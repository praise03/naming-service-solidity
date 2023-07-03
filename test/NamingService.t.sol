// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Counter.sol";

contract CounterScript is Test {
    MyToken token;
    address one = vm.addr(0x1);
    address two = vm.addr(0x2);

    function setUp() public {
        token = new MyToken("KillToken", "KTN");
    }

    function testName() external {
        assertEq("KillToken", token.name());
    }
}
