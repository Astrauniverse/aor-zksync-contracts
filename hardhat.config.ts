import "@matterlabs/hardhat-zksync-toolbox";
import { config as dotEnvConfig } from "dotenv";
// dynamically changes endpoints for local tests
// const zkSyncTestnet =
//     process.env.NODE_ENV == "test"
//         ? {
//             url: "https://zksync2-testnet.zksync.dev",
//             ethNetwork: "goerli",
//             zksync: true,
//         }
//         : {
//
//         };

// read .env file config
dotEnvConfig();

const TEST_PRIVATE_KEY = `${process.env.TEST_PRIVATE_KEY}`

const PROD_PRIVATE_KEY = `${process.env.PROD_PRIVATE_KEY}`;
module.exports = {
    zksolc: {
        version: "1.3.5",
        compilerSource: "binary",
        settings: {},
    },
    defaultNetwork: "zkSyncTestnet",

    networks: {
        zkSyncTestnet: {
            url: "https://zksync2-testnet.zksync.dev",
            ethNetwork: "goerli", // Can also be the RPC URL of the network (e.g. `https://goerli.infura.io/v3/<API_KEY>`)
            zksync: true,
            verifyURL: 'https://zksync2-testnet-explorer.zksync.dev/contract_verification',
            accounts: [TEST_PRIVATE_KEY]
        },
        zkSyncMainnet: {
            url: "https://mainnet.era.zksync.io",
            ethNetwork: "mainnet",
            zksync: true,
            verifyURL: 'https://zksync2-mainnet-explorer.zksync.io/contract_verification',
            accounts: [PROD_PRIVATE_KEY]
        },
    },
    solidity: {
        version: "0.8.18",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    },
};
