// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Token is ERC20 {
    uint256 private initialSupply = 1000000;
    
    constructor() ERC20("My Test Token", "MTT") {
        _mint(msg.sender, initialSupply * (10 ** decimals()));
    }
}