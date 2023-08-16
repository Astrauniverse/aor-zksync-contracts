import { Wallet, Provider, Contract } from "zksync-web3";
import * as hre from "hardhat";
const args = require('./withdrawArgs.js');
const ino = require('../inoContract.js');


async function withdraw() {
    console.log("run withdraw() ...... ")
    const artifact = await hre.artifacts.readArtifact("contracts/AuctionSpaceship.sol:AuctionSpaceship");
    // let provider = hre.network.provider;
    const provider = new Provider(hre.network.config.url);
    const wallet = new Wallet(hre.network.config.accounts[0], provider);
    const contract = new Contract(ino.auctionSpaceshipContract, artifact.abi, wallet);

// function withdraw(uint256 batchId,address to) external nonReentrant onlyOwner
    let receipt = await contract.withdraw(args.batchId,args.to);
    await receipt.wait();
    console.log("withdraw complete")
}
withdraw().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
