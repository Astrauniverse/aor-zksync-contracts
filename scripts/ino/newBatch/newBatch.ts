import { Wallet, Provider, Contract } from "zksync-web3";
import * as hre from "hardhat";
const args = require('./newBatchArgs.js');
const ino = require('../inoContract.js');


async function newBatch() {
    console.log("run newBatch() ...... ")
    const artifact = await hre.artifacts.readArtifact("contracts/AuctionSpaceship.sol:AuctionSpaceship");
    // let provider = hre.network.provider;
    const provider = new Provider(hre.network.config.url);
    const wallet = new Wallet(hre.network.config.accounts[0], provider);
    const contract = new Contract(ino.auctionSpaceshipContract, artifact.abi, wallet);

//function newBatch(uint256 saleStartTime,uint256 roundTime,uint256 saleQuantity,uint256 startingPrice,uint256 incrementPrice,uint256 purchaseLimit,
// AstraOmniRiseSpaceship.Metadata memory metadata)
    let receipt = await contract.newBatch(args.saleStartTime,args.roundTime,args.saleQuantity,args.startingPrice,args.incrementPrice,args.purchaseLimit,args.getMetadata());
    await receipt.wait();
    console.log("newBatch complete")
}
newBatch().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
