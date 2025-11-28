Struct definitions
    struct Stake {
        uint256 amount;
        uint256 timestamp;
        uint256 lockPeriod;
        uint256 rewardRate;
        bool active;
    }
    
    struct FlashLoan {
        address borrower;
        uint256 amount;
        uint256 fee;
        uint256 timestamp;
        bool repaid;
    }
    
    0.09% fee
    uint256 public constant FEE_DENOMINATOR = 10000;
    
    address public owner;
    bool public protocolActive;
    
    Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    modifier protocolIsActive() {
        require(protocolActive, "Protocol is paused");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        protocolActive = true;
    }
    
    /**
     * @dev Function 1: Stake tokens with specified lock period
     * @param lockPeriod Duration in seconds to lock the stake
     */
    function stake(uint256 lockPeriod) external payable protocolIsActive {
        require(msg.value > 0, "Stake amount must be greater than 0");
        require(lockPeriod >= 1 days, "Lock period must be at least 1 day");
        
        uint256 rewardRate = calculateRewardRate(lockPeriod);
        
        Stake memory newStake = Stake({
            amount: msg.value,
            timestamp: block.timestamp,
            lockPeriod: lockPeriod,
            rewardRate: rewardRate,
            active: true
        });
        
        userStakes[msg.sender].push(newStake);
        totalStaked[msg.sender] += msg.value;
        totalProtocolStake += msg.value;
        
        emit Staked(msg.sender, msg.value, lockPeriod);
    }
    
    /**
     * @dev Function 2: Unstake tokens after lock period expires
     * @param stakeIndex Index of the stake in user's stakes array
     */
    function unstake(uint256 stakeIndex) external protocolIsActive {
        require(stakeIndex < userStakes[msg.sender].length, "Invalid stake index");
        
        Stake storage userStake = userStakes[msg.sender][stakeIndex];
        require(userStake.active, "Stake already withdrawn");
        require(block.timestamp >= userStake.timestamp + userStake.lockPeriod, "Lock period not expired");
        
        uint256 reward = calculateReward(userStake);
        uint256 totalAmount = userStake.amount + reward;
        
        userStake.active = false;
        totalStaked[msg.sender] -= userStake.amount;
        totalProtocolStake -= userStake.amount;
        
        require(address(this).balance >= totalAmount, "Insufficient contract balance");
        payable(msg.sender).transfer(totalAmount);
        
        emit Unstaked(msg.sender, userStake.amount, reward);
    }
    
    /**
     * @dev Function 3: Calculate rewards for a specific stake
     * @param userStake The stake to calculate rewards for
     * @return reward The calculated reward amount
     */
    function calculateReward(Stake memory userStake) public view returns (uint256) {
        uint256 stakeDuration = block.timestamp - userStake.timestamp;
        if (stakeDuration > userStake.lockPeriod) {
            stakeDuration = userStake.lockPeriod;
        }
        
        uint256 reward = (userStake.amount * userStake.rewardRate * stakeDuration) / (365 days * 100);
        return reward;
    }
    
    /**
     * @dev Function 4: Calculate reward rate based on lock period
     * @param lockPeriod The lock period duration
     * @return rate The reward rate percentage
     */
    function calculateRewardRate(uint256 lockPeriod) public pure returns (uint256) {
        if (lockPeriod >= 365 days) {
            return 15; 10% APY
        } else if (lockPeriod >= 90 days) {
            return 7; 5% APY
        } else {
            return 3; Refund excess amount
        if (msg.value > totalRepayment) {
            payable(msg.sender).transfer(msg.value - totalRepayment);
        }
        
        emit FlashLoanRepaid(loanId, loan.fee);
    }
    
    /**
     * @dev Function 7: Get user's active stakes
     * @param user Address of the user
     * @return stakes Array of user's stakes
     */
    function getUserStakes(address user) external view returns (Stake[] memory) {
        return userStakes[user];
    }
    
    /**
     * @dev Function 8: Get total pending rewards for a user
     * @param user Address of the user
     * @return totalRewards Total pending rewards
     */
    function getPendingRewards(address user) external view returns (uint256) {
        uint256 totalRewards = 0;
        Stake[] memory stakes = userStakes[user];
        
        for (uint256 i = 0; i < stakes.length; i++) {
            if (stakes[i].active) {
                totalRewards += calculateReward(stakes[i]);
            }
        }
        
        return totalRewards;
    }
    
    /**
     * @dev Function 9: Fund the reward pool (owner or anyone can contribute)
     */
    function fundRewardPool() external payable {
        require(msg.value > 0, "Must send ETH to fund pool");
        rewardPool += msg.value;
        emit RewardPoolFunded(msg.value);
    }
    
    /**
     * @dev Function 10: Emergency pause/unpause protocol (owner only)
     * @param status True to activate, false to pause
     */
    function setProtocolStatus(bool status) external onlyOwner {
        protocolActive = status;
    }
    
    Fallback function
    fallback() external payable {
        rewardPool += msg.value;
    }
}
// 
Contract End
// 
