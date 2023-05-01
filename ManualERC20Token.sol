// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ManualERC20Token is IERC20 {
  // the token information
  string private _name;
  string private _symbol;
  uint8 private _decimals = 18;
  // 18 decimals is the strongly suggested default, avoid changing it
  uint256 private _totalSupply;

  // This creates an array with all balances
  mapping(address => uint256) private _balances;

  // This creates an array of mapping of the addresses authorized to spend 
  //                                 and the max amount they can spend
  mapping(address => mapping(address => uint256)) private _allowances;

  // This notifies clients about the amount burnt
  event Burn(address indexed from, uint256 value);

  // Initializes contract with initial supply tokens to the creator of the contract
  constructor(uint256 initialSupply, string memory tokenName, string memory tokenSymbol) {
    // Update total supply with the decimal amount
    _totalSupply = initialSupply * 10**uint256(_decimals); 

    // Give the creator all initial tokens
    _balances[msg.sender] = _totalSupply; 
    _name = tokenName; 
    _symbol = tokenSymbol; 
  }

  function name() public view returns (string memory) {
    return _name;
  }

  function symbol() public view returns (string memory) {
    return _symbol;
  }

  function decimals() public view returns (uint8) {
    return _decimals;
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  /**
   * Internal transfer, only can be called by this contract
   */
  function _transfer(address _from, address _to, uint256 _value) internal {
    // Prevent transfer to 0x0 address. Use burn() instead
    require(_to != address(0x0));
    // Check if the sender has enough
    require(_balances[_from] >= _value);
    // Check for overflows
    require(_balances[_to] + _value >= _balances[_to]);
    // Save this for an assertion in the future
    uint256 previousBalances = _balances[_from] + _balances[_to];
    // Subtract from the sender
    _balances[_from] -= _value;
    // Add the same to the recipient
    _balances[_to] += _value;
    emit Transfer(_from, _to, _value);
    // Asserts are used to use static analysis to find bugs in your code. They should never fail
    assert(_balances[_from] + _balances[_to] == previousBalances);
  }

  /**
   * Transfer tokens
   *
   * Send `_value` tokens to `_to` from your account
   *
   * @param _to The address of the recipient
   * @param _value the amount to send
   */
  function transfer(address _to, uint256 _value) public returns (bool success) {
    _transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * Set allowance for other address
   *
   * Allows `_spender` to spend no more than `_value` tokens on your behalf
   *
   * @param _spender The address authorized to spend
   * @param _value the max amount they can spend
   */
  function approve(address _spender, uint256 _value) public returns (bool success) {
    _allowances[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * Return the amount allowed to spend for _spender
   * @param _owner The account owner
   * @param _spender The address authorized to spend
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return _allowances[_owner][_spender];
  }

  /**
   * Transfer tokens from other address
   *
   * Send `_value` tokens to `_to` on behalf of `_from`
   *
   * @param _from The address of the sender
   * @param _to The address of the recipient
   * @param _value the amount to send
   */
  function transferFrom(address _from, address _to, uint256 _value) 
    public returns (bool success) {
    require(_value <= _allowances[_from][msg.sender]); // Check _allowances
    _allowances[_from][msg.sender] -= _value;
    _transfer(_from, _to, _value);
    return true;
  }

  /**
   * Destroy tokens
   *
   * Remove `_value` tokens from the system irreversibly
   *
   * @param _value the amount of money to burn
   */
  function burn(uint256 _value) public returns (bool success) {
    require(_balances[msg.sender] >= _value); // Check if the sender has enough
    _balances[msg.sender] -= _value; // Subtract from the sender
    _totalSupply -= _value; // Updates totalSupply
    emit Burn(msg.sender, _value);
    return true;
  }

  /**
   * Destroy tokens from other account
   *
   * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
   *
   * @param _from the address of the sender
   * @param _value the amount of money to burn
   */
  function burnFrom(address _from, uint256 _value) public returns (bool success) {
    require(_balances[_from] >= _value); // Check if the targeted balance is enough
    require(_value <= _allowances[_from][msg.sender]); // Check allowance
    _balances[_from] -= _value; // Subtract from the targeted balance
    _allowances[_from][msg.sender] -= _value; // Subtract from the sender's allowance
    _totalSupply -= _value; // Update totalSupply
    emit Burn(_from, _value);
    return true;
  }
}