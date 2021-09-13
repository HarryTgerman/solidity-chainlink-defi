// stake Tokens
// unstake Tokens
// issue Tokens
// add Allowed Tokens
// getEthValue
// SPDX-License-Identifier: MIT

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract TokenFram is Ownable {
    struct Deposit {
        uint256 amount;
        uint256 timestamp;
    }
    mapping(address => mapping(address => Deposit[])) public stakingBalance;
    address[] public allowedTokens;
    address[] public stakers;
    mapping(address => uint256) public uniqueTokensStaked;
    mapping(address => address) public tokenPriceFeedMapping;
    IERC20 public rewardToken;
    // 2334540 blocks per year 400% APY
    // uint256 rewardPerHour = 0.0000017133996;
    uint256 rewardPerHour;

    constructor(address _rewardTokenAddress, uint256 _rewardPerHour) {
        rewardToken = IERC20(_rewardTokenAddress);
        rewardPerHour = _rewardPerHour;
    }

    function setPriceFeedContract(address _token, address _priceFeed)
        public
        onlyOwner
    {
        tokenPriceFeedMapping[_token] = _priceFeed;
    }

    function stakeTokens(uint256 _amount, address _token) public {
        require(_amount > 0, "amount needs to be greater");
        require(isAllowed(_token) == true, "can not stake this Token");
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        stakingBalance[_token][msg.sender].push(
            Deposit({amount: _amount, timestamp: block.timestamp})
        );
        updateUniqueTokensStaked(msg.sender, _token);
        if (uniqueTokensStaked[msg.sender] == 1) {
            stakers.push(msg.sender);
        }
    }

    function isAllowed(address _token) public view returns (bool) {
        for (uint256 i = 0; i < allowedTokens.length; i++) {
            if (allowedTokens[i] == _token) {
                return true;
            }
        }
        return false;
    }

    function addAllowedTokens(address _token) public onlyOwner {
        allowedTokens.push(_token);
    }

    function updateUniqueTokensStaked(address _user, address _token) internal {
        if (stakingBalance[_token][_user].length <= 0) {
            uniqueTokensStaked[_user] = uniqueTokensStaked[_user] + 1;
        }
    }

    function issueTokens() public onlyOwner {
        for (uint256 i = 0; i < stakers.length; i++) {
            address recipient = stakers[i];
            uint256 userTotalValue = getUserTotalValue(recipient);
            rewardToken.transfer(recipient, userTotalValue);
        }
    }

    function claimTokens() public {
        require(isStaker(msg.sender) == true, "You are not a staker");
        uint256 userTotalValue = getUserTotalValue(msg.sender);
        rewardToken.transfer(msg.sender, userTotalValue);
    }

    function isStaker(address _user) public view returns (bool) {
        for (uint256 i = 0; i < stakers.length; i++) {
            if (stakers[i] == _user) {
                return true;
            }
        }
        return false;
    }

    function getUserTotalValue(address _user) public returns (uint256) {
        uint256 totalValue = 0;
        require(uniqueTokensStaked[_user] > 0);
        for (uint256 i = 0; i < allowedTokens.length; i++) {
            totalValue =
                totalValue +
                getUserSingleTokenValue(_user, allowedTokens[i]);
        }
        return totalValue;
    }

    function getUserSingleTokenValue(address _user, address _token)
        public
        returns (uint256)
    {
        if (uniqueTokensStaked[_user] <= 0) {
            return 0;
        }
        uint256 singleTokenTotalValue = 0;
        for (uint256 i = 0; i < stakingBalance[_token][_user].length; i++) {
            uint256 hoursStaked = ((block.timestamp -
                stakingBalance[_token][_user][i].timestamp) / 1 hours);
            (uint256 price, uint256 decimals) = getTokenValue(_token);

            uint256 value = (stakingBalance[_token][_user][i].amount * price) /
                (10**decimals);

            singleTokenTotalValue =
                singleTokenTotalValue +
                ((value * hoursStaked) / rewardPerHour);
            stakingBalance[_token][_user][i].timestamp = block.timestamp;
        }
        return singleTokenTotalValue;
    }

    function getTokenValue(address _token)
        public
        view
        returns (uint256, uint256)
    {
        address priceFeedAddress = tokenPriceFeedMapping[_token];
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            priceFeedAddress
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint256 decimals = uint256(priceFeed.decimals());
        return (uint256(price), decimals);
    }

    function unstakeTokens(address _token) public {
        Deposit[] memory balance = stakingBalance[_token][msg.sender];
        require(balance.length > 0, "No stakes found");
        claimTokens();
        uint256 amount = getStakedBalance(msg.sender, _token);
        delete stakingBalance[_token][msg.sender];
        uniqueTokensStaked[msg.sender] = uniqueTokensStaked[msg.sender] - 1;
        if (uniqueTokensStaked[msg.sender] == 0) {
            removeStaker(msg.sender);
        }
        IERC20(_token).transfer(_token, amount);
    }

    function getStakedBalance(address _user, address _token)
        public
        view
        returns (uint256 balance)
    {
        uint256 amountTotal = 0;
        for (uint256 i = 0; i < stakingBalance[_token][_user].length; i++) {
            amountTotal = amountTotal + stakingBalance[_token][_user][i].amount;
        }
        return amountTotal;
    }

    function removeStaker(address _user) public {
        for (uint256 i = 0; i < stakers.length; i++) {
            if (stakers[i] == _user) {
                // Move the last element into the place to delete
                stakers[i] = stakers[stakers.length - 1];
                // Remove the last element
                stakers.pop();
            }
        }
    }
}
