const LoserDaoProposal = artifacts.require("LoserDaoProposal");

module.exports = function(deployer) {
  const mumbaiProxy = "0x207fa8df3a17d96ca7ea4f2893fcdcb78a304101";
  const gatesNft = "0xB38C0fbe5c75ae359a812581b36efF9612457Fa3";
  const daoToken = "0x4BA325cE10eEb1D70073AC7CC03a02CE0a3931C0";
  const lowbToken = "0x5aa1a18432aa60bad7f3057d71d3774f56cd34b8";
  const treasury = "0xF8C32af57C9876a603698a611383fbF6F3408473";
  const loserPunk = "0xe031188b0895afd3f3c32b2bf27fbd1ab9e8c9ea";

  const gatesNft_oec_test = "0x817a120a790ebbbe1e6fbe05af99f54538622e36";
  const uyangToken_oec_test = "0xecadbde3a6f20ebedd3927ad08785751fe5b0abe";
  const lowbToken_oec_test = "0xaa159B8d4156C4feDC94Edc752A2eDa0D00768eE";
  const treasury_oec_test = "0xe1650c34a62d8d716b718d3623175c2af7e4a1ad";
  const loserPunk_oec_test = "0xb6934d8344BDaf9624F6361Cd7aFb98b8377060D";
  deployer.deploy(LoserDaoProposal, "LoserDaoProposal", "LoserDaoProposal", daoToken,lowbToken);
};