//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract Token {
    
    string public name = "KAIST Hardhat Token";
    string public symbol = "KHT";

    uint256 public totalSupply = 1000000;

	// The address of contract owner
    address public owner;

    // Store each account's balance.
    mapping(address => uint256) balances;

    // Event when token transfer happens
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    constructor() {
        // The totalSupply is assigned to the transaction sender, which is the
        // account that is deploying the contract.
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function transfer(address to, uint256 amount) external {
        // Check if the transaction sender has enough tokens.
        require(balances[msg.sender] >= amount, "Not enough tokens");

        console.log(
            "Transferring from %s to %s %s tokens",
            msg.sender,
            to,
            amount
        );

        // Transfer the amount.
        balances[msg.sender] -= amount;
        balances[to] += amount;

        // Notify the transfer.
        emit Transfer(msg.sender, to, amount);
    }

    // retrieve the token balance of a given account.
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}
