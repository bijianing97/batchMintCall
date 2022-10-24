// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface airdrop {
    function transfer(address recipent, uint256 amount) external;

    function claim() external;

    function balanceOf(address account) external view returns (uint256);
}

contract multiCall2 {
    address constant rnd = (0x517E6BD7E7B837B839De770EA5e62D049cD2ebdA);

    function startClaim(uint256 times) external {
        for (uint256 i = 0; i < times; i++) {
            new claimer(rnd);
        }
    }
}

contract claimer {
    constructor(address _airdrop) {
        airdrop(_airdrop).claim();
        uint256 balance = airdrop(_airdrop).balanceOf(address(this));
        airdrop(_airdrop).transfer(tx.origin, balance);
        selfdestruct(payable(tx.origin));
    }
}
