// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

contract EmployeeStorage {
    // SLOT 0: Te dwie zmienne zajmują tylko 5 z 32 bajtów tego slotu
    uint24 private salary; 
    uint16 private shares; 

    // SLOT 1: Zajmuje cały slot (32 bajty)
    uint256 public idNumber; 

    // SLOT 2: String (krótkie napisy są przechowywane bezpośrednio tutaj)
    string public name;

    error TooManyShares(uint16 provided, uint16 limit);

    constructor() {
        name = "Pat";
        idNumber = 112358132134;
        salary = 50000;
        shares = 1000;
    }

    function grantShares(uint16 _newShares) external {
        if (_newShares > 5000) {
            revert TooManyShares(_newShares, 5000);
        }
        shares += _newShares;
    }

    // Pozwala sprawdzić Slot 0, aby zobaczyć spakowane salary i shares
    function checkForPacking(uint _slot) external view returns (uint result) {
        assembly {
            result := sload(_slot)
        }
    }

    function viewEmployeeData() external view returns (uint24 _salary, uint16 _shares) {
        return (salary, shares);
    }

    function debugResetShares() external {
        shares = 1000;
    }
}

}# BL2.1
