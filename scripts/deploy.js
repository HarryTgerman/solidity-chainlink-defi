const hre = require("hardhat");



async function main(
    getNamedAccounts,
    deployments,
) {
    // const { deploy } = deployments;
    const { deployer, admin } = await getNamedAccounts();

    const TokenFram = await hre.ethers.getContractFactory("TokenFram");
    const HarrysRewardToken = await hre.ethers.getContractFactory("HarrysRewardToken");


    const rewardToken = await HarrysRewardToken.deploy();

    await rewardToken.deployed();

    const tokenFram = await TokenFram.deploy(rewardToken.address, 0.0000017133996, { from: admin });

    await tokenFram.deployed();

    console.log("Greeter deployed to:",);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });



