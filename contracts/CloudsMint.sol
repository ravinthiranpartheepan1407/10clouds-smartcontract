// SPDX-License-Identifier: Unlicense
 pragma solidity ^0.8.13;

 import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
 import "@openzeppelin/contracts/access/Ownable.sol";


 contract CloudMint is ERC721Enumerable, Ownable {

     string _baseTokenURI;

     uint256 public _price = 0.01 ether;

     bool public _paused;

     uint256 public maxTokenIds = 100;

     uint256 public tokenIds;

      uint maxGiveAway = 0;


     modifier onlyWhenNotPaused {
         require(!_paused, "Contract currently paused");
         _;
     }

     constructor (string memory baseURI) ERC721("10 Clouds Token", "CDN") {
         _baseTokenURI = baseURI;
     }


     function mint() public payable onlyWhenNotPaused {
         require(tokenIds < maxTokenIds, "Exceed maximum 10 Cloud Token Total supply");
         require(msg.value >= _price, "Ether sent is not correct");
         require(balanceOf(msg.sender) <= maxGiveAway,"No more available.!");
         tokenIds += 1;
         _safeMint(msg.sender, tokenIds);
     }


     function _baseURI() internal view virtual override returns (string memory) {
         return _baseTokenURI;
     }


     function setPaused(bool val) public onlyOwner {
         _paused = val;
     }


     function withdraw() public onlyOwner  {
         address _owner = owner();
         uint256 amount = address(this).balance;
         (bool sent, ) =  _owner.call{value: amount}("");
         require(sent, "Failed to send Ether");
     }


     receive() external payable {}


     fallback() external payable {}
 }
