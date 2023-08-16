import { expect } from "chai";
import {Wallet, Provider, Contract, utils} from "zksync-web3";
import * as hre from "hardhat";
import * as ethers from "ethers";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

const RICH_WALLET_PK = `${process.env.TEST_PRIVATE_KEY}`

/**
 * Deposit funds to L2
 * @param deployer
 * @param amount
 */
async function deposit(deployer: Deployer, amount: ethers.BigNumber) {
    // OPTIONAL: Deposit funds to L2
    // Comment this block if you already have funds on zkSync.
    const depositHandle = await deployer.zkWallet.deposit({
        to: deployer.zkWallet.address,
        token: utils.ETH_ADDRESS,
        amount: amount,
    });
    // Wait until the deposit is processed on zkSync
    await depositHandle.wait();
}

describe("deposit", function () {
    it("deposit", async () => {
        const provider = new Provider("https://zksync2-testnet.zksync.dev");

        const wallet = new Wallet(RICH_WALLET_PK, provider);

        const deployer = new Deployer(hre, wallet);
        //转几个eth
        const val = ethers.utils.parseUnits("2", "ether");
        await deposit(deployer,val);
    });
});
