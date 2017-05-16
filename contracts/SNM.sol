
pragma solidity ^0.4.11;

import "../installed_contracts/token/StandardToken.sol";

contract SNM  is StandardToken {

  // Constants
  // =========

  string public name = "SONM Token";
  string public symbol = "SNM";
  uint public decimals = 18;
  uint constant TOKEN_LIMIT = 222 * 1e6 * 1e18;


  // State variables
  // ===============

  address public ico;


  // Constructor
  // ===========

  function SNM(address _ico) {
    ico = _ico;
  }


  // Priveleged functions
  // ====================


  // Mint few tokens and transefer them to some address.
  function mint(address _holder, uint _value) external {
    if(msg.sender != ico) throw;
    if(_value == 0 || totalSupply + _value > TOKEN_LIMIT) throw;

    balances[_holder] += _value;
    totalSupply += _value;
    Transfer(0x0, _holder, _value);
  }
}
