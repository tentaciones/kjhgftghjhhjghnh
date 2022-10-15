pragma solidity 0.8.7;

contract Position{



    struct LOCUS{
        uint256 collateralFactor;
        uint256 interestRate;
        uint256 locusId;
        uint256 liquidity;
        uint256 k;
        bool initialized;
    }

    struct TOKENDATA{
        uint256 amount;
        uint256 collateralFactor;
        uint256 interestRate;
        uint256 locusId;
        uint256 tokenId;
        uint256 kAtInstance;
        string name;
        string description;
        string bgHue;
        string textHue;
    }


    



    mapping(uint =>Position.LOCUS) public locus;
    mapping (uint =>mapping(uint =>Position.LOCUS)) public getLocus;

    function get(uint _locusId)internal view returns (LOCUS memory data ){
        
        data=locus[_locusId];
    }

    function put( uint256 _collateralFactor, uint256 _interestRate, uint256 _count, uint _liquidity)internal {
        
        locus[_count]=(LOCUS({collateralFactor:_collateralFactor,interestRate:_interestRate,locusId:_count,liquidity: _liquidity, k:1, initialized:true }));
        getLocus[_collateralFactor][_interestRate]=locus[_count];
        
    }

    function update(uint _locusId, uint _deltaK, uint _deltaLiquidity)internal{
        locus[_locusId].k+=_deltaK;
        locus [_locusId].liquidity+=_deltaLiquidity;
    }

}
