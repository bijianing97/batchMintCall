// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface ERC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract Proxy {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function withdraw(address token) external onlyOwner {
        ERC20(token).transfer(owner, ERC20(token).balanceOf(address(this)));
    }

    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function execute(
        address target,
        bytes memory data
    ) public payable onlyOwner {
        (bool success, ) = target.call(data);
        require(success, "Transaction failed");
    }

    function destory(address payable recipient) public onlyOwner {
        selfdestruct(recipient);
    }
}

contract Batcher {
    address public owner;
    Proxy[] public proxies;

    constructor(uint256 _n) {
        owner = msg.sender;
        // Create proxies, we will not destroy them
        for (uint256 i = 0; i < _n; i++) {
            // create with slat
            Proxy proxy = new Proxy{salt: bytes32(uint256(i))}(address(this));
            proxies.push(proxy);
        }
    }

    function getBytecode() public view returns (bytes memory) {
        bytes memory bytecode = type(Proxy).creationCode;
        return abi.encodePacked(bytecode, abi.encode(msg.sender));
    }

    function getAddress(uint256 _salt) public view returns (address) {
        // Get a hash concatenating args passed to encodePacked
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(getBytecode())
            )
        );
        return address(uint160(uint256(hash)));
    }

    fallback() external payable {
        require(owner == msg.sender, "Only owner can call this function");
        // delegeatecall to proxy contracts
        for (uint256 i = 0; i < proxies.length; i++) {
            address proxy = address(proxies[i]);
            (bool success, ) = proxy.call(msg.data);
            require((success), "Transaction failed");
        }
    }

    receive() external payable {}
}
