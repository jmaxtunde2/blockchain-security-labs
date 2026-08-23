// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;
    address owner;

    constructor() {
        owner = msg.sender;
    }

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }

    function getCaller() public view returns (address) {
        return msg.sender;
    }

    function reset() public {
        require(msg.sender == owner, "Not Owner");
        number = 0;
    }
}
