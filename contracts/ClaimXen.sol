// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface Xen {
    function claimRank(uint256 term) external;

    function claimMintReward() external;

    function approve(address spender, uint256 amount) external returns (bool);
}

interface Token {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract Get {
    Xen private constant xen = Xen(0x06450dEe7FD2Fb8E39061434BAbCFC05599a6Fb8);

    constructor() {
        xen.approve(msg.sender, ~uint256(0));
    }

    function claimRank(uint256 term) external {
        xen.claimRank(term);
    }

    function claimMintReward() external {
        xen.claimMintReward();
        selfdestruct(payable(tx.origin));
    }
}

contract GetXen {
    mapping(address => mapping(uint256 => address[])) public uesrContracts;
    Token private constant xen =
        Token(0x06450dEe7FD2Fb8E39061434BAbCFC05599a6Fb8);

    function claimRank(uint256 times, uint256 term) external {
        address user = tx.origin;
        for (uint256 i; i < times; ++i) {
            Get get = new Get();
            get.claimRank(term);
            uesrContracts[user][term].push(address(get));
        }
    }

    function claimMintedReward(uint256 times, uint256 term) external {
        address user = tx.origin;
        for (uint256 i; i < times; ++i) {
            uint256 count = uesrContracts[user][term].length;
            address get = uesrContracts[user][term][count - 1];
            Get(get).claimMintReward();
            address owner = tx.origin;
            uint256 balance = xen.balanceOf(owner);
            xen.transferFrom(get, owner, balance);
            uesrContracts[user][term].pop();
        }
    }
}
