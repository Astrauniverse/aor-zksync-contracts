# Set up the project

Document:  https://era.zksync.io/docs/dev/building-on-zksync/hello-world.html  

## Compile:
```shell
yarn hardhat compile
```

## Deploy:
```shell
# Run all the files under the deploy directory. The file format requires exporting a method as the entrypoint (export default). Refer to: https://github.com/matter-labs/hardhat-zksync/issues/119

yarn hardhat deploy-zksync
# Only run deploy/deployGreeter.ts file
yarn hardhat deploy-zksync --script deployGreeter.ts --network zkSyncTestnet
```  
Docs: https://era.zksync.io/docs/api/hardhat/hardhat-zksync-deploy.html#commands  
- To run a specific script, add the `--script` parameter, e.g. `hardhat deploy-zksync --script 001_deploy.ts` will run the script `./deploy/001_deploy.ts`.
- To run on a specific zkSync network, use the`--network `parameter, e.g.`--network zkTestnet`(zkTestnet needs to be configured as a network in hardhat.config.ts), or specify defaultNetwork in hardhat.config.ts.

# Verify contract

https://era.zksync.io/docs/api/hardhat/hardhat-zksync-verify.html    
Command to verify contract:
```shell
yarn hardhat verify --network <network> <contract address> --contract <fully qualified name>
```
- `--network` specifies the network.  
- `--contract` specifies which contract to verify. E.g.`--contract contracts/AContract.sol:TheContract`  


```shell
yarn hardhat verify --network zkSyncTestnet <contract address> --constructor-args deploy/greeterArguments.js
```
- `--network zkSyncTestnet` means verifying the contract on zkSyncTestnet network. zkSyncTestnet is configured as a network in`hardhat.config.ts`.
- `--constructor-args deploy/greeterArguments.js` means the arguments when creating the contract. It's in`deploy/greeterArguments.js`.

# Run scripts
```shell
npx hardhat run scripts/ship/ship.ts
```
Select network to run script. Default is the `defaultNetwork` configured in `hardhat.config.ts`.

```shell
npx hardhat --network zkSyncTestnet run scripts/ship/ship.ts
```
# Test contracts

Docs: https://era.zksync.io/docs/api/hardhat/testing.html#testing-with-mocha-chai  
Test a single file:  

```shell
npx hardhat test test/greeter.ts
```
Test all files under test folder:

```shell
npx hardhat test
```
Select network for testing:

```shell
cd  .\test\ship\
npx hardhat  --network zkSyncTestnet test ship.ts
```
