import { expect } from "chai";
import { Wallet, Provider, Contract } from "zksync-web3";
import * as hre from "hardhat";
const { ethers } = require("hardhat");
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

const RICH_WALLET_PK = `${process.env.TEST_PRIVATE_KEY}`

async function deployGreeter(deployer: Deployer): Promise<Contract> {
    const artifact = await deployer.loadArtifact("Greeter");
    return await deployer.deploy(artifact, ["Hi"]);
}

/*describe("Greeter", function () {
    it("Should return the new greeting once it's changed", async function () {
        const provider = Provider.getDefaultProvider();

        const wallet = new Wallet(RICH_WALLET_PK, provider);
        const deployer = new Deployer(hre, wallet);

        const greeter = await deployGreeter(deployer);

        expect(await greeter.greet()).to.eq("Hi");

        const setGreetingTx = await greeter.setGreeting("Hola, mundo!");
        // wait until the transaction is mined
        await setGreetingTx.wait();

        expect(await greeter.greet()).to.equal("Hola, mundo!");
    });
});*/

describe("checkInWhitelist", function () {
    it("Should return true", async () => {
        /*const provider = new Provider("https://zksync2-testnet.zksync.dev");

        const wallet = new Wallet(RICH_WALLET_PK, provider);
        const deployer = new Deployer(hre, wallet);
        const artifact = await deployer.loadArtifact("Greeter");*/

        const artifact = await hre.artifacts.readArtifact("Greeter");
        // let provider = hre.network.provider;
        const provider = new Provider(hre.network.config.url);
        const wallet = new Wallet(RICH_WALLET_PK, provider);

        const greeter = new Contract("0x909E34b36F82ad65F7e476FDb5168D03a8Fd1aDC", artifact.abi, wallet);

        const whitelistRoot = "0x4f333bf5ca281a9bff4533bc36ce4357d9c400aea488f7cd13d1c54df3fe7aff";
        const proof =  [
            "0x0eb41fd4423838eadbfe97c27e70c206b603c7bc01a8d84c221424971b9ba011",
            "0x24280176fa87db5f4640e0d33c7369ca8fc4637180fda7b457a48cff92aa815c",
            "0xbe252c90c1ef39cc3f04ecf33c03436b9ba23d2e4e87462c9b14f25a55134d20",
            "0x179ca30ae3b635cf7be6eb45109e8749f67f755eec7ce6bffa10e5de35350247",
            "0x89e5fc70d4a93ae4c87ec4630f2dc2d066bfed717e013781a68f6a24a08820da",
            "0xfa4a8d22b99cec66df69b6465e95475caf4b63e34fdec1910c5608fdb47217e3",
            "0x5e6f4674c49519c35b7350ba00954febf47be1c8ae09331d30b84561ac699e12",
            "0xb4011666ff33d4f728f081f5d9bfb21827b11a1982430458c8ee53cc5953156a",
            "0x353f50258cd16af44f768c90a48341c645c09a04f688e58ae469ad5c447d26e5",
            "0x6bf95d733750f11e16ed2e6539dca38e6b7157bfc6c86606d65d28b96b07bf25",
            "0x0571185593f04029af55afc1bf9cace0ddd4b44e0bd3de2230f9cc34241b6887",
            "0xb4a7fa95e2b668e0aa5e8cc2f8daefb88adc2139fc9feeea4420dbd97395e1a4",
            "0xfca24fc853bf077a6d958e5e759202872c47ec31007cf02398acbef317a7e4aa",
            "0x208795223d8ab966cfebd2e660b747a50a80f267490dfa3e9ae4dd727a7f6373"
        ];
        const addr = "0x6215d01d700b366FC31319d7b3488Fe81E30C399";
        const whitelistType = 1;

        let isWhitelist = await greeter.checkInWhitelist(whitelistRoot,proof,addr,whitelistType);
        console.log("isWhitelist == ",isWhitelist);
        expect(isWhitelist).to.eq(true);

        isWhitelist = await greeter.checkInWhitelist(whitelistRoot,proof,addr,2);
        console.log("isWhitelist == ",isWhitelist);
        expect(isWhitelist).to.eq(false);
    });
});
