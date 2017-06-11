const ICO = artifacts.require("./ICO.sol");
const MSig = artifacts.require("./installed/MultiSigWallet.sol");


module.exports = (deployer, network) => {

  const team
    = network === "mainnet"
      ? [ "0xCc14D25Fae961Ced09709BE04bf13c28Db3FF81b" // Alexey
        , "0xf9AE3E50B994Fa6914757958D65Ad1B3547fBe82" // Sergey
        ]
      : web3.eth.accounts.slice(0, 2);
  const requiredConfirmations = team.length;
  const preICO = "0x0000000000000000000000000000000000000000";
  const robot
    = network === "mainnet"
      ?  "0x0000000000000000000000000000000000000000"
      : web3.eth.accounts[3];

  deployer.deploy(MSig, team, requiredConfirmations)
    .then(MSig.deployed)
    .then(msig => deployer.deploy(ICO, msig.address, preICO, robot));
};
