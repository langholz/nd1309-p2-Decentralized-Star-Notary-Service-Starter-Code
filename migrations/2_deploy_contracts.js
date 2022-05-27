const StarNotary = artifacts.require("StarNotary");

module.exports = function (deployer) {
  deployer.deploy(StarNotary, "Star notary 54231", "STN54231");
};
