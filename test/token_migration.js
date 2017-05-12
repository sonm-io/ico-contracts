
const SNM = artifacts.require("./SNM.sol");
const ICO = artifacts.require("./ICO.sol");
const MockPreICO = artifacts.require("./MockPreICO.sol");

contract("ICO", () => {
  const [a, b, c] = web3.eth.accounts;
  let preICO;
  let ico;
  let snm;


  function chkBalance(tok, addr, val, msg) {
    return tok.balanceOf.call(addr).then(res =>
      assert.equal(val, web3.fromWei(res.toFixed(), 'ether'), msg)
    )
  }



  it("should be able to create MockPreICO", () =>
    MockPreICO.new().then(res => {
      assert.isOk(res && res.address, "has invalid address");
      preICO = res;
    })
  );

  it("should be able to create ICO", () =>
    ICO.new(preICO.address, a, b).then(res => {
      assert.isOk(res && res.address, "has invalid address");
      ico = res;
      return ico.snm.call().then(_snm => snm = SNM.at(_snm));
    })
  );

  it("should be able to set balance in MockPreICO", () =>
    preICO.setBalance(web3.toWei(3, 'ether'), {from: c}).then(() =>
      chkBalance(preICO, c, 3, "can't set mock balance")
    )
  );

  it("should be able to migrate some tokens", () =>
    ico.migrate({from: c}).then(() =>
      chkBalance(preICO, c, 0, "balance should be empty after migration")
    )
  );

  it("SNM balance should be 2*SPT after migration", () =>
    chkBalance(snm, c, 3 * 2, "SPT should be doubled after migration")
  );

  it("should not change SPT balance on repeated migrations", () =>
    ico.migrate({from: c}).then(() =>
      chkBalance(preICO, c, 0, "balance should not change")
    )
  );

  it("should not change SNM balance on repeated migrations", () =>
    ico.migrate({from: c}).then(() =>
      chkBalance(snm, c, 3 * 2, "balance should not change")
    )
  );
})
