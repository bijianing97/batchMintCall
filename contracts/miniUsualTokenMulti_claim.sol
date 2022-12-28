// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// 调用方式为 BatcherV2 调用 excute函数，调用proxy的callback函数，callback delegatecall BatcherV2的callback函数
contract BatcherV2 {
    bytes public miniProxy; // = 0x363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3;
    address private immutable owner;
    address private immutable deployer;
    uint256 public counter;

    constructor() {
        miniProxy = bytes.concat(
            bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73),
            bytes20(address(this)),
            bytes15(0x5af43d82803e903d91602b57fd5bf3)
        );
        owner = address(this);
        deployer = msg.sender;
    }

    function createProxy(uint256 _n) internal {
        bytes memory bytecode = miniProxy;
        uint256 start = counter;
        address proxy;
        for (uint256 i = 0; i < _n; i++) {
            bytes32 salt = keccak256(abi.encodePacked(msg.sender, start + i));
            assembly {
                proxy := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
            }
        }
        counter = start + _n;
    }

    function callback(address target, bytes memory data) external {
        require(msg.sender == owner, "Only owner can call this function");
        (bool success, ) = target.call(data);
        require(success, "Transaction failed");
    }

    function increase(uint256 _n) external {
        require(msg.sender == deployer, "Only deployer can call this function");
        createProxy(_n);
        counter += _n;
    }

    function getProxyAddress(
        address sender,
        uint _n
    ) public view returns (address proxy) {
        bytes32 salt = keccak256(abi.encodePacked(sender, _n));
        proxy = address(
            uint160(
                uint(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            address(this),
                            salt,
                            keccak256(abi.encodePacked(miniProxy))
                        )
                    )
                )
            )
        );
    }

    function excuete(
        uint256 start,
        uint256 count,
        address target,
        bytes memory data
    ) public {
        require(msg.sender == deployer, "Only deployer can call this function");
        for (uint256 i = start; i < count + start; i++) {
            address proxy = getProxyAddress(msg.sender, i);
            BatcherV2(proxy).callback(target, data);
        }
    }
}

contract BatchClaimXEN {
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1167.md
    bytes miniProxy; // = 0x363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3;
    address private immutable original;
    //address private constant XEN = 0x4DE35392c51885e88bCeF722A5DE8ab200628254;
    address private constant XEN = 0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e;
    mapping(address => uint) public countClaimRank;
    mapping(address => uint) public countClaimMint;

    constructor() {
        miniProxy = bytes.concat(
            bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73),
            bytes20(address(this)),
            bytes15(0x5af43d82803e903d91602b57fd5bf3)
        );
        original = address(this);
    }

    function batchClaimRank(uint times, uint term) external {
        bytes memory bytecode = miniProxy;
        address proxy;
        uint N = countClaimRank[msg.sender];
        for (uint i = N; i < N + times; i++) {
            bytes32 salt = keccak256(abi.encodePacked(msg.sender, i));
            assembly {
                proxy := create2(0, add(bytecode, 32), mload(bytecode), salt)
            }
            BatchClaimXEN(proxy).claimRank(term);
        }
        countClaimRank[msg.sender] = N + times;
    }

    function claimRank(uint term) external {
        IXEN(XEN).claimRank(term);
    }

    function proxyFor(
        address sender,
        uint i
    ) public view returns (address proxy) {
        bytes32 salt = keccak256(abi.encodePacked(sender, i));
        proxy = address(
            uint160(
                uint(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            address(this),
                            salt,
                            keccak256(abi.encodePacked(miniProxy))
                        )
                    )
                )
            )
        );
    }

    function batchClaimMintReward(uint times) external {
        uint M = countClaimMint[msg.sender];
        uint N = countClaimRank[msg.sender];
        N = M + times < N ? M + times : N;
        for (uint i = M; i < N; i++) {
            address proxy = proxyFor(msg.sender, i);
            BatchClaimXEN(proxy).claimMintRewardTo(msg.sender);
        }
        countClaimMint[msg.sender] = N;
    }

    function claimMintRewardTo(address to) external {
        IXEN(XEN).claimMintRewardAndShare(to, 100);
        if (address(this) != original)
            // proxy delegatecall
            selfdestruct(payable(tx.origin));
    }
}

interface IXEN {
    function claimRank(uint term) external;

    function claimMintReward() external;

    function claimMintRewardAndShare(address other, uint256 pct) external;

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}
