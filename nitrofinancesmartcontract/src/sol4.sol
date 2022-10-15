pragma solidity 0.8.7;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Positions.sol";
import "./NFTManager.sol";
import "./Libraries/errors.sol";
import "./Libraries/SafeMath.sol";
import "./Libraries/FullMath.sol";
import "./PriceAggregator.sol";
import "./BorrowLogic.sol";

contract SOL4 is Position, errors, PriceAggregator, BorrowLogic{

    using SafeMath for uint256;
    using FullMath for uint256;
    NFTManager NFT=NFTManager(0x8B801270f3e02eA2AACCf134333D5E5A019eFf42);
    IERC20 USDC=IERC20(0x7EF2e0048f5bAeDe046f6BF797943daF4ED8CB47);
    PriceAggregator priceB=PriceAggregator(0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B);
    BorrowLogic logic=BorrowLogic(0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B);
    address auctionPool=0x406AB5033423Dcb6391Ac9eEEad73294FA82Cfbc;

    uint256 nextId=1;
    uint locusTracker=1;
    uint64 LasttimeStamp;
    uint256 liquidationThreshold;
    uint256 LiquidationFee;

    uint256 private constant DELTA_K_PRECISION = 1e10;
    uint256 private constant K_MANTISSA=1e6;
    uint256 private constant SECONDS_PER_YEAR=31536000;

    struct TOKENID{
        uint _tokenId;
    }

    mapping (address =>uint) public collateralAmount;
    mapping (address=>uint) public collateralValue;
    mapping (address=>uint) public borrowedValue;
    mapping (address=>uint)public tmcr;
    mapping (address=>uint)public ir;
    mapping (uint256=>uint64)public differenceInTime_K;
    mapping (uint256=>uint64)public LasttimeStamp_k;
    mapping (uint =>uint) public NFTidToAmount;
    mapping (uint =>TOKENID[]) public locusToNftId;
    mapping(uint256=>mapping(uint256=>uint256))public AmountBorrowedFromLocus;
    mapping(uint256=>mapping(uint256=>uint64))public LastKtimeStamp;
    


    function addLiquidity(uint _collateralFactor, uint _interestRate, uint _value) external{
        LOCUS memory data=getLocus[_collateralFactor][_interestRate];
        if (data.collateralFactor!=_collateralFactor&& data.interestRate!=_interestRate){
            _create(_collateralFactor,_interestRate, _value);
        }else{
            _update(_collateralFactor,_interestRate, _value);
        } 
    }

    function _create(uint _collateralFactor, uint _interestRate, uint _value) internal{
        uint kInitialValue=1*DELTA_K_PRECISION;
        put( _collateralFactor,  _interestRate, locusTracker, _value);
        uint usdcAmount=priceB.getConversionRateUsdc(_value);
        USDC.transferFrom(msg.sender, address(this), usdcAmount);
        NFT.createPosition(nextId,_collateralFactor,_interestRate, _value,kInitialValue,locusTracker );
        NFTidToAmount[nextId]=_value;
        TOKENID []storage data=locusToNftId[locusTracker];
        data.push(TOKENID({_tokenId:nextId})); 
        
        locusTracker++;
        nextId ++;
    }


    function _update(uint _collateralFactor, uint _interestRate, uint _value) internal{
        LOCUS memory data=getLocus [_collateralFactor][_interestRate];
        update(data.locusId,0, _value);
        uint usdcAmount=priceB.getConversionRateUsdc(_value);
        USDC.transferFrom(msg.sender, address(this), usdcAmount);
        if (AmountBorrowedFromLocus[_collateralFactor][_interestRate]==0){
            NFT.createPosition(nextId,_collateralFactor,_interestRate, _value,1*DELTA_K_PRECISION,data.locusId );
            NFTidToAmount[nextId]=_value;
            TOKENID []storage tokenId=locusToNftId[locusTracker];
            tokenId.push(TOKENID({_tokenId:nextId}));
            data.liquidity+=_value;
            nextId ++;
        }else{
            accuredK(_collateralFactor, _interestRate);
            uint amount=SafeMath.div(_value*1e10, data.k);
            NFT.createPosition(nextId,_collateralFactor,_interestRate, amount,data.k,data.locusId );
            NFTidToAmount[nextId]=amount;
            data.liquidity+=_value;
            TOKENID []storage tokenId=locusToNftId[locusTracker];
            tokenId.push(TOKENID({_tokenId:nextId}));
            nextId ++;

        }
        
    }

    function borrow(uint _collateralFactor, uint _interestRate, uint _value)external{
        if (borrowedValue[msg.sender]==0){
            _initBorrow( _collateralFactor,  _interestRate,  _value);
        }else{
            _subBorrows( _collateralFactor,  _interestRate,  _value);
        }

    }

    function _initBorrow(uint _collateralFactor, uint _interestRate, uint _value) internal{
        cook();
        LOCUS memory data=getLocus[_collateralFactor][_interestRate];
        if (data.collateralFactor!=_collateralFactor&& data.interestRate!=_interestRate){
            revert LOCUS_NOT_IN_EXISTENCE();

        }else{
            require (collateralValue[msg.sender]>_value, "not enough collateral");
            require(FullMath.mulDivRoundingUp(collateralValue[msg.sender],_collateralFactor, 100)>_value, "more than max borrow");
            require(_value<=data.liquidity, "not enough liquidity");
            borrowedValue[msg.sender]=_value;
            AmountBorrowedFromLocus[_collateralFactor][_interestRate]+=_value;
            uint usdcAmount=priceB.getConversionRateUsdc(_value);
            USDC.transfer(msg.sender, usdcAmount);
            data.liquidity-=_value;
            BORROWTRANSACTIONS []storage borrowData=addressToBorrowTransaction[msg.sender];
            borrowData.push(BORROWTRANSACTIONS({interestRateBorrowedAt:_interestRate, collateralFactorBorrowedAt:_collateralFactor, totalBorrowed:_value, borrower:msg.sender,  locusId:data.locusId}));         
                

        }
        
    }

    function _subBorrows(uint _collateralFactor, uint _interestRate, uint _value) internal{    
        cook();
        LOCUS memory data=getLocus[_collateralFactor][_interestRate];
        if (data.collateralFactor!=_collateralFactor&& data.interestRate!=_interestRate){
            revert LOCUS_NOT_IN_EXISTENCE();
        }else{
            BORROWTRANSACTIONS [] storage borrowData= addressToBorrowTransaction[msg.sender];
            require (collateralValue[msg.sender]>_value, "not enough collateral");
            require(_value<=data.liquidity, "not enough liquidity");   
            _tmcr(_collateralFactor, _value);
            require(tmcr[msg.sender]<=_collateralFactor, "ooooooopopopo"); 
            require(_value<=FullMath.mulDivRoundingUp(_collateralFactor,_value,100), "ppppp"); 
            borrowedValue[msg.sender]+=_value;
            AmountBorrowedFromLocus[_collateralFactor][_interestRate]+=_value;
            uint usdcAmount=priceB.getConversionRateUsdc(_value);
            USDC.transfer(msg.sender, usdcAmount);
            data.liquidity-=_value;
            for (uint i; i<borrowData.length;i++){
                if (borrowData[i].collateralFactorBorrowedAt==data.collateralFactor && borrowData[i].interestRateBorrowedAt==data.interestRate){
                    borrowData[i].totalBorrowed+=_value;
                }else{

                    borrowData.push(BORROWTRANSACTIONS({interestRateBorrowedAt:_interestRate, collateralFactorBorrowedAt:_collateralFactor, totalBorrowed:_value, borrower:msg.sender,  locusId:data.locusId}));         
                }
            }
            
        }
        
    }

    function _tmcr(uint _collateralFactor, uint _value)internal{
        BORROWTRANSACTIONS []storage borrowData=addressToBorrowTransaction[msg.sender];
        if (borrowData.length==0){
            tmcr[msg.sender]=0;

        }else{
            uint presumedDebt=borrowedValue[msg.sender]+_value;
            uint yColFactor=FullMath.mulDivRoundingUp(_value,100,presumedDebt);
            uint bColFactor=FullMath.mulDivRoundingUp(yColFactor,_collateralFactor,100 );

            tmcr[msg.sender]=0;

            for (uint i;i<borrowData.length;i++){
                uint zColFactor=FullMath.mulDivRoundingUp(borrowData[i].totalBorrowed,100,presumedDebt);
                uint aColFactor=FullMath.mulDivRoundingUp(zColFactor,borrowData[i].collateralFactorBorrowedAt,100 );
                tmcr[msg.sender]+=aColFactor;

            }

            tmcr[msg.sender]+=bColFactor;


        }

    }

    function addCollateral()external payable {
        address(this).balance+msg.value;  
        collateralAmount[msg.sender]+=msg.value;
        collateralValue[msg.sender]=priceB.inverseConversionEth(collateralAmount[msg.sender]);

    }

    function withdrawLiquidity(uint256 _id, uint _amount) external{
        cook();
        require(NFTidToAmount[_id]>=_amount, "you dont have the amount you are trying to withdraw");
        if(NFTidToAmount[_id]==_amount){
            LOCUS memory data=locus[_id];
            NFT.transferFrom(msg.sender, address(this), _id );
            NFTidToAmount[_id]=0;
            NFT.burn(_id);
            
            uint usdcAmount=priceB.getConversionRateUsdc(_amount);
            USDC.transferFrom(msg.sender, address(this), usdcAmount);
            data.liquidity-=_amount;
           
        }else if (NFTidToAmount[_id]>_amount) {
            LOCUS memory data=locus[_id];
            NFTidToAmount[_id]-=_amount;
            NFT.transferFrom(msg.sender, address(this), _id );
            uint usdcAmount=priceB.getConversionRateUsdc(_amount);
            USDC.transferFrom(msg.sender, address(this), usdcAmount);
            data.liquidity-=_amount;
            NFT.createPosition(nextId,data.collateralFactor,data.interestRate, NFTidToAmount[_id]-=_amount, data.k,data.locusId );
            NFT.burn(_id);
            nextId++;
        }
    }



    function withdrawCollateral(uint _amount)external payable{
        cook();
        require (_amount<=collateralAmount[msg.sender], "amount greater than available collateral");
        if (borrowedValue[msg.sender]==0){ 
            address(this).balance-_amount;
            (bool sent, ) = payable(msg.sender).call{value: _amount}("");
            require(sent, "Failed to send Ether");
            collateralAmount[msg.sender]-=_amount;
        }else{
            uint calc=FullMath.mulDivRoundingUp(borrowedValue[msg.sender],100, liquidationThreshold);
            uint safeValuetWithdrawable=SafeMath.sub(collateralValue[msg.sender],calc);
            uint safeAmountWithdrawable=priceB.getConversionRateEth(safeValuetWithdrawable);
            require (_amount <=safeAmountWithdrawable, "cant withdraw collateral used to support borrow");
            address(this).balance-_amount;
            (bool sent, ) = payable(msg.sender).call{value: _amount}("");
            require(sent, "Failed to send Ether");
            collateralAmount[msg.sender]-=_amount;  

        }
    }

    function repay(uint _amount, uint256 _collateralFactor, uint256 _interestRate)external {
        cook();
        BORROWTRANSACTIONS [] storage borrowData= addressToBorrowTransaction[msg.sender];
        LOCUS memory data=getLocus[_collateralFactor][_interestRate];
        for (uint i; i<borrowData.length;i++){ 
            if(borrowData.length==0){ 
                revert NOT_OWING();
            }else if(data.collateralFactor==borrowData[i].collateralFactorBorrowedAt&& data.interestRate==borrowData[i].interestRateBorrowedAt){
                require (_amount<=borrowData[i].totalBorrowed, "amount more than borrowed amount");
                uint usdcAmount=priceB.getConversionRateUsdc(_amount);
                USDC.transferFrom(msg.sender, address(this), usdcAmount);
                borrowedValue[msg.sender]-=_amount; 
                AmountBorrowedFromLocus[_collateralFactor][_interestRate]+=_amount;
                if(_amount==borrowData[i].totalBorrowed){

                    borrowData[i]=borrowData[borrowData.length-1];
                    borrowData.pop();
                    
                }else{
                    borrowData[i].totalBorrowed-=_amount;
                }

            }

        }

    }

    function liquidate (address _borrower)external{
        cook();
        require (borrowedValue[_borrower]>0, "no borrow");
        uint x=SafeMath.mul(borrowedValue[msg.sender],100);
        uint healtFactor=FullMath.mulDivRoundingUp(collateralValue[_borrower],liquidationThreshold,x);
        
        if (healtFactor<1){
            BORROWTRANSACTIONS [] memory borrowData= addressToBorrowTransaction[_borrower];
            collateralAmount[_borrower]=0;
            borrowedValue[_borrower]=0;
            address(this).balance-collateralAmount[_borrower];
            (bool sent, ) = payable(auctionPool).call{value: collateralAmount[_borrower]}("");
            require(sent, "Failed to send Ether");
            for (uint i;i<borrowData.length;i++){
                liquidatedTransactions.push(LIQUIDATEDTRANSACTIONS({ locusId:borrowData[i].locusId,interestRateBorrowedAt:borrowData[i].interestRateBorrowedAt,collateralFactorBorrowedAt:borrowData[i].collateralFactorBorrowedAt,  amountLiquidatedFromPool:borrowData[i].totalBorrowed}));
            }
            borrowData=new BORROWTRANSACTIONS[](0);
            allLiquidators.push(msg.sender);
        }else if(healtFactor>=1){
            revert  CANT_BE_LIQUIDATED();
        }
    }

    function UpdatePoolAfterLiquidation()external{
        for (uint i; i>liquidatedTransactions.length; i++){
            LIQUIDATEDTRANSACTIONS  storage LiquidationData=liquidatedTransactions[i];
            LOCUS memory data=getLocus[LiquidationData.collateralFactorBorrowedAt][LiquidationData.interestRateBorrowedAt];
            if (LiquidationData.locusId==data.locusId){
                data.liquidity+=LiquidationData.amountLiquidatedFromPool;
                LiquidationData.amountLiquidatedFromPool=0;

                
            }
            
        }    

    }

    function chackIfLiquidationIsAllowed (address _borrower)public view  returns (bool CAN_BE_LIQUIDATED){
        require (borrowedValue[_borrower]>0, "no borrow");
        uint x=SafeMath.mul(borrowedValue[_borrower],100);
        uint healtFactor=FullMath.mulDivRoundingUp(collateralValue[_borrower],liquidationThreshold,x);
        if (healtFactor<1){
             return true;
        }else if(healtFactor>=1){
             return false;
        }
    }

    function setLiquidationThreshold(uint _LiquidationFee)external{
        LiquidationFee=_LiquidationFee;
        liquidationThreshold=100-_LiquidationFee;
    }

    function cook ()internal{
        collateralValue[msg.sender]=priceB.inverseConversionEth(collateralAmount[msg.sender]);
        //getPriceUsdc();
        //getPriceEth();
    }

    function getNowInternal() public view virtual returns (uint64) {
        if (block.timestamp >= 2**64) revert TimestampTooLarge();
        return uint64(block.timestamp);
    }

    function accuredK(uint _collateralFactor, uint _interestRate) internal {
        uint64 now_ = getNowInternal();
        uint64 formerTime = LastKtimeStamp[_collateralFactor][_interestRate];
        uint64 timeElapsed = now_ - formerTime;
        uint borrowed=AmountBorrowedFromLocus[_collateralFactor][_interestRate]; 
        LOCUS memory data=getLocus[_collateralFactor][_interestRate];
        if (data.collateralFactor==_collateralFactor&& data.interestRate==_interestRate){
            uint UtilizationRate=FullMath.mulDivRoundingUp(borrowed, 100,data.liquidity);
            uint Krate=FullMath.mulDivRoundingUp(UtilizationRate,data.interestRate,100);
            uint NewKValue=((Krate*1e7 /(SECONDS_PER_YEAR*100))*timeElapsed*1);
            data.locusId+=NewKValue;
            
        }
         LastKtimeStamp[_collateralFactor][_interestRate] = now_;
    }



    /*function _timeChangeK(uint _locusId) internal {
        uint64 now_ = getNowInternal();
        uint64 formerTime = LasttimeStamp_k[_locusId];
        differenceInTime_K[_locusId] = now_ - formerTime;
         
        LasttimeStamp_k[_locusId] = now_;
    }
    //
//1*((1+0.05)/12)**12*1
    function _deltaK(uint _tokenId, uint _kRate) public pure returns (uint, uint, uint ){
        //_timeChangeK(_tokenId);
        //LOCUS memory data=locus [_tokenId];
        uint toPercentage=SafeMath.div(_kRate*1e3, 100);
        uint compoundInterest=SafeMath.com(_tokenId,toPercentage, 12 );
     uint x=toPercentage/12;
     uint y=x+1000;
     uint j=y**12;
     uint check=j*_tokenId;
        return (compoundInterest, y, x);

    }*/



}