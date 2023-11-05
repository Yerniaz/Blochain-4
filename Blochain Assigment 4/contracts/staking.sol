// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Staking {
    address public owner;
    uint public stakingPeriod;
    uint public totalRewards;

    mapping(address => uint) public userBalances;
    mapping(address => uint) public stakedBalances;
    mapping(address => uint) public stakingStartTimes;
    address[] public stakers;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(uint _stakingPeriod, uint _totalRewards) {
        owner = msg.sender;
        stakingPeriod = _stakingPeriod;
        totalRewards = _totalRewards;
    }

    function deposit(uint _amount) public {
        userBalances[msg.sender] += _amount;
    }

    function stake(uint _amount) public {
        require(userBalances[msg.sender] >= _amount, "Insufficient balance");
        userBalances[msg.sender] -= _amount;
        stakedBalances[msg.sender] += _amount;
        stakingStartTimes[msg.sender] = block.timestamp;
    }

    function calculateRewards(address _user) public view returns (uint) {
        uint timeStaked = block.timestamp - stakingStartTimes[_user];
        return (stakedBalances[_user] * timeStaked) / stakingPeriod;
    }

    function distributeRewards() public onlyOwner {
        require(totalRewards > 0, "No rewards left to distribute");

        for (uint i = 0; i < stakers.length; i++) {
            address staker = stakers[i];
            uint reward = calculateRewards(staker);
            userBalances[staker] += reward;
            totalRewards -= reward;
        }
    }

    function withdraw() public {
        require(block.timestamp - stakingStartTimes[msg.sender] >= stakingPeriod, "Staking period not yet complete");
        uint reward = calculateRewards(msg.sender);
        userBalances[msg.sender] += stakedBalances[msg.sender] + reward;
        stakedBalances[msg.sender] = 0;
        stakingStartTimes[msg.sender] = 0;
    }
}
