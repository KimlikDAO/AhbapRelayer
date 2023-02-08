// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
}

contract MockERC20 is IERC20 {
    uint8 public immutable decimals;

    string public name;
    string public symbol;
    uint256 public totalSupply;
    mapping(address => uint256) public override balanceOf;

    constructor(
        string memory tokenSymbol,
        string memory tokenName,
        uint8 tokenDecimals
    ) {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimals;
        uint256 toMint = 100 * 10**decimals;
        balanceOf[msg.sender] = toMint;
        totalSupply = toMint;
    }

    function transfer(address to, uint256 amount)
        external
        override
        returns (bool)
    {
        balanceOf[msg.sender] -= amount;
        unchecked {
            balanceOf[to] += amount;
        }
        return true;
    }

    function mint(uint256 amount) external {
        balanceOf[msg.sender] += amount;
    }
}
