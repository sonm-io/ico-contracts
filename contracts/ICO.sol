
pragma solidity ^0.4.11;

import "./PreICO.sol";
import "./SNM.sol";


contract ICO {

  // Constants
  // =========

  uint constant PRICE = 1212; // SNM per ETH

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
    if(msg.value > 0) {
      uint _snmValue = msg.value * PRICE;
      snm.mint(_investor, _snmValue);
    }
  }


  function migrate() {
    uint _sptBalance = preICO.balanceOf(msg.sender);
    if(_sptBalance > 0) {
      preICO.burnTokens(msg.sender);
      // Mint DOUBLE amount of tokens for our generous early investors.
      snm.mint(msg.sender, _sptBalance * 2);
    }
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

  function getBonus() internal {

  }

  function allocateFunds() internal {

  }
}
