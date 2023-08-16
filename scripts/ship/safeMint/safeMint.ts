import { Wallet, Provider, Contract } from "zksync-web3";
import * as hre from "hardhat";
const args = require('./safeMintArgs.js');
const ship = require('../shipContract.js');



async function safeMint() {
    console.log("run safeMint() ...... ")

    const shipArtifact = await hre.artifacts.readArtifact("contracts/ship/AstraOmniRiseSpaceship.sol:AstraOmniRiseSpaceship");
    // let provider = hre.network.provider;
    const provider = new Provider(hre.network.config.url);
    const wallet = new Wallet(hre.network.config.accounts[0], provider);
    const shipContract = new Contract(ship.shipContract, shipArtifact.abi, wallet);

    let safeMint = await shipContract.safeMint(args.mintTO,args.getMetadata(args.metadata));
    await safeMint.wait();
    console.log("safeMint complete")
}

async function safeTransferFrom() {
    console.log("run safeTransferFrom() ...... ")

    const shipArtifact = await hre.artifacts.readArtifact("contracts/ship/AstraOmniRiseSpaceship.sol:AstraOmniRiseSpaceship");
    // let provider = hre.network.provider;
    const provider = new Provider(hre.network.config.url);
    const wallet = new Wallet(hre.network.config.accounts[0], provider);
    const shipContract = new Contract(ship.shipContract, shipArtifact.abi, wallet);

    // ethers V5 bug -> methods with the same name error: https://github.com/ethers-io/ethers.js/issues/1160
    let tx = await shipContract.functions['safeTransferFrom(address,address,uint256)']("0xaBF9776315d960d5d95f6ADCCE6441CeFaFd8750","0xaBF9776315d960d5d95f6ADCCE6441CeFaFd8750","1");
    await tx.wait();
    console.log("safeTransferFrom complete")
}



safeMint().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
/*
safeTransferFrom().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});*/
