var SafeMath = artifacts.require('./SafeMath.sol');
var StarCoin = artifacts.require("./StarCoin.sol");
var StarCoinPreSale = artifacts.require("./StarCoinPreSale.sol");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, StarCoin);
  deployer.link(SafeMath, StarCoinPreSale);
  deployer.deploy(StarCoin).then(function() {
    const hardCap = 12916;
    const softCap = 0;
    const token = StarCoin.address;
    const totalTokens = 6328760; //NOT in wei, converted by contract
    const limit = 4000; //in ETH
    const beneficiary = web3.eth.accounts[0];
    const startBlock = web3.eth.blockNumber;
    const endBlock = web3.eth.blockNumber + 100;

    deployer.deploy(StarCoinPreSale, hardCap, softCap, token, beneficiary, totalTokens, limit, startBlock, endBlock);
  });
};
