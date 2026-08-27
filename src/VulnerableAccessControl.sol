// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VulnerableAccessControl {
    
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }

    function withdrawal(address payable recipient, uint256 amount) external{
        require(
            msg.sender == owner,
            "Not owner"
        );

        recipient.transfer(amount);
    }

    function changeOwner(address newOwner) external{
        require(
            msg.sender == owner,
            "Not owner"
        );

        owner = newOwner;
    }

    receive() external payable{}
}