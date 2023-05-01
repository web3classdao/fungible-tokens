// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MTTTokenMint is ERC20 {
    
    uint256 private _maxSupply = 1000000;
    address private _owner;
   
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
 
    constructor() ERC20("My Test Token", "MTT") {
        _maxSupply = _maxSupply * (10 ** decimals());
        _owner = msg.sender;
    }

    function fund() public payable {
        // Add funder address and eth amount funded 
        require(msg.value >= MINIMUM_FUND, "The minimum fund is 0.001 ETH");
        _addressToAmountFunded[msg.sender] += msg.value;
        _funders.push(msg.sender);

        // Transfer the amount of token equivalent to funded eth
        uint256 tokenAmount = uint256(msg.value * EXCHANGE_RATE / 10 ** 18) * (10 ** decimals());
        require(tokenAmount + totalSupply() <= _maxSupply, "Not enough tokens");
        _mint(msg.sender, tokenAmount);

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

    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}