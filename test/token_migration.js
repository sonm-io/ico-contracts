
const ppc = require("../tools/preprocessor");

ppc.run("src", "contracts", {});

const MockPreICO = artifacts.require("./MockPreICO.sol");

contract("ICO", () => {
  MockPreICO.new().then(preIco => {
    console.log(preIco.address);
    ppc.run("src", "contracts", {PRESALE_ADDRESS: preIco.address});
  });
});
