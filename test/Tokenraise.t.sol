// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {THTokenRaiseFactory, THTokenRaise} from "contracts/TokenRaise.sol";
import {DeployHelper} from "test/DeployHelper.sol";
import "contracts/test/USDT.sol";
import "lib/forge-std/src/Test.sol";

contract TokenRaiseTest is Test, DeployHelper {
    uint256 price;

    TetherToken usdt;

    uint256 i;
    uint256 start_block;
    uint256 end_block;
    THTokenRaiseFactory factory;
    THTokenRaise tr;
    uint256 max_amount;
    address owner;

    function setUp() public {
        start_block = block.number;

        usdt = new TetherToken(0 ether, "Tether", "USDT", 6);

        usdt.issue(100000000000);
        vm.prank(account1.addr);
        usdt.issue(100000000000);

        factory = new THTokenRaiseFactory();
        tr = new THTokenRaise(
            start_block,
            start_block + 20,
            100000000,
            address(usdt),
            20000,
            payable(account8.addr)
        );

        usdt.approve(address(tr), 100000000000);
        vm.prank(account1.addr);
        usdt.approve(address(tr), 100000000000);
    }

    function test_THTokenRaise() public {
        //---------------raise
        tr.raise(60000000);
        vm.prank(account1.addr);
        tr.raise(15000000);
        uint256 b = usdt.balanceOf(account8.addr);
        assertEq(b, 75000000);

        (uint256 f0, uint256 f1) = tr.user_proportion(msg.sender);
        assertEq(f0, 125000000);
        assertEq(f1, 75000000);

        assertEq(tr.get_current_share(), 12000);
        assertEq(tr.get_current_price(), 625000000000000000);
        //---------------block
        for (i = 0; i < 20; i++) {
            usdt.transfer(msg.sender, 0);
        }
        vm.expectRevert("TokenRaise: raise end");
        tr.raise(10000000);
        tr.change_end_block(block.number + 5);
        vm.prank(msg.sender);
        tr.raise(45000000);

        assertEq(usdt.balanceOf(account8.addr), 120000000);
        (f0, f1) = tr.get_share_fraction();
        assertEq(f0, 1);
        assertEq(f1, 1);

        assertEq(tr.get_current_share(), 20000);

        assertEq(tr.get_current_price(), 600000000000000000);
    }
}