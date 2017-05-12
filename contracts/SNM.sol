
pragma solidity ^0.4.11;


contract SNM  {

  address public ico;
  mapping (address => uint) balance;

  // Init with a reference to the ICO contract.
  function SNM(address _ico) {
    ico = _ico;
  }


  function balanceOf(address _holder) external returns (uint) {
    return balance[_holder];
  }

  // Mint few tokens and transefer them to some address.
  function mint(address _holder, uint _value) external {
    // TODO: check msg.sender
    // TODO: check totalSupply <= 222M
    balance[_holder] += _value;
  }
}
