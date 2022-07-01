// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Galacticore is ERC721URIStorage, Ownable {
    
    uint256 constant maxSupply = 1112;
    uint256 constant nftPerAddressLimitPresale = 3;
    uint256 constant nftPerAddressLimitPublic = 50;
    uint256 constant nftPerTXLimit = 20;
    uint256 private pricePrivate;
    uint256 private pricePublic;
    uint256 public currentMint = 1;
    uint32 public actualmint=uint32(currentMint-1);
    
    string private customBaseURI;
    string private contractURI;


    address[] public whitelistedAddresses;
    address[] public freeMintAddresses;
    address FOUNDER_1 = 0x171d53eC7358d52Cc511299E8f68c9F608509f4A;
    address FOUNDER_2 = 0x70a5b7A0A40c2842daf9BC9e6ff874fdD38f6F5c;
    address GAME_DEV;
    address ARTIST;
    
    address private artist;
    uint256 private royaltyAmount;

    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    bool private isPublicSaleActive = false;
    bool private isPrivateSaleActive = false;

    mapping (address => uint32) internal adminMintCount;
    mapping(address => uint256) public mintCount;
    mapping(address => uint256) public freemintCount;

  constructor() ERC721("Galacticore", "GCORE") {
    customBaseURI = '';
    pricePrivate = 1 ether;
    pricePublic = 1.2 ether;
    royaltyAmount = 50;
    contractURI = '';
    ownerMint(30);
  }
  
    // TOGGLE FUNCTIONS

    function togglePublicMint() public onlyOwner {
        isPublicSaleActive = !isPublicSaleActive;
  }
    function togglePrivateMint() public onlyOwner {
        isPrivateSaleActive = !isPrivateSaleActive;
  }
    
    // INFO FUNCTIONS 

    function _contractURI() public view returns (string memory) {
        return contractURI;
  }


    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address receiver, uint256 _royaltyAmount) {
        return (GAME_DEV, ((_salePrice * royaltyAmount) / 1111));
  }

    //ERC2981

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
        if (interfaceId == _INTERFACE_ID_ERC2981) {
            return true;
    }
        return super.supportsInterface(interfaceId);
    }
    
    
    // SET FUNCTONS


    function setBaseURI(string memory newCustomBaseURI) public onlyOwner {
        customBaseURI = newCustomBaseURI;
}

     function setContractURI(string memory newContractURI) public onlyOwner {
        contractURI = newContractURI;
}    
    // WHITELIST CONTROLS
    
    function isWhitelisted(address _user) public view returns (bool) {
    for (uint i = 0; i < whitelistedAddresses.length; i++) {
      if (whitelistedAddresses[i] == _user) {
          return true;
      }
    }
    return false;
    }


    function isfreeMinter(address __user) public view returns (bool) {
    for (uint i = 0; i < freeMintAddresses.length; i++) {
      if (freeMintAddresses[i] == __user) {
          return true;
      }
    }
    return false;
    }

    //whitelist = ["address"]
    
    function addwhitelistUsers(address[] calldata _users) public onlyOwner {
        delete whitelistedAddresses;
        whitelistedAddresses = _users;
}

    function addFreeMintUsers(address[] calldata _users) public onlyOwner {
        delete freeMintAddresses;
        freeMintAddresses = _users;
}



    //MINT FUNCTIONS

    function mint(uint amount) public payable {
        require (isPublicSaleActive || isPrivateSaleActive, "Sale is not active");
        if(isPrivateSaleActive==true && isPublicSaleActive==false){
            require(msg.value >= pricePrivate*amount, "Balance is not enough");
            require(isWhitelisted(msg.sender), "You are not whitelisted");
            require(currentMint+amount<=maxSupply, "Amount exceeds max supply");
            require(amount>0, "Amount cannot be zero");
            require (mintCount[msg.sender] + amount <= nftPerAddressLimitPresale, "You have max amount of NFTs.");
            for(uint i=0; i<amount; i++){
                if(isWhitelisted(msg.sender)){
                _safeMint(msg.sender, currentMint + i);
                mintCount[msg.sender]++;
            }
            currentMint = currentMint + 1;
        }
    }
        if(isPrivateSaleActive==false && isPrivateSaleActive==true){
            require(msg.value >= pricePublic*amount, "Balance is not enough");
            require(currentMint+amount<=maxSupply, "Amount exceeds max supply");
            require(amount>0, "Amount cannot be zero");
            require(balanceOf(msg.sender)+amount<=nftPerAddressLimitPublic, "You cannot mint more than 50 on public sale");
            for(uint i=0; i<amount; i++){
                _safeMint(msg.sender, currentMint + i);
                mintCount[msg.sender]++;
                currentMint = currentMint + 1;
        }
        }
    }


     function ownerMint(uint256 _mintAmount) public onlyOwner {
        require(currentMint + _mintAmount <= maxSupply, "Max NFT limit exceeded"); 
        require(_mintAmount >= 0, "Mint amount should be at least 1");
        for(uint i=0; i<_mintAmount; i++){
            _safeMint(msg.sender, currentMint + i);
            adminMintCount[msg.sender]++;
        
    }
        currentMint = currentMint + _mintAmount;
}



    function freeMint() public {
        require(isfreeMinter(msg.sender), "You are not eligible for free mint");
        require(isPrivateSaleActive, "Free mint is not active");
        require(freemintCount[msg.sender]==0, "You have already minted free");
            _safeMint(msg.sender, currentMint + 1);
            freemintCount[msg.sender]+=1;
    }

    // SET WALLET FUNCTIONS  
    
    
    function setFounder1(address newFounder1) public onlyOwner{
        FOUNDER_1=newFounder1;
    }

    function setFounder2(address newFounder2) public onlyOwner{
        FOUNDER_2=newFounder2;
    }
    
    function setGameWallet(address _gamewallet) public onlyOwner{
        GAME_DEV=_gamewallet;
    }

    function setartistwallet(address _artistwallet) public onlyOwner {
        ARTIST=_artistwallet;
    }



    //WITHDRAW
    
    function _withdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Transfer failed.");
}
        
        
        
        function withdrawAll() public onlyOwner {
            uint256 balance = address(this).balance;
            require(balance > 0);

            _withdraw(FOUNDER_1, (balance*15)/100);
            _withdraw(FOUNDER_2, (balance*15)/100);
            _withdraw(GAME_DEV, (balance*65)/100);
            _withdraw(ARTIST, (balance*5)/100);
        
}

}
