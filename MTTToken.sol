// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MTTToken is ERC20 {

    // Check the minting was done
    bool private _minted;
    
    constructor() ERC20("My Test Token", "MTT") {
        _minted = false;
    }

    function mintToken(uint256 initialSupply) external {
        require(!_minted, "Already minted");
        // Mint all tokens to msg.sender (caller contract)
        _mint(msg.sender, initialSupply * (10 ** decimals()));
        // Set the minting is done
        _minted = true;
    }
}