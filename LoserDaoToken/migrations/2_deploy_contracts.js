const LoserDao = artifacts.require("LoserDao");

module.exports = function(deployer) {
  deployer.deploy(LoserDao,"LoserDao", "LoserDaoToken");
};
