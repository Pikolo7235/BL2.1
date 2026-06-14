// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract EmployeeStorage {
    // --- STORAGE ---
    // SLOT 0: Maksymalnie upakowany (Często modyfikowane dane w jednej transakcji)
    // Kolejność od góry do dołu = od prawej do lewej w pamięci (Little Endian)
    uint16 private shares = 1000;      // 2 bajty (offset: 0)
    uint24 private salary = 50000;     // 3 bajty (offset: 16 bitów = 2 bajty)
    uint32 private lastBonusDate;      // 4 bajty (offset: 40 bitów = 5 bajtów)
    address public manager;            // 20 bajtów (offset: 72 bity = 9 bajtów)
    // ŁĄCZNIE W SLOT 0: 2 + 3 + 4 + 20 = 29 z 32 dostępnych bajtów.

    // SLOT 1
    uint256 public idNumber;

    // SLOT 2
    string public name;

    // --- EVENTY (Najtańsze logowanie zdarzeń) ---
    event SharesGranted(uint16 indexed totalShares);
    event SalaryUpdated(uint24 indexed newSalary);

    // --- MODYFIKATORY ---
    modifier onlyManager() {
        require(msg.sender == manager, "Brak uprawnien: Tylko Manager");
        _;
    }

    // --- CONSTRUCTOR ---
    constructor(uint256 _id, string memory _name, address _manager) {
        idNumber = _id;
        name = _name;
        manager = _manager;
    }

    // --- FUNKCJE BIZNESOWE ---

    /**
     * @notice Przyznaje nowe udziały pracownikowi.
     * @dev Optymalizacja: Od Solidity 0.8.0 Math overflow jest sprawdzany automatycznie.
     * Usunięto zbędne rzutowanie uint32 dla oszczędności gasu.
     */
    function grantShares(uint16 _newShares) external onlyManager {
        uint16 currentShares = shares;
        require(currentShares + _newShares <= 5000, "Limit 5000");
        
        shares = currentShares + _newShares;
        emit SharesGranted(shares);
    }

    /**
     * @notice Aktualizuje pensję i zapisuje datę ostatniego bonusu w obrębie tego samego Slotu 0.
     * @dev Wykonuje tylko jedną operację SSTORE (modyfikacja dwóch zmiennych naraz).
     */
    function updateSalaryAndBonus(uint24 _newSalary) external onlyManager {
        salary = _newSalary;
        lastBonusDate = uint32(block.timestamp);
        emit SalaryUpdated(_newSalary);
    }

    // --- ZAAWANSOWANE FUNKCJE LOW-LEVEL (YUL) ---

    // Zwraca spakowany SLOT 0 w czytelnym formacie HEX
    function checkSlotZero() external view returns (bytes32 result) {
        assembly { 
            result := sload(0) 
        }
    }

    /**
     * @notice Pobiera wartość salary bezpośrednio ze Slotu 0 za pomocą Inline Assembly.
     * @dev Najbardziej efektywny sposób czytania spakowanych danych bez narzutu Solidity.
     */
    function getSalaryUsingAssembly() external view returns (uint24 res) {
        assembly {
            // 1. Pobierz cały slot 0 (32 bajty)
            let slot0 := sload(0)
            
            // 2. Przesuń bity w prawo (bit-shift) o 16 bitów, aby usunąć 'shares' (uint16)
            let shifted := shr(16, slot0)
            
            // 3. Zastosuj maskę bitową dla typu uint24 (0xffffff), aby odciąć resztę starszych bitów
            res := and(shifted, 0xffffff)
        }
    }

    // Zwykły podgląd danych z poziomu Solidity
    function viewEmployeeData() external view returns (uint24, uint16, uint32, address) {
        return (salary, shares, lastBonusDate, manager);
    }
}
