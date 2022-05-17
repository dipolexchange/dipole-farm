const Distribution = artifacts.require("Distribution");
const governance = "0x03bc45D46EA3EF8e9ECE777fe20e3169f5Ee3637";
const devOps = "0xb82450a9C9433DF8a8a8dEE9A5660982Aa136795";
const otherExpenses = "0x3C4e46647aDBca88D6224fD0b9CD94cfB2F053F3";

module.exports = function(deployer) {
  deployer.deploy(Distribution, governance, devOps, otherExpenses);
};
