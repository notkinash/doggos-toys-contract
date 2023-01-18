// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Toys is ERC721ABurnable, ERC721AQueryable, Ownable, ReentrancyGuard {
    uint256 public mintPrice = 1.5 ether;

    // Limits

    uint8 public collectionSize = 100;

    uint8 public maxPerWallet = 2;

    // Control

    bool public mintAvailable = false;

    string private _defaultBaseURI = "";

    mapping(address => bool) public whitelist;

    constructor() ERC721A("Doggos Toys", "TOYS") {}

    // Mint functions

    function mint(uint256 quantity) external payable {
        // Check if mint is available
        require(mintAvailable, "Mint isn't available yet");

        // Check if minter is whitelisted
        require(isWhitelisted(msg.sender), "Not whitelisted");
        
        // Check if there is enough tokens available
        uint256 nextTotalMinted = _totalMinted() + quantity;
        require(nextTotalMinted <= collectionSize, "Sold out");
        
        // Check if balance + quantity <= 2
        uint256 amount = balanceOf(msg.sender) + quantity;
        require(amount <= maxPerWallet, "You can only mint 2");

        // Check if minter is paying the correct price
        uint256 price = quantity * mintPrice;
        require(msg.value >= price, "Invalid price");
        
        _mint(msg.sender, quantity);
    }

    function give(address to, uint256 quantity) external onlyOwner {
        // Check if there is enough tokens available
        uint256 nextTotalMinted = _totalMinted() + quantity;
        require(nextTotalMinted <= collectionSize, "Sold out");

        _mint(to, quantity);
    }

    // Whitelist functions

    function isWhitelisted(address target) public view returns (bool) {
        return whitelist[target];
    }

    function whitelistAdd(address target) external onlyOwner {
        whitelist[target] = true;
    }

    function multiWhitelistAdd(address[] calldata targets) external onlyOwner {
        for (uint256 i = 0; i < targets.length; i++) {
            whitelist[targets[i]] = true;
        }
    }

    function whitelistRemove(address target) external onlyOwner {
        whitelist[target] = false;
    }

    // Control functions

    function toggleMint() external onlyOwner {
        mintAvailable = !mintAvailable;
    }

    function setMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
    }

    function setCollectionSize(uint8 newSize) external onlyOwner {
        collectionSize = newSize;
    }

    function setMaxPerWallet(uint8 newMax) external onlyOwner {
        maxPerWallet = newMax;
    }

    function setBaseURI(string calldata newURI) external onlyOwner {
        _defaultBaseURI = newURI;
    }

    // Special functions

    function withdraw() external onlyOwner nonReentrant {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }

    // Override functions

    function tokenURI(uint256 tokenId) public view override(ERC721A, IERC721A) returns (string memory) {
        return string(abi.encodePacked(_defaultBaseURI, _toString(tokenId), ".json"));
    }
}