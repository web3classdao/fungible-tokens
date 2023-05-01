//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./MTTToken.sol";

contract MTTTokenFund {

    address private _owner;
    uint256 private _initialSupply = 1000000;
    // token contract variable of Type MTTToken
    MTTToken private _token;

    // Store each funder's amount funded and address. 
    mapping(address => uint256) private _addressToAmountFunded;
    address[] private _funders;
    uint256 public constant MINIMUM_FUND = 0.001 * 10 ** 18;     // 0.001 ETH
    uint256 public constant EXCHANGE_RATE = 1000;                // 1 ETH = 1000 MTT

    // Events
    event Funding(address indexed _from, uint256 _value, uint256 _tvalue);
    event Withdraw(address indexed _from, uint256 _value);

    modifier onlyOwner {
        require(msg.sender == _owner, "You're not the owner");
        _;
    }

    constructor(address tokenAddress) {
        // Initialize _token with the address of the MTTToken deployed previously.
        _token = MTTToken(tokenAddress);
        // Mint all tokens to this contract (caller contract)
        // This contract will hold all tokens
        _token.mintToken(_initialSupply);
        _owner = msg.sender;
    }

    function fund() public payable {
        // Add funder address and eth amount funded 
        require(msg.value >= MINIMUM_FUND, "The minimum fund is 0.001 ETH");
        _addressToAmountFunded[msg.sender] += msg.value;
        _funders.push(msg.sender);

        // Calculate the amount of token equivalent to funded eth
        uint256 tokenAmount = uint256(msg.value * EXCHANGE_RATE / 10 ** 18);
        tokenAmount *= (10 ** _token.decimals());

        // Call the MTTToken contract to send tokens to msg.sender
        // When transfer() in the MTTToken contract is called, 
        // msg.sender will be this contract (caller contract) 
        // Then, tokens will be transfered from this contract address
        bool success = _token.transfer(msg.sender, tokenAmount);
        if (!success) {
            revert("Token transfer failed");
        }

        // Notify the funding.
        emit Funding(msg.sender, msg.value, tokenAmount);
    }

    function withdraw() public onlyOwner {
        // Reset funders' data
        for (uint256 funderIndex=0; funderIndex < _funders.length; funderIndex++){
            address funder = _funders[funderIndex];
            _addressToAmountFunded[funder] = 0;
        }
        _funders = new address[](0);

        uint256 ethAmount = address(this).balance;
        (bool callSuccess, ) = payable(msg.sender).call{value: ethAmount}("");
        require(callSuccess, "Withdraw Call failed");

        // Notify the withdraw.
        emit Withdraw(msg.sender, ethAmount);
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}