var SafeMath = artifacts.require('./SafeMath.sol');
var StarCoin = artifacts.require("./StarCoin.sol");
var InvestorWhiteList = artifacts.require("./InvestorWhiteList.sol");
var StarCoinICO = artifacts.require("./StarCoinICO.sol");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, StarCoin);
  deployer.link(SafeMath, StarCoinICO);
  deployer.deploy(StarCoin).then(async function() {
    const hardCap = 20000000; //in STAR
    const softCap =  16000000; //in STAR
    const token = StarCoin.address;

    var beneficiary;
    web3.eth.getAccounts( (err,res) => {
      beneficiary = res[0];
      console.log("beneficiary", beneficiary);
    })
    web3.eth.getBlockNumber( (err, res) => {
      const startBlock = res;
      const endBlock = startBlock + 2000;
      console.log("startBlock", startBlock);
      console.log("endBlock", endBlock);

      deployer.deploy(InvestorWhiteList).then(async function() {
        deployer.deploy(StarCoinICO, hardCap, softCap, token, beneficiary, InvestorWhiteList.address, startBlock, endBlock);
      })
    })
  });
};
