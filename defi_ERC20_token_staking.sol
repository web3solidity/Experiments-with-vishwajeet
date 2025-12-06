// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract StakingWithPermit is ReentrancyGuard {
    IERC20 public immutable stakingToken;
    IERC20Permit public immutable permitToken;

    mapping(address => uint256) public stakedBalance;
    uint256 public totalStaked;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    constructor(address tokenAddress) {
        stakingToken = IERC20(tokenAddress);
        permitToken = IERC20Permit(tokenAddress); // same address, different ABI
    }

    /**
     * @notice Stake using EIP-2612 permit (no approve() needed)
     */
    function stakeWithPermit(
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        // 1. Permit the contract to pull tokens
        permitToken.permit(
            msg.sender,
            address(this),
            amount,
            deadline,
            v,
            r,
            s
        );

        // 2. Pull tokens after permit is approved
        stakingToken.transferFrom(msg.sender, address(this), amount);

        // 3. Update staking balances
        stakedBalance[msg.sender] += amount;
        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    /**
     * @notice Stake with normal approval (optional fallback)
     */
    function stake(uint256 amount) external nonReentrant {
        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakedBalance[msg.sender] += amount;
        totalStaked += amount;
        emit Staked(msg.sender, amount);
    }

    /**
     * @notice Unstake tokens
     */
    function unstake(uint256 amount) external nonReentrant {
        require(stakedBalance[msg.sender] >= amount, "Not enough staked");

        stakedBalance[msg.sender] -= amount;
        totalStaked -= amount;

        stakingToken.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

        function checkBalance(address user) external view returns (uint256) {
        return stakingToken.balanceOf(user);
    }
}
