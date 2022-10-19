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
      uint a=data.collateralFactor;
      uint b=data.interestRate;
      uint c=data.amount;
      return Base64.encode(bytes(string(
          abi.encodePacked(

          '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="1080" height="1080" viewBox="0 0 1080 1080" xml:space="preserve">'
'<rect x="0" y="0" width="100%" height="100%" fill="transparent">''</rect>'
'<g transform="matrix(1 0 0 1 540 540)" id="33a1e131-0355-42ea-98a8-26c5142f8764"  >'
'</g>'
'<g transform="matrix(1 0 0 1 540 540)" id="d7004637-3313-45f3-afd4-f2834fff5c13"  >'
'<rect style="stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(255,255,255); fill-rule: nonzero; opacity: 1;" vector-effect="non-scaling-stroke"  x="-540" y="-540" rx="0" ry="0" width="1080" height="1080" />'
'</g>'
'<g transform="matrix(1.81 0 0 1.81 540 540)"  >'
'<rect style="stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(255,255,255); fill-rule: nonzero; opacity: 1;" vector-effect="non-scaling-stroke"  x="-150" y="-240" rx="0" ry="0" width="300" height="480" />'
'</g>'
'<g transform="matrix(1.81 0 0 1.81 540 540.01)"  >'
'<rect style="stroke: rgb(0,0,0); stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(119,147,172); fill-rule: nonzero; opacity: 1;" vector-effect="non-scaling-stroke"  x="-120" y="-210" rx="15" ry="15" width="240" height="420" />'
'</g>'
'<g transform="matrix(1.81 0 0 1.81 540 301.09)"  >'
'<rect style="stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(37,28,28); fill-rule: nonzero; opacity: 1;" vector-effect="non-scaling-stroke"  x="-120" y="-21" rx="0" ry="0" width="240" height="42" />'
'</g>'
'<g transform="matrix(1.81 0 0 1.81 540.2 298.58)" style=""  >'
		'<text xml:space="preserve" font-family="sans-serif" font-size="30" font-style="normal" font-weight="bold" style="stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(255,255,255); fill-rule: nonzero; opacity: 1; white-space: pre;" >''<tspan x="-42.5" y="9.42" >''USDC''</tspan>''</text>'
'</g>'
'<g transform="matrix(1.81 0 0 1.81 540 746.35)"  >'
'<rect style="stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(0,0,0); fill-rule: nonzero; opacity: 1;" vector-effect="non-scaling-stroke"  x="-120" y="-12" rx="0" ry="0" width="240" height="24" />'
'</g>'
'<g transform="matrix(1.81 0 0 1.81 540 800.64)"  >'
'<rect style="stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(0,0,0); fill-rule: nonzero; opacity: 1;" vector-effect="non-scaling-stroke"  x="-120" y="-12" rx="0" ry="0" width="240" height="24" />'
'</g>'
'<g transform="matrix(0.32 0 0 0.26 410.18 747.26)" style="" id="b7a36e4d-f528-4500-9353-563874008126"  >'
		'<text xml:space="preserve" font-family="Alegreya" font-size="80" font-style="normal" font-weight="700" style="stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(255,255,255); fill-rule: nonzero; opacity: 1; white-space: pre;" >''<tspan x="-217.44" y="25.13" >tokenId: #',data.tokenId.toString(),'</tspan>''</text>'
'</g>'
'<g transform="matrix(0.27 0 0 0.27 422.97 800.11)" style=""  >'
		'<text xml:space="preserve" font-family="Alegreya" font-size="80" font-style="normal" font-weight="700" style="stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(255,255,255); fill-rule: nonzero; opacity: 1; white-space: pre;" >''<tspan x="-310.92" y="25.13" >',c,'</tspan></text>'
'</g>'
'<g transform="matrix(0.32 0 0 0.32 398.26 429.71)" style="" id="9afaa311-6335-47c2-85d7-75a6841d5a43"  >'
		'<text xml:space="preserve" font-family="Lato" font-size="40" font-style="normal" font-weight="400" style="stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(0,0,0); fill-rule: nonzero; opacity: 1; white-space: pre;" >''<tspan x="-23.2" y="12.57" >',a,'</tspan>''</text>'
'</g>'
'<g transform="matrix(0.3 0 0 0.3 613.24 675.33)" style="" id="a42d5e1d-b62f-44f1-86cb-150d8dbfcd08"  >'
		'<text xml:space="preserve" font-family="Lato" font-size="40" font-style="normal" font-weight="400" style="stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(0,0,0); fill-rule: nonzero; opacity: 1; white-space: pre;" >''<tspan x="-23.2" y="12.57" >',b,'</tspan>''</text>'
'</g>'
'<g transform="matrix(0.3 0 0 0.3 640.92 415.41)" style="" id="03f4a122-535c-4209-b446-7617028ae2f2"  >'
		'<text xml:space="preserve" font-family="Lato" font-size="40" font-style="normal" font-weight="400" style="stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(0,0,0); fill-rule: nonzero; opacity: 1; white-space: pre;" >''<tspan x="-62.64" y="12.57" >(',a,b,')</tspan>''</text>'
'</g>'
'<g transform="matrix(0.83 0 0 0.83 539.69 541.07)"  >'
'<g style="" vector-effect="non-scaling-stroke"   >'
		'<g transform="matrix(1 0 0 1 -153.5 0)"  >'
'<path style="stroke: rgb(0,0,0); stroke-width: 5; stroke-dasharray:  ; stroke-linecap: null; stroke-dashoffset: 0; stroke-linejoin: null; stroke-miterlimit: 4; fill: none; fill-rule: nonzero; opacity: 1;" vector-effect="non-scaling-stroke"  transform=" translate(-73.5, -214.5)" d="M 71.5 17.00002 L 75.5 412.00001000000003" stroke-linecap="round" />'
'</g>'
		'<g transform="matrix(1 0 0 1 0 137.5)" id="svg_2"  >'
'<line style="stroke: rgb(0,0,0); stroke-width: 5; stroke-dasharray:  ; stroke-linecap: null; stroke-dashoffset: 0; stroke-linejoin: null; stroke-miterlimit: 4; fill: none; fill-rule: nonzero; opacity: 1;" vector-effect="non-scaling-stroke"  x1="-194.499995" y1="0" x2="194.499995" y2="0" />'
'</g>'
		'<g transform="matrix(1 0 0 1 87.5 -11)" id="svg_5"  >'
'<line style="stroke: rgb(0,0,0); stroke-width: 2; stroke-dasharray:  ; stroke-linecap: null; stroke-dashoffset: 0; stroke-linejoin: null; stroke-miterlimit: 4; fill: none; fill-rule: nonzero; opacity: 1;" vector-effect="non-scaling-stroke"  x1="1" y1="150.5" x2="-1" y2="-150.5" />'
'</g>'
		'<g transform="matrix(1 0 0 1 -17.5 -132)" id="svg_3"  >'
'<line style="stroke: rgb(0,0,0); stroke-width: 2; stroke-dasharray:  ; stroke-linecap: null; stroke-dashoffset: 0; stroke-linejoin: null; stroke-miterlimit: 4; fill: none; fill-rule: nonzero; opacity: 1;" vector-effect="non-scaling-stroke"  x1="-136" y1="1.5" x2="136" y2="-1.5" />'
'</g>'
'</g>'
'</g>'
'<g transform="matrix(0.39 0 0 0.39 628.6 678.63)" style="" id="070bf1af-5900-4edf-b809-1e27d4566f83"  >'
		'<text xml:space="preserve" font-family="Lato" font-size="40" font-style="normal" font-weight="400" style="stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-dashoffset: 0; stroke-linejoin: miter; stroke-miterlimit: 4; fill: rgb(0,0,0); fill-rule: nonzero; opacity: 1; white-space: pre;" ><tspan x="-6.14" y="12.57" >''I''</tspan>''</text>'
'</g>'
'</svg>'




          )
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

