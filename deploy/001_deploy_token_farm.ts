

import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNamedAccounts, ethers } = hre;
    const { deploy, log } = deployments

    const { deployer, admin } = await getNamedAccounts();

    const rewardToken = await deploy('HarrysRewardToken', { from: admin, log: true })


    await deploy('TokenFram', {
        from: admin,
        args: [rewardToken.address, 1000],
        log: true,
    });
};
export default func;
func.tags = ['TokenFram'];