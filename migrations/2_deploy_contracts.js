// var Oyla = artifacts.require("./Oyla.sol");
// var Sample = artifacts.require("./Sample.sol");
var Denemeler = artifacts.require("./Denemeler.sol");

module.exports = function(deployer) {
  deployer.deploy(Denemeler);
  // deployer.deploy(Denemeler);

  // Additional contracts can be deployed here
  // e.g. deployer.deploy(Contract, input_1, input...);
};