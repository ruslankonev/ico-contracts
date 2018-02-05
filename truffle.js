var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "issue stereo item shaft clutch shuffle clerk jungle endorse grain hair stove";
module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    ropsten: {
      provider: function() { return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/SzWLgyLfKtsI5qlqcpmX",1) },
      network_id: 3
    },
    kovan: {
      provider: function() { return new HDWalletProvider(mnemonic, "https://kovan.infura.io/SzWLgyLfKtsI5qlqcpmX",1) },
      network_id: 3
    }
  },
};
