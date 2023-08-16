import { Wallet, utils } from "zksync-web3";
import * as ethers from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import * as  deployArguments from "./deployIDOArgs";

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {
    console.log(`Running deploy script for the AstraOmniRiseIDO contract`);
    const wallet = new Wallet(hre.network.config.accounts[0]);

    const deployer = new Deployer(hre, wallet);
    const artifact = await deployer.loadArtifact("contracts/AstraOmniRiseIDO.sol:AstraOmniRiseIDO");

    const greeterContract = await deployer.deploy(artifact, deployArguments);

    //obtain the Constructor Arguments
    console.log("constructor args:" + greeterContract.interface.encodeDeploy(deployArguments));

    // Show the contract info.
    const contractAddress = greeterContract.address;
    console.log(`${artifact.contractName} was deployed to ${contractAddress}`);
}
