import { Wallet, utils } from "zksync-web3";
import * as ethers from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import * as  args from "./gameFundPoolArgs";

export default async function (hre: HardhatRuntimeEnvironment) {
    console.log(`Running deploy script for the GameFundPool contract`);
    const wallet = new Wallet(hre.network.config.accounts[0]);

    const deployer = new Deployer(hre, wallet);
    const artifact = await deployer.loadArtifact("contracts/GameFundPool.sol:GameFundPool");

    const deploymentFee = await deployer.estimateDeployFee(artifact, args);

    const parsedFee = ethers.utils.formatEther(deploymentFee.toString());
    console.log(`The deployment is estimated to cost ${parsedFee} ETH`);

    const greeterContract = await deployer.deploy(artifact, args);

    //obtain the Constructor Arguments
    console.log("constructor args:" + greeterContract.interface.encodeDeploy(args));

    // Show the contract info.
    const contractAddress = greeterContract.address;
    console.log(`${artifact.contractName} was deployed to ${contractAddress}`);
}
