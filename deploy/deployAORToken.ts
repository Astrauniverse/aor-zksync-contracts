import { Wallet, utils } from "zksync-web3";
import * as ethers from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {
    console.log(`Running deploy script for the AstraOmniRiseToken contract`);
    const wallet = new Wallet(hre.network.config.accounts[0]);

    const deployer = new Deployer(hre, wallet);
    const artifact = await deployer.loadArtifact("contracts/AstraOmniRiseToken.sol:AstraOmniRiseToken");

    const deploymentFee = await deployer.estimateDeployFee(artifact,[]);

    const parsedFee = ethers.utils.formatEther(deploymentFee.toString());
    console.log(`The deployment is estimated to cost ${parsedFee} ETH`);

    const contract = await deployer.deploy(artifact, []);

    console.log("constructor args:" + contract.interface.encodeDeploy([]));

    // Show the contract info.
    const contractAddress = contract.address;
    console.log(`${artifact.contractName} was deployed to ${contractAddress}`);
}
