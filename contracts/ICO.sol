
pragma solidity ^0.4.11;

import "./PreICO.sol";
import "./SNM.sol";


// TODO:
//  - allocateFunds
//  - setRobotAddress
// FIXME:
//  - merge buy & foreignBuy?


contract ICO {

  // Constants
  // =========

  uint public constant TOKEN_PRICE = 606; // SNM per ETH
  uint public constant TOKENS_FOR_SALE = 165680000 * 1e18;

  enum Currency { BTC, LTC, Dash }
  uint private constant CURRENCY_LEN = uint(Currency.Dash) + 1;
  // Limit the amount of tokens that can be sold for the specific currency.
  uint[] public CURRENCY_LIMIT = [ 10 * 1e18, 20 * 1e18, 30 * 1e18 ];


  // Events
  // ======

  event Migrate(address holder, uint snmValue);
  event Withdraw(uint value);
  event CurrencyOverflow(Currency currency, string curAddress);
  event RunIco();
  event PauseIco();
  event FinishIco(address teamFund, address ecosystemFund, address bountyFund);


  // State variables
  // ===============

  PreICO preICO;
  SNM public snm;

  address team;
  address tradeRobot;
  modifier teamOnly { require(msg.sender == team); _; }
  modifier robotOnly { require(msg.sender == tradeRobot); _; }

  uint tokensSold = 0;

  enum IcoState { Created, Running, Paused, Finished }
  IcoState icoState = IcoState.Created;


  // Constructor
  // ===========

  function ICO(address _team, address _preICO, address _tradeRobot) {
    snm = new SNM(this);
    preICO = PreICO(_preICO);
    team = _team;
    tradeRobot = _tradeRobot;
  }



  // Public functions
  // ================

  // Here you can buy some tokens (just don't forget to provide enough gas).
  function() external payable {
    buy(msg.sender);
  }


  function buy(address _investor) public payable {
    require(icoState == IcoState.Running);
    require(msg.value > 0);

    uint _snmValue = msg.value * TOKEN_PRICE;
    uint _bonus = getBonus(_snmValue, tokensSold);
    uint _total = _snmValue + _bonus;

    require(tokensSold + _total <= TOKENS_FOR_SALE);

    snm.mint(_investor, _total);
    tokensSold += _total;
  }


  function migrate() external {
    require(icoState == IcoState.Created || icoState == IcoState.Running);

    uint _sptBalance = preICO.balanceOf(msg.sender);
    require(_sptBalance > 0);

    preICO.burnTokens(msg.sender);
    // Mint DOUBLE amount of tokens for our generous early investors.

    uint _snmValue = _sptBalance * 2;
    snm.mint(msg.sender, _snmValue);
    Migrate(msg.sender, _snmValue);
  }


  function getBonus(uint _value, uint _sold)
    public constant returns (uint)
  {
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


  // This is called by our friendly robot to allow you to buy SNM for various
  // cryptos.
  function foreignBuy(
    address _investor,
    uint _snmValue,
    Currency _cur,
    string _curAddress
  )
    external robotOnly
  {
    require(icoState == IcoState.Running);

    uint _curIx = uint(_cur);
    if(_curIx >= CURRENCY_LEN) throw;
    if(CURRENCY_LIMIT[_curIx] == 0) {
      CurrencyOverflow(_cur, _curAddress);
      return;
    }
    uint _bonus = getBonus(_snmValue, tokensSold);
    uint _total = _snmValue + _bonus;
    if(CURRENCY_LIMIT[_curIx] < _total) {
      CurrencyOverflow(_cur, _curAddress);
      return;
    }

    CURRENCY_LIMIT[_curIx] -= _total;
    snm.mint(_investor, _total);
  }



  // ICO state management: start / pause / finish
  // --------------------------------------------

  function startIco() external teamOnly {
    require(icoState == IcoState.Created || icoState == IcoState.Paused);
    icoState = IcoState.Running;
    RunIco();
  }


  function pauseIco() external teamOnly {
    require(icoState == IcoState.Running);
    icoState = IcoState.Paused;
    PauseIco();
  }


  function finishIco(
    address _teamFund,
    address _ecosystemFund,
    address _bountyFund
  )
    external teamOnly
  {
    require(icoState == IcoState.Running || icoState == IcoState.Paused);

    // TODO: allocate funds depending on snm.totalSupply()

    icoState = IcoState.Finished;
    FinishIco(_teamFund, _ecosystemFund, _bountyFund);
  }


  // Withdraw all collected ethers to the team's multisig wallet
  function withdrawEther() external teamOnly {
    team.transfer(this.balance);
    Withdraw(this.balance);
  }



  // Private functions
  // =================

  function min(uint a, uint b) internal constant returns (uint) {
    return a < b ? a : b;
  }
}
