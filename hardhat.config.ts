require("@nomiclabs/hardhat-waffle");
import { HardhatUserConfig } from 'hardhat/types';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';

const config: HardhatUserConfig = {
  solidity: "0.8.4",
  etherscan: {
    apiKey: process.env.ETHERSCAN_API
  },
  namedAccounts: {
    deployer: 0,
    admin: 1,
  },
};
export default config;

// // https://hardhat.org/guides/create-task.html
// task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
//   const accounts = await hre.ethers.getSigners();

//   for (const account of accounts) {
//     console.log(account.address);
//   }
// });
