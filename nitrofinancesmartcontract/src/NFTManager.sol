pragma solidity 0.8.7;
import "./NitroFinaceLiquidityPositions.sol";
import "./Positions.sol";
import "./Libraries/Base64.sol";
contract NFTManager is Position, NitroFinaceLiquidityPositions{
    using Strings for uint256;
    mapping(uint =>Position.TOKENDATA) public tokenData;


    function createPosition(uint _tokenId, uint _collateralFactor, uint256 _interestRate, uint256 _liquidity, uint256 kValueAtDeltaK, uint _locusId)external{
        safeMint(tx.origin,_tokenId);
        tokenData[_tokenId]=(TOKENDATA({amount:_liquidity,collateralFactor:_collateralFactor,interestRate:_interestRate, locusId:_locusId,tokenId:_tokenId, kAtInstance:kValueAtDeltaK,  name:string(abi.encodePacked('NitroFinance #', uint256(_tokenId).toString())), description:"Represents liquidity added to a specific position on nitrofinance",   bgHue:randomNum(361, block.difficulty, _tokenId).toString(),
        textHue:randomNum(361, block.timestamp, _tokenId).toString()}));
        //locus[_locusId]=(LOCUS({collateralFactor:_collateralFactor,interestRate: _interestRate,locusId:_locusId, k:kValueAtDeltaK,initialized:true }));

    }

    function randomNum(uint256 _mod, uint256 _seed, uint _salt) public view returns(uint256) {
      uint256 num = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
      return num;
    }
 function buildImage(uint256 tokenId) public view returns(string memory) {
      TOKENDATA memory data = tokenData[tokenId];
      string memory a=data.collateralFactor.toString();
      string memory b=data.interestRate.toString();
      string memory c=data.amount.toString();
      return Base64.encode(bytes(
          abi.encodePacked(




          )
      ));
  }


    function buildMetadata(uint256 _tokenId) public view returns(string memory) {
      TOKENDATA memory data=  tokenData[_tokenId];
      return string(abi.encodePacked(
              'data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
                          '{"name":"', 
                          data.name,
                          '", "description":"', 
                          data.description,
                          '", "image": "', 
                          'data:image/svg+xml;base64,', 
                          buildImage(_tokenId),
                          '"}')))));
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
      require(_exists(_tokenId),"ERC721Metadata: URI query for nonexistent token");
      return buildMetadata(_tokenId);
    }

 

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}

