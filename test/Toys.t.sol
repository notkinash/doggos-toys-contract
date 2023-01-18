// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Toys.sol";

contract ToysTest is Test {
    Toys public toys;

    function setUp() public {
        toys = new Toys();
        toys.toggleMint();
    }

    function _addToWhitelist(address target) private {
        address owner = toys.owner();
        vm.prank(owner);
        toys.whitelistAdd(target);
    }

    function _removeFromWhitelist(address target) private {
        address owner = toys.owner();
        vm.prank(owner);
        toys.whitelistRemove(target);
    }

    function testMint1() public {
        _addToWhitelist(msg.sender);
        //
        uint256 quantity = 1;
        uint256 price = quantity * toys.mintPrice();
        //
        vm.prank(msg.sender);
        toys.mint{value: price}(quantity);
        //
        assertEq(toys.balanceOf(msg.sender), quantity);
    }

    function testMint2() public {
        _addToWhitelist(msg.sender);
        //
        uint256 quantity = 2;
        uint256 price = quantity * toys.mintPrice();
        //
        vm.prank(msg.sender);
        toys.mint{value: price}(quantity);
        //
        assertEq(toys.balanceOf(msg.sender), quantity);
    }

    function testFailMint3() public {
        _addToWhitelist(msg.sender);
        //
        uint256 quantity = 3;
        uint256 price = quantity * toys.mintPrice();
        //
        vm.prank(msg.sender);
        toys.mint{value: price}(quantity);
        //
        assertEq(toys.balanceOf(msg.sender), quantity);
    }

    function testMint100() public {
        address currentAddress = address(0);
        uint256 quantity = 2;
        uint256 price = quantity * toys.mintPrice();

        for (uint160 i = 0; i < 50; i++) {
            currentAddress = address(0xfcfd + i);
            _addToWhitelist(currentAddress);
            //
            vm.deal(currentAddress, 4 ether);
            vm.prank(currentAddress);
            //
            toys.mint{value: price}(quantity);
        }

        assertEq(toys.totalSupply(), 100);
    }

    function testFailMint102() public {
        address currentAddress = address(0);
        uint256 quantity = 2;
        uint256 price = quantity * toys.mintPrice();

        for (uint160 i = 0; i < 50; i++) {
            currentAddress = address(0xfcfd + i);
            _addToWhitelist(currentAddress);
            //
            vm.deal(currentAddress, 4 ether);
            vm.prank(currentAddress);
            //
            toys.mint{value: price}(quantity);
        }

        toys.mint{value: price}(quantity);

        assertEq(toys.totalSupply(), 100);
    }

    function testAddWhitelist() public {
        _addToWhitelist(msg.sender);
        assertEq(toys.isWhitelisted(msg.sender), true);
    }

    function testMultiAddWhitelist() public {
        address[] memory addresses = new address[](50);
        for (uint160 i = 0; i < 50; i++) {
            addresses[i] = (address(0xfcfd + i));
        }

        vm.prank(toys.owner());
        toys.multiWhitelistAdd(addresses);

        assertEq(toys.isWhitelisted(addresses[49]), true);
    }

    function testRemoveWhitelist() public {
        _addToWhitelist(msg.sender);
        _removeFromWhitelist(msg.sender);
        assertEq(toys.isWhitelisted(msg.sender), false);
    }

    function testFailCheckNonWhitelistedAddress() public {
        assertEq(toys.isWhitelisted(msg.sender), true);
    }

    function testWithdraw() public {
        uint256 quantity = 2;
        uint256 price = quantity * toys.mintPrice();

        _addToWhitelist(msg.sender);
        
        vm.prank(msg.sender);
        toys.mint{value: price}(quantity);

        address(toys).balance;

        vm.prank(toys.owner());
        toys.transferOwnership(msg.sender);

        vm.prank(msg.sender);
        toys.withdraw();

        assertEq(address(toys).balance, 0);
    }

    function testTokenURI() public {
        assertEq(toys.tokenURI(1), "1.json");

        vm.prank(toys.owner());
        toys.setBaseURI("ipfs://Qmd6dVF1F5tjdRsF9SDf7DcLGcWzcy7DNV2jG8yQV3rNVL/");

        assertEq(toys.tokenURI(1), "ipfs://Qmd6dVF1F5tjdRsF9SDf7DcLGcWzcy7DNV2jG8yQV3rNVL/1.json");
    }

    function testMaxPerWallet() public {
        vm.prank(toys.owner());
        toys.setMaxPerWallet(5);

        assertEq(toys.maxPerWallet(), 5);
    }

    function testCollectionSize() public {
        vm.prank(toys.owner());
        toys.setCollectionSize(250);

        assertEq(toys.collectionSize(), 250);
    }

    function testMintPrice() public {
        vm.prank(toys.owner());
        toys.setMintPrice(3 ether);

        assertEq(toys.mintPrice(), 3 ether);
    }
}