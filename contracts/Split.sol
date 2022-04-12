// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.10 and less than 0.9.0
pragma solidity ^0.8.10;

import "hardhat/console.sol";

contract Split {
    mapping (address => uint256) private balances;
    uint256 private totalShare;
    address public owner;
    uint256 private lastRun;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not allowed");
        _;
    }

    struct Proportion {
        address account;
        uint256 share;
    }

    constructor() {
        owner = msg.sender;
        totalShare = 0;
    }

    Proportion[] private addressList;

    function addToList(address _to, uint _share) external onlyOwner {
        require(_share > 0, "Invalid share");
        require(_to != address(0), "Invalid address");

        addressList.push(Proportion(_to, _share));
        totalShare += _share;
    }

    function getfromList(uint256 _index) private view returns (address _to, uint _share) {
        Proportion storage addressItem = addressList[_index];
        return (addressItem.account, addressItem.share);
    }

    function deposit() external payable {
        uint256 dividend;
        dividend = msg.value;

        if(totalShare > 0) {
            dividend = msg.value / totalShare;
        }
        
        for (uint i = 0; i < addressList.length; i++) {
            Proportion memory addressItem = addressList[i];
            balances[addressItem.account] += addressItem.share * dividend;
        }

        lastRun = block.timestamp;
        console.log("Last Run: ", lastRun);
    }

    function balance(address account) public view returns (uint256) {
        return balances[account];
    }

    function withdraw() external {
        require(block.timestamp - lastRun > 2592000, 'Need to wait 1 month');
        uint256 _balance = balances[msg.sender];
        require(_balance > 0, 'Invailid balance');
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(_balance);
    }

    function testWithdraw(address account) external {
        console.log("Current Time: ", block.timestamp);
        require(block.timestamp - lastRun > 2, 'Need to wait 2 second');
        uint256 _balance = balances[account];
        require(_balance > 0, 'Invailid balance');
        balances[account] = 0;
        payable(account).transfer(_balance);
    }
}