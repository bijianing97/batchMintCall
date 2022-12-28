// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract FallBackTest {
    bytes public params = "hello word";

    receive() external payable {}

    fallback() external payable {
        params = msg.data;
    }
}
