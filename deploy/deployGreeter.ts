import { Wallet, utils } from "zksync-web3";
import * as ethers from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import * as  greeterArguments from "./greeterArguments";
const WALLET_PRIVATE_KEY = `${process.env.TEST_PRIVATE_KEY}`;

/**
 * Deposit funds to L2
 * @param deployer
 * @param deploymentFee
 */
async function deposit(deployer: Deployer, deploymentFee: ethers.BigNumber) {
    // OPTIONAL: Deposit funds to L2
    // Comment this block if you already have funds on zkSync.
    const depositHandle = await deployer.zkWallet.deposit({
        to: deployer.zkWallet.address,
        token: utils.ETH_ADDRESS,
        amount: deploymentFee.mul(2),
    });
    // Wait until the deposit is processed on zkSync
    await depositHandle.wait();
}

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {
    console.log(`Running deploy script for the Greeter contract`);
    // Initialize the wallet.
    const wallet = new Wallet(WALLET_PRIVATE_KEY);

    // Create deployer object and load the artifact of the contract you want to deploy.
    const deployer = new Deployer(hre, wallet);
    const artifact = await deployer.loadArtifact("Greeter");

    // Estimate contract deployment fee
    const greeting = greeterArguments[0];
    console.log(`greeting == `,greeting);
    const deploymentFee = await deployer.estimateDeployFee(artifact, [greeting]);

    //Deposit funds to L2
    // await deposit(deployer, deploymentFee);

    // Deploy this contract. The returned object will be of a `Contract` type, similarly to ones in `ethers`.
    // `greeting` is an argument for contract constructor.
    const parsedFee = ethers.utils.formatEther(deploymentFee.toString());
    console.log(`The deployment is estimated to cost ${parsedFee} ETH`);

    const greeterContract = await deployer.deploy(artifact, [greeting]);

    //obtain the Constructor Arguments
    console.log("constructor args:" + greeterContract.interface.encodeDeploy([greeting]));

    // Show the contract info.
    const contractAddress = greeterContract.address;
    console.log(`${artifact.contractName} was deployed to ${contractAddress}`);
}
