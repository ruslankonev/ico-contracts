var SafeMath = artifacts.require('./SafeMath.sol');
var StarCoin = artifacts.require("./StarCoin.sol");
var StarCoinICO = artifacts.require("./StarCoinICO.sol");
var InvestorWhiteList = artifacts.require("./InvestorWhiteList.sol");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, StarCoin);
  deployer.link(SafeMath, StarCoinICO);
  deployer.deploy(StarCoin).then(async function() {
    const hardCap = 20000000; //in STAR
    const softCap =  16000000; //in STAR
    const token = StarCoin.address;
    const beneficiary = web3.eth.accounts[0];
    const startBlock = web3.eth.blockNumber;
    const endBlock = web3.eth.blockNumber + 2000;
    await deployer.deploy(InvestorWhiteList);
    await deployer.deploy(StarCoinICO, hardCap, softCap, token, beneficiary, InvestorWhiteList.address, startBlock, endBlock);
  });
};
