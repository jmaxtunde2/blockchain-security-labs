//SPDX-Licence-Identifier:MIT
pragma solidity ^0.8.13;

contract SecureVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawal(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient Balance");
        balances[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);
    }
}
