pragma solidity 0.8.7;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Libraries/SafeMath.sol";
import "./Libraries/FullMath.sol";
import "./PriceAggregator.sol";
import "./Positions.sol";
import "./NFTManager.sol";
contract AuctioPool is PriceAggregator, Position,NFTManager {

    uint public discount=8;
    uint public fee=3;
    address treasury;
    address pool;

    IERC20 USDC=IERC20(0x5A86858aA3b595FD6663c2296741eF4cd8BC4d01);
    NFTManager NFT=NFTManager(0x1c91347f2A44538ce62453BEBd9Aa907C662b4bD);
    PriceAggregator priceB=PriceAggregator(0x93f8dddd876c7dBE3323723500e83E202A7C96CC);
    function auction (uint _amount)external{
        uint FEES=FullMath.mulDivRoundingUp(fee, _amount, 100);
        uint newAmount=SafeMath.sub(_amount, FEES);
        uint ethAmount=priceB.getConversionRateEth(_amount);
        uint FeeusdcAmount=priceB.getConversionRateUsdc(FEES);
        uint usdcAmount=priceB.getConversionRateUsdc(newAmount);
        USDC.transferFrom(msg.sender, treasury, FeeusdcAmount);
        USDC.transferFrom(msg.sender, pool, usdcAmount);
        address(this).balance-ethAmount;
        (bool sent, ) = payable(msg.sender).call{value: ethAmount}("");
        require(sent, "Failed to send Ether");

    }

    function auctionWithNft(uint _id)external{
        NFT.transferFrom(msg.sender, address(this), _id);
        NFT.burn(_id);
        LOCUS memory data=locus[_id];
        TOKENDATA memory tokenData=tokenData[_id];
        uint value=SafeMath.mul(data.k, tokenData.amount);
        uint FEES=FullMath.mulDivRoundingUp(fee, value, 100);
        uint newAmount=SafeMath.sub(value, FEES);
        uint FeeusdcAmount=priceB.getConversionRateUsdc(FEES);
        USDC.transferFrom(pool, treasury, FeeusdcAmount);
        uint ethAmount=priceB.getConversionRateEth(newAmount);
        address(this).balance-ethAmount;
        (bool sent, ) = payable(msg.sender).call{value: ethAmount}("");
        require(sent, "Failed to send Ether");

    }

}