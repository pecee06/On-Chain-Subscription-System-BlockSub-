
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BlockSub {
    struct Subscription {
        uint256 amount;
        uint256 renewalPeriod;
        uint256 nextPayment;
        bool isActive;
    }

    mapping(address => Subscription) public subscriptions;
    address public owner;

    event Subscribed(address indexed user, uint256 amount, uint256 renewalPeriod);
    event Renewed(address indexed user, uint256 nextPayment);
    event Cancelled(address indexed user);

    constructor() {
        owner = msg.sender;
    }

    // Subscribe to a plan
    function subscribe(uint256 _renewalPeriod) external payable {
        require(msg.value > 0, "Subscription fee required");
        require(_renewalPeriod > 0, "Invalid renewal period");

        subscriptions[msg.sender] = Subscription({
            amount: msg.value,
            renewalPeriod: _renewalPeriod,
            nextPayment: block.timestamp + _renewalPeriod,
            isActive: true
        });

        emit Subscribed(msg.sender, msg.value, _renewalPeriod);
    }

    // Renew Subscription
    function renew() external payable {
        Subscription storage sub = subscriptions[msg.sender];
        require(sub.isActive, "No active subscription");
        require(msg.value == sub.amount, "Incorrect renewal amount");
        require(block.timestamp >= sub.nextPayment, "Too early to renew");

        sub.nextPayment = block.timestamp + sub.renewalPeriod;
        emit Renewed(msg.sender, sub.nextPayment);
    }

    // Cancel Subscription
    function cancel() external {
        Subscription storage sub = subscriptions[msg.sender];
        require(sub.isActive, "No active subscription");

        sub.isActive = false;
        emit Cancelled(msg.sender);
    }
}
