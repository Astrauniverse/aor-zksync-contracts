import { Wallet, Provider, Contract } from "zksync-web3";
import * as hre from "hardhat";
const args = require('./addMinterArgs.js');
const ship = require('../shipContract.js');

async function addMinter() {
    console.log("run addMinter() ...... ")
    const shipArtifact = await hre.artifacts.readArtifact("contracts/ship/AstraOmniRiseSpaceship.sol:AstraOmniRiseSpaceship");
    // let provider = hre.network.provider;
    const provider = new Provider(hre.network.config.url);
    const wallet = new Wallet(hre.network.config.accounts[0], provider);
    const shipContract = new Contract(ship.shipContract, shipArtifact.abi, wallet);

    let receipt = await shipContract.addMinter(args.minter);
    await receipt.wait();
    console.log("addMinter complete")
}

addMinter().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
