
pragma solidity ^0.4.11;


contract SNM  {

  // Constants
  // =========

  uint constant TOKEN_LIMIT = 222 * 1e6 * 1e18;


  // State variables
  // ===============

  address public ico;
  mapping (address => uint) balance;
  uint public totalSupply;


  // Constructor
  // ===========

  function SNM(address _ico) {
    ico = _ico;
  }


  // Public functions
  // ================

  function balanceOf(address _holder) external returns (uint) {
    return balance[_holder];
  }


  // Priveleged functions
  // ====================


  // Mint few tokens and transefer them to some address.
  function mint(address _holder, uint _value) external {
    if(msg.sender != ico) throw;
    if(_value == 0 || totalSupply + _value > TOKEN_LIMIT) throw;

    balance[_holder] += _value;
    totalSupply += _value;

    // TODO: Transfer event
  }
}
