// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Test {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function test() public {
        require(msg.sender == owner, "Only owner can call this function");
        selfdestruct(payable(tx.origin));
    }
}

contract DD {
    address public owner;
    Test public test;

    constructor() {
        owner = msg.sender;
    }

    function createTest() public {
        require(msg.sender == owner, "Only owner can call this function");
        test = new Test{salt: bytes32(uint256(1))}();
    }

    function deleteTest() public {
        require(msg.sender == owner, "Only owner can call this function");
        test.test();
    }
}
