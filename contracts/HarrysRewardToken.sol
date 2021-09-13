// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract HarrysRewardToken is ERC20 {
    constructor() ERC20("Harrys Reward Token", "HRY") {
        _mint(msg.sender, 1000000 * 10**18);
    }
}
