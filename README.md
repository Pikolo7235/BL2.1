// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

contract EmployeeStorage {
    string public name;
    uint public idNumber;

    uint24 private salary;
    uint16 private shares;

    constructor() {
        name = "Pat";
        idNumber = 112358132134;
        salary = 50000;
        shares = 1000;
    }

    function grantShares(uint16 _newShares) external {
        require(_newShares <= 5000, "Too many shares");
        shares += _newShares;
    }

    function checkForPacking(uint _slot) external view returns (uint result) {
        assembly {
            result := sload(_slot)
        }
    }

    function viewShares() external view returns (uint16) {
        return shares;
    }

    function viewSalary() external view returns (uint24) {
        return salary;
    }

    function debugResetShares() external {
        shares = 1000;
    }
}# BL2.1
