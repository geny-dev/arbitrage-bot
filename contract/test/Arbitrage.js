const Arbitrage = artifacts.require("Arbitrage");
const zombieNames = ["Zombie 1", "Zombie 2"];
contract("Arbitrage", (accounts) => {
    let [alice, bob] = accounts;

    // start here

    it("should be able to create a new zombie", async () => {
        const contractInstance = await CryptoZombies.new();
        const result = await contractInstance.createRandomZombie(zombieNames[0], {from: alice});
        assert.equal(result.receipt.status, true);
        assert.equal(result.logs[0].args.name,zombieNames[0]);
    })

    //define the new it() function
})
