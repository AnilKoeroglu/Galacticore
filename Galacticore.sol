// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// Creator : Galacticore
// Author :  Ferrosia - anilkoroglu03@gmail.com

contract Galacticore is 
Ownable, 
ERC721Enumerable
{
    using Strings for uint256;

/* VARIABLES HERE */
    
    string public notRevealedURI;
    string public baseURI;
    string public baseExtension = ".json";
    
    
    uint256 public price = 1200000000000000000;
    uint256 public pricePrivate = 1000000000000000000;
    uint256 constant maxSupply = 1112;
    uint256 constant nftPerAddressLimitPresale = 3;
    uint256 constant nftPerAddressLimitPublic = 50;
    uint256 constant nftPerTXLimit = 20;
    uint256 public currentMint = 1;
    uint32 public ownedCounter = uint32(balanceOf(msg.sender));
    uint32 public actualmint=uint32(currentMint-1);

    bool public IS_PUBLIC_SALE_ACTIVE = false;
    bool public IS_PRE_SALE_ACTIVE = false;
    bool revealed = false;
    

    
    address[] public whitelistedAddresses;
    address[] public freeMintAddresses;
    address FOUNDER_1 = 0x171d53eC7358d52Cc511299E8f68c9F608509f4A;
    address FOUNDER_2 = 0x70a5b7A0A40c2842daf9BC9e6ff874fdD38f6F5c;
    address GAME_DEV;
    address ARTIST;

    
    mapping (address => uint32) internal adminMintCount;
    mapping(address => uint256) public mintCount;
    mapping(address => uint256) public freemintCount;


    
     constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
  }
  

    //******URI FUNCTIONS*******
    
    function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    if(revealed == false) {
        return notRevealedURI;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }
    
    
    function reveal() public onlyOwner {
        revealed = true;
    }

    function setNotRevealedURI(string memory newNotRevealedURI) public onlyOwner {
        notRevealedURI = newNotRevealedURI;
    }
    
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
  }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
  }

    //******TOGGLE FUNCTIONS******

    function togglePublicSale() public onlyOwner{
        IS_PUBLIC_SALE_ACTIVE = !IS_PUBLIC_SALE_ACTIVE;
    }

    function togglePreSale() public onlyOwner{
        IS_PRE_SALE_ACTIVE = !IS_PRE_SALE_ACTIVE;
    }

    function _currentMint() public view returns(uint256){
        return currentMint;
    }

    
    
    //*******INFO FUNCTIONS*******
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



    function mintCountById(address _address) public view returns (uint) {
        return mintCount[_address];
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    //*******SET WALLET FUNCTIONS*******     
    
    
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
    


    //*******MINT FUNCTIONS******* 

    
    
    function presaleMint(uint256 _mintAmount) public payable {
        require (IS_PRE_SALE_ACTIVE, "Presale is not active yet");
        require (isWhitelisted(msg.sender), "You are not whitelisted");
        require(currentMint + _mintAmount <= maxSupply, "Max NFT limit exceeded");
        require (mintCount[msg.sender] < nftPerAddressLimitPresale, "You have max amount of NFTs.");
        uint256 totalprice = _mintAmount*pricePrivate;
        require(msg.value >= totalprice, "Balance is not enough");
        require (_mintAmount < nftPerAddressLimitPresale, "Amount exceeds max amount."); 
        require(_mintAmount > 0, "Mint amount should be at least 1");
        for(uint i=0; i<_mintAmount; i++){
            if(isWhitelisted(msg.sender)){
                
                _safeMint(msg.sender, currentMint + i);
            mintCount[msg.sender]++;
            }
            currentMint = currentMint + _mintAmount;
        }
    }
    

    function freemint() public payable {
        if(isfreeMinter(msg.sender)==true){
            require(IS_PRE_SALE_ACTIVE, "Free Mint is not active yet.");
            require(freemintCount[msg.sender] < 1, "You have already free minted.");
            _safeMint(msg.sender, currentMint);
            freemintCount[msg.sender] +=1;
            currentMint = currentMint+=1;   
        }
    }
    
    
    function publicsaleMint(uint256 _mintAmount) public payable {
        require (IS_PUBLIC_SALE_ACTIVE, "Public sale is not active yet");
        require(currentMint + _mintAmount <= maxSupply, "Max NFT limit exceeded");
        require (mintCount[msg.sender] < nftPerAddressLimitPublic, "You have max  of NFTs.");
        uint256 totalprice = _mintAmount*price;
        require(msg.value >= totalprice, "Balance is not enough");
        require (_mintAmount < nftPerAddressLimitPublic, "Amount exceeds max amount."); 
        require(_mintAmount > 0, "Mint amount should be at least 1");
        require(_mintAmount <= nftPerTXLimit, "You cannot mint more than 20 in one TX");
        for(uint i=0; i<_mintAmount; i++){
            _safeMint(msg.sender, currentMint + i);
            mintCount[msg.sender]++;
        }
        currentMint = currentMint + _mintAmount;
}

    //*******OWNER MINT*******
    
    function ownerMint(uint256 _mintAmount) public onlyOwner {
        require(currentMint + _mintAmount <= maxSupply, "Max NFT limit exceeded"); 
        require(_mintAmount >= 0, "Mint amount should be at least 1");
        for(uint i=0; i<_mintAmount; i++){
            _safeMint(msg.sender, currentMint + i);
            adminMintCount[msg.sender]++;
        
    }
        currentMint = currentMint + _mintAmount;
}

    //*******WHITELIST FUNCTIONS*******   
    function addwhitelistUsers(address[] calldata _users) public onlyOwner {
        delete whitelistedAddresses;
        whitelistedAddresses = _users;
}

    function addFreeMintUsers(address[] calldata _users) public onlyOwner {
        delete freeMintAddresses;
        freeMintAddresses = _users;
}

        
//whitelist = [""]
        
        
        //WITHDRAW FUNCTION
        
         
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