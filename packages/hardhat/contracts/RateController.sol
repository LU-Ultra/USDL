// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./USDLStaking.sol";

error Engine__InvalidBorrowRate();

contract RateController {
    IUSDLEngine private i_usdl;
    USDLStaking private i_staking;

    constructor(address _usdl, address _staking) {
        i_usdl = IUSDLEngine(_usdl);
        i_staking = USDLStaking(_staking);
    }

    /**
     * @notice Set the borrow rate for the USDL engine
     * @param newRate The new borrow rate to set
     */
    function setBorrowRate(uint256 newRate) external {
        try i_usdl.setBorrowRate(newRate) {} catch {
            revert Engine__InvalidBorrowRate();
        }
    }

    /**
     * @notice Set the savings rate for the USDL staking contract
     * @param newRate The new savings rate to set
     */
    function setSavingsRate(uint256 newRate) external {
        try i_staking.setSavingsRate(newRate) {} catch {
            revert Staking__InvalidSavingsRate();
        }
    }
}
