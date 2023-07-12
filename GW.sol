// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";



contract GW is ERC721URIStorage, Ownable{

    using Strings for uint256;

    string public baseURI;
    
    uint public currentMint = 1;
    uint internal price = 5 ether;
    uint internal supply = 3333;

    bool public IS_SALE_ACTIVE;

    address FOUNDER_1 = 0x171d53eC7358d52Cc511299E8f68c9F608509f4A;
    address[] minterAddresses;

    mapping(address => uint256) public mintCount;
    mapping(address => bool) public takenSnapshot;
    

    constructor() ERC721("Galactic Warriors" , "GW"){
}


    
    /*************************
    *                        * 
    *     *URI FUNCTIONS*    *
    *                        *
    **************************/

    function actualMint() public view returns(uint256 totalMint){
        return currentMint-1;
    }


    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }



    /*************************
    *                        * 
    *       *SNAPSHOT*       *
    *                        *
    **************************/

    
    function addSnapshotList(address minterAddress) internal{
        if(takenSnapshot[minterAddress]==false){
            minterAddresses.push(minterAddress);
            takenSnapshot[minterAddress]=true;
        }else{
        }
    }


    function printAddresses() public onlyOwner view returns(address[] memory _addresses){
            return(minterAddresses);
        }
    

    /*************************
    *                        * 
    *    *MINT FUNCTIONS*    *
    *                        *
    **************************/

    function toggleMint() public onlyOwner {
        IS_SALE_ACTIVE = !IS_SALE_ACTIVE;
    }
    
    
    function Mint() public payable {
        require(IS_SALE_ACTIVE==true, "Sale is not active yet");
        require(currentMint <= supply, "Max supply is exceeded");
        require(msg.value >= price, "Your balance is not enough");
        _safeMint(msg.sender,currentMint);
        _setTokenURI(currentMint, string(abi.encodePacked(currentMint.toString(), ".json")));
        currentMint+=1;
        mintCount[msg.sender]+=1;
        addSnapshotList(msg.sender);
    }


    function multipleMint(uint _amount) public payable {
        require(IS_SALE_ACTIVE==true, "Sale is not active yet");
        require(currentMint + _amount <= supply, "Max supply is exceeded");
        require(msg.value >= _amount*price, "Balance is not enough");
        require(_amount>=0, "Amount cannot be zero");
        for(uint i=0;i<_amount;i++){
            _safeMint(msg.sender, currentMint);
            mintCount[msg.sender]+=1;
            _setTokenURI(currentMint, string(abi.encodePacked(currentMint.toString(), ".json")));
            currentMint+=1;
        }
        addSnapshotList(msg.sender);
    }



    /*************************
    *                        * 
    *       *WITHDRAW*       *
    *                        *
    **************************/
        
         
       function _withdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Transfer failed.");
}
        
        
        function withdrawAll() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0);

        _withdraw(FOUNDER_1, (balance));
 
        
}

}



