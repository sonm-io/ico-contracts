
pragma solidity ^0.4.11;

import "./PreICO.sol";
import "./SNM.sol";


contract ICO {

  // Constants
  // =========

  uint public constant TOKEN_PRICE = 606; // SNM per ETH
  uint public constant TOKENS_FOR_SALE = 165680000 * 1e18;


  // Events
  // ======

  event Withdraw(uint value);


  // State variables
  // ===============

  PreICO preICO;
  SNM public snm;

  address team;
  address tradeRobot;
  address bountyFund;
  address ecosystemFund;
  address teamFund;

  uint tokensSold = 0;


  // Constructor
  // ===========

  function ICO(address _preICO, address _team, address _tradeRobot) {
    snm = new SNM(this);
    preICO = PreICO(_preICO);
    team = _team;
    tradeRobot = _tradeRobot;
  }



  // Public functions
  // ================

  // Here you can buy some tokens (just don't forget to provide enough gas).
  function() payable {
    buy(msg.sender);
  }


  function buy(address _investor) payable {
    if(msg.value == 0) throw;

    uint _snmValue = msg.value * TOKEN_PRICE;
    uint _bonus = getBonus(_snmValue, tokensSold);
    uint _total = _snmValue + _bonus;

    if(tokensSold + _total > TOKENS_FOR_SALE) throw;

    snm.mint(_investor, _total);
    tokensSold += _total;
  }


  function migrate() {
    uint _sptBalance = preICO.balanceOf(msg.sender);
    if(_sptBalance > 0) {
      preICO.burnTokens(msg.sender);
      // Mint DOUBLE amount of tokens for our generous early investors.
      snm.mint(msg.sender, _sptBalance * 2);
    }
  }


  function getBonus(uint _value, uint _sold) public constant returns (uint) {
    uint[8] memory _promille = [ 150, 125, 100, 75, 50, 38, 25, uint(13) ];
    uint _step = TOKENS_FOR_SALE / 10;
    uint _bonus = 0;

    for(uint8 i = 0; _value > 0 && i < _promille.length; ++i) {
      uint _min = _step * i;
      uint _max = _step * (i+1);

      if(_sold >= _min && _sold < _max) {
        uint _bonusedPart = min(_value, _max - _sold);
        _bonus += _bonusedPart * _promille[i] / 1000;
        _value -= _bonusedPart;
        _sold  += _bonusedPart;
      }
    }

    return _bonus;
  }



  // Priveleged functions
  // ====================

  enum Currency { BTC, LTC, Dash }

  // This is called by our friendly robot to allow you to buy SNM for various
  // cryptos.
  function foreignBuy(
    address _investor,
    uint _snmValue,
    Currency _cur,
    uint _curValue)
  {
    // TODO:
    // - chk msg.sender
    // - chk currency limits
  }


  enum IcoState { Created, Running, Paused, Finished }

  function setIcoState(IcoState _newState) {
    // FIXME: Start in Paused state?
  }


  // Withdraw all collected ethers to the team's multisig wallet;
  function withdrawEther() {
    team.transfer(this.balance);
    Withdraw(this.balance);
  }



  // Private functions
  // =================

  function allocateFunds() internal {

  }

  function min(uint a, uint b) internal constant returns (uint) {
    return a < b ? a : b;
  }
}
