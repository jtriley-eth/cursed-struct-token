// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/CursedStructToken.sol";

contract CursedStructTokenTest is Test {
    CursedStructToken token;

    function setUp() public {
        token = new CursedStructToken();
    }

    function invariantMetadata() public {
        assertEq(token.name(), "Cursed Struct Token");
        assertEq(token.symbol(), "CST");
        assertEq(token.decimals(), 18);
    }

    function testMint() public {
        token.mint(address(0xBEEF), 1e18);

        assertEq(token.totalSupply(), 1e18);
        assertEq(token.balanceOf(address(0xBEEF)), 1e18);
    }

    function testApprove() public {
        assertTrue(token.approve(address(0xBEEF), 1e18));

        assertEq(token.allowance(address(this), address(0xBEEF)), 1e18);
    }

    function testTransfer() public {
        token.mint(address(this), 1e18);

        assertTrue(token.transfer(address(0xBEEF), 1e18));
        assertEq(token.totalSupply(), 1e18);

        assertEq(token.balanceOf(address(this)), 0);
        assertEq(token.balanceOf(address(0xBEEF)), 1e18);
    }

    function testTransferFrom() public {
        address from = address(0xABCD);

        token.mint(from, 1e18);

        vm.prank(from);
        token.approve(address(this), 1e18);

        assertTrue(token.transferFrom(from, address(0xBEEF), 1e18));
        assertEq(token.totalSupply(), 1e18);

        assertEq(token.allowance(from, address(this)), 0);

        assertEq(token.balanceOf(from), 0);
        assertEq(token.balanceOf(address(0xBEEF)), 1e18);
    }

    function testInfiniteApproveTransferFrom() public {
        address from = address(0xABCD);

        token.mint(from, 1e18);

        vm.prank(from);
        token.approve(address(this), type(uint256).max);

        assertTrue(token.transferFrom(from, address(0xBEEF), 1e18));
        assertEq(token.totalSupply(), 1e18);

        assertEq(token.allowance(from, address(this)), type(uint256).max);

        assertEq(token.balanceOf(from), 0);
        assertEq(token.balanceOf(address(0xBEEF)), 1e18);
    }

    function testFailTransferInsufficientBalance() public {
        token.mint(address(this), 0.9e18);
        vm.expectRevert();
        token.transfer(address(0xBEEF), 1e18);
    }

    function testFailTransferFromInsufficientAllowance() public {
        address from = address(0xABCD);

        token.mint(from, 1e18);

        vm.prank(from);
        token.approve(address(this), 0.9e18);

        vm.expectRevert();
        token.transferFrom(from, address(0xBEEF), 1e18);
    }

    function testFailTransferFromInsufficientBalance() public {
        address from = address(0xABCD);

        token.mint(from, 0.9e18);

        vm.prank(from);
        token.approve(address(this), 1e18);

        vm.expectRevert();
        token.transferFrom(from, address(0xBEEF), 1e18);
    }

    function testMint(address from, uint256 amount) public {
        token.mint(from, amount);

        assertEq(token.totalSupply(), amount);
        assertEq(token.balanceOf(from), amount);
    }

    function testApprove(address to, uint256 amount) public {
        assertTrue(token.approve(to, amount));

        assertEq(token.allowance(address(this), to), amount);
    }

    function testTransfer(address from, uint256 amount) public {
        token.mint(address(this), amount);

        assertTrue(token.transfer(from, amount));
        assertEq(token.totalSupply(), amount);

        if (address(this) == from) {
            assertEq(token.balanceOf(address(this)), amount);
        } else {
            assertEq(token.balanceOf(address(this)), 0);
            assertEq(token.balanceOf(from), amount);
        }
    }

    function testTransferFrom(
        address to,
        uint256 approval,
        uint256 amount
    ) public {
        amount = bound(amount, 0, approval);

        address from = address(0xABCD);

        token.mint(from, amount);

        vm.prank(from);
        token.approve(address(this), approval);

        assertTrue(token.transferFrom(from, to, amount));
        assertEq(token.totalSupply(), amount);

        uint256 app = from == address(this) || approval == type(uint256).max ? approval : approval - amount;
        assertEq(token.allowance(from, address(this)), app);

        if (from == to) {
            assertEq(token.balanceOf(from), amount);
        } else {
            assertEq(token.balanceOf(from), 0);
            assertEq(token.balanceOf(to), amount);
        }
    }

    function testFailTransferInsufficientBalance(
        address to,
        uint256 mintAmount,
        uint256 sendAmount
    ) public {
        sendAmount = bound(sendAmount, mintAmount + 1, type(uint256).max);

        token.mint(address(this), mintAmount);
        vm.expectRevert();
        token.transfer(to, sendAmount);
    }

    function testFailTransferFromInsufficientAllowance(
        address to,
        uint256 approval,
        uint256 amount
    ) public {
        amount = bound(amount, approval + 1, type(uint256).max);

        address from = address(0xABCD);

        token.mint(from, amount);

        vm.prank(from);
        token.approve(address(this), approval);

        vm.expectRevert();
        token.transferFrom(from, to, amount);
    }

    function testFailTransferFromInsufficientBalance(
        address to,
        uint256 mintAmount,
        uint256 sendAmount
    ) public {
        sendAmount = bound(sendAmount, mintAmount + 1, type(uint256).max);

        address from = address(0xABCD);

        token.mint(from, mintAmount);

        vm.prank(from);
        token.approve(address(this), sendAmount);

        vm.expectRevert();
        token.transferFrom(from, to, sendAmount);
    }
}
