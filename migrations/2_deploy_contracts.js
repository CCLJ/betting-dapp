var Casino = artifacts.require("./Casino.sol");

module.exports = function(deployer) {
  deployer.deploy(Casino);
  // min bet = 0.1 ether in Wei
  // 100 is max number pf players
  // gas limit = willing to pay for deployment
  // deployer.deploy(web3.toWei(0.1, 'ether'), 100, { gas: 3000000 });
};
