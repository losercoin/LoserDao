const LoserDaoTreasury = artifacts.require("LoserDaoTreasury");

module.exports = function(deployer) {
  const loserDaoToken = "0x4BA325cE10eEb1D70073AC7CC03a02CE0a3931C0";
  const lowbToken = "0x5aa1a18432aa60bad7f3057d71d3774f56cd34b8";

  const gatesNft_oec_test = "0x817a120a790ebbbe1e6fbe05af99f54538622e36";
  const uyangToken_oec_test = "0xecadbde3a6f20ebedd3927ad08785751fe5b0abe";
  const lowbToken_oec_test = "0xaa159B8d4156C4feDC94Edc752A2eDa0D00768eE";
  const loserPunk_oec_test = "0xaa159B8d4156C4feDC94Edc752A2eDa0D00768eE";
  deployer.deploy(LoserDaoTreasury, loserDaoToken, lowbToken);
};
