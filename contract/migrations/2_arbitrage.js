var Arbitrage = artifacts.require("./Arbitrage.sol");
module.exports = async function(deployer, _, accounts) {
  console.log("Deploying Arbitrage contract from account:", accounts[0]);

  await deployer.deploy(Arbitrage);
  
  const arbitrage = await Arbitrage.deployed();

  console.log("Deployed Arbitrage into :", arbitrage.address);
  
  console.log("Deploy Success!");
};