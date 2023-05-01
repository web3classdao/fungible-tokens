//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract Token {
    
    string public name = "My Test Token";
    string public symbol = "MTT";

    uint256 public totalSupply = 1000000;

	// The address of contract owner
    address public owner;

    // Store each account's balance.
    mapping(address => uint256) balances;

    // Store each funder's amount funded and address. 
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    uint256 public constant MINIMUM_FUND = 0.001 * 10 ** 18;     // 0.001 ETH
    uint256 public constant EXCHANGE_RATE = 1000;                // 1 ETH = 1000 MTT

    // Event when token transfer happens
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Funding(address indexed _from, uint256 _value);
    event Withdraw(address indexed _from, uint256 _value);

    modifier onlyOwner {
        require(msg.sender == owner, "You're not the owner");
        _;
    }
    
    constructor() {
        // The totalSupply is assigned to the transaction sender, which is the
        // account that is deploying the contract.
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function fund() public payable {
        // Add funder address and eth amount funded 
        require(msg.value >= MINIMUM_FUND, "The minimum fund is 0.001 ETH");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);

        // Transfer the amount of token equivalent to funded eth
        uint256 tokenAmount = getTokenAmountInETH(msg.value);
        require(balances[owner] >= tokenAmount, "We don't have enough tokens");
        balances[owner] -= tokenAmount;
        balances[msg.sender] += tokenAmount;

        console.log(
            "Funding %s wei from %s and transfering %s tokens",
            msg.value,
            msg.sender,
            tokenAmount
        );

        // Notify the funding.
        emit Funding(msg.sender, msg.value);
    }

    function getTokenAmountInETH(uint256 ethAmount) internal pure returns (uint256) {
        return uint256(ethAmount * EXCHANGE_RATE / 10 ** 18);
    } 

    function withdraw() public onlyOwner {
        // Reset funders' data
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        uint256 ethAmount = address(this).balance;
        (bool callSuccess, ) = payable(msg.sender).call{value: ethAmount}("");
        require(callSuccess, "Withdraw Call failed");

        // Notify the withdraw.
        emit Funding(msg.sender, ethAmount);
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

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}
