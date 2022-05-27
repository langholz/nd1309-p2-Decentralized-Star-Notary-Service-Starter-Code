pragma solidity >=0.4.24;

//Importing openzeppelin-solidity ERC-721 implemented Standard
import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

// StarNotary Contract declaration inheritance the ERC721 openzeppelin implementation
contract StarNotary is ERC721 {

    // Star data
    struct Star {
        string name;
    }

    // mapping the Star with the Owner Address
    mapping(uint256 => Star) public tokenIdToStarInfo;
    // mapping the TokenId and price
    mapping(uint256 => uint256) public starsForSale;

    // Implement Task 1 Add a name and symbol properties
    // name: Is a short name to your token
    // symbol: Is a short string like 'USD' -> 'American Dollar'
    string private _name;
    string private _symbol;

    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    // Create Star using the Struct
    function createStar(string memory starName, uint256 tokenId) public { // Passing the name and tokenId as a parameters
        Star memory newStar = Star(starName); // Star is an struct so we are creating a new Star
        tokenIdToStarInfo[tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, tokenId); // _mint assign the the star with tokenId to the sender address (ownership)
    }

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "You can't sale the Star you don't owned");
        starsForSale[tokenId] = price;
    }

    // Function that allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }

    function buyStar(uint256 tokenId) public payable {
        require(starsForSale[tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[tokenId];
        address ownerAddress = ownerOf(tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        _transferFrom(ownerAddress, msg.sender, tokenId); // We can't use _addTokenTo or_removeTokenFrom functions, now we have to use _transferFrom
        address payable ownerAddressPayable = _make_payable(ownerAddress); // We need to make this conversion to be able to use transfer() function to transfer ethers
        ownerAddressPayable.transfer(starCost);
        if (msg.value > starCost) {
            msg.sender.transfer(msg.value - starCost);
        }
    }

    // Implement Task 1 lookUpTokenIdToStarInfo
    function lookUpTokenIdToStarInfo(uint256 tokenId) public view returns (string memory) {
        //1. You should return the Star saved in tokenIdToStarInfo mapping
        require(_exists(tokenId), "Token does not exist");
        return tokenIdToStarInfo[tokenId].name;
    }

    // Implement Task 1 Exchange Stars function
    function exchangeStars(uint256 tokenId1, uint256 tokenId2) public {
        //1. Passing to star tokenId you will need to check if the owner of tokenId1 or tokenId2 is the sender
        //2. You don't have to check for the price of the token (star)
        //3. Get the owner of the two tokens (ownerOf(tokenId1), ownerOf(tokenId2)
        //4. Use _transferFrom function to exchange the tokens.
        require(_exists(tokenId1), "Token 1 does not exist");
        require(_exists(tokenId2), "Token 2 does not exist");
        address ownerToken1 = ownerOf(tokenId1);
        address ownerToken2 = ownerOf(tokenId2);
        require(ownerToken1 == msg.sender || ownerToken2 == msg.sender, "You can't exchange a star you don't own");
        _transferFrom(ownerToken1, ownerToken2, tokenId1);
        _transferFrom(ownerToken2, ownerToken1, tokenId2);
    }

    // Implement Task 1 Transfer Stars
    function transferStar(address to, uint256 tokenId) public {
        //1. Check if the sender is the ownerOf(tokenId)
        //2. Use the transferFrom(from, to, tokenId); function to transfer the Star
        require(_exists(tokenId), "Token does not exist");
        address ownerAddress = ownerOf(tokenId);
        require(ownerAddress == msg.sender, "You can't transfer a star you don't own");
        transferFrom(msg.sender, to, tokenId);
    }
}
