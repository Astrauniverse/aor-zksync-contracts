import { Wallet, utils } from "zksync-web3";
import * as ethers from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import * as  args from "./auctionSpaceshipArgs";

export default async function (hre: HardhatRuntimeEnvironment) {
    console.log(`Running deploy script for the AuctionSpaceship contract`);
    const wallet = new Wallet(hre.network.config.accounts[0]);

    const deployer = new Deployer(hre, wallet);
    const artifact = await deployer.loadArtifact("contracts/AuctionSpaceship.sol:AuctionSpaceship");


    const contract = await deployer.deploy(artifact, args);

    //obtain the Constructor Arguments
    console.log("constructor args:" + contract.interface.encodeDeploy(args));

    // Show the contract info.
    const contractAddress = contract.address;
    console.log(`${artifact.contractName} was deployed to ${contractAddress}`);
}
