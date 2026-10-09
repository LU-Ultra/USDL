// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./USDL.sol";
import "./Oracle.sol";
import "./USDLStaking.sol";

error Engine__InvalidAmount();
error Engine__UnsafePositionRatio();
error Engine__NotLiquidatable();
error Engine__InvalidBorrowRate();
error Engine__NotRateController();
error Engine__InsufficientCollateral();
error Engine__TransferFailed();

contract USDLEngine is Ownable {
    uint256 private constant COLLATERAL_RATIO = 150; // 150% collateralization required
    uint256 private constant LIQUIDATOR_REWARD = 10; // 10% reward for liquidators
    uint256 private constant SECONDS_PER_YEAR = 365 days;
    uint256 private constant PRECISION = 1e18;

    USDL private i_usdl;
    Oracle private i_oracle;
    USDLStaking private i_staking;
    address private i_rateController;

    uint256 public borrowRate; // Annual interest rate for borrowers in basis points (1% = 100)

    // Total debt shares in the pool
    uint256 public totalDebtShares;

    // Exchange rate between debt shares and USDL (1e18 precision)
    uint256 public debtExchangeRate;
    uint256 public lastUpdateTime;

    mapping(address => uint256) public s_userCollateral;
    mapping(address => uint256) public s_userDebtShares;

    event CollateralAdded(address indexed user, uint256 indexed amount, uint256 price);
    event CollateralWithdrawn(address indexed withdrawer, uint256 indexed amount, uint256 price);
    event BorrowRateUpdated(uint256 newRate);
    event DebtSharesMinted(address indexed user, uint256 amount, uint256 shares);
    event DebtSharesBurned(address indexed user, uint256 amount, uint256 shares);
    event Liquidation(
        address indexed user,
        address indexed liquidator,
        uint256 amountForLiquidator,
        uint256 liquidatedUserDebt,
        uint256 price
    );

    modifier onlyRateController() {
        if (msg.sender != i_rateController) revert Engine__NotRateController();
        _;
    }

    constructor(
        address _oracle,
        address _usdlAddress,
        address _stakingAddress,
        address _rateController
    ) Ownable(msg.sender) {
        i_oracle = Oracle(_oracle);
        i_usdl = USDL(_usdlAddress);
        i_staking = USDLStaking(_stakingAddress);
        i_rateController = _rateController;
        lastUpdateTime = block.timestamp;
        debtExchangeRate = PRECISION; // 1:1 initially
    }

    // Checkpoint 2: Depositing Collateral & Understanding Value
    function addCollateral() public payable {}

    function calculateCollateralValue(address user) public view returns (uint256) {}

    // Checkpoint 3: Interest Calculation System
    function _getCurrentExchangeRate() internal view returns (uint256) {}

    function _accrueInterest() internal {}

    function _getUSDLToShares(uint256 amount) internal view returns (uint256) {}

    // Checkpoint 4: Minting USDL & Position Health
    function getCurrentDebtValue(address user) public view returns (uint256) {
        uint256 userDebtShares = s_userDebtShares[user];

        if (userDebtShares == 0) {
            return 0;
        }

        uint256 currentExchangeRate = _getCurrentExchangeRate();

        return (userDebtShares * currentExchangeRate) / PRECISION;
    }

    function calculatePositionRatio(address user) public view returns (uint256) {
    uint256 debtValue = getCurrentDebtValue(user);

        if (debtValue == 0) {
            return type(uint256).max;
        }

    uint256 collateralValue = calculateCollateralValue(user);

    return (collateralValue * 100) / debtValue;
    }

    function _validatePosition(address user) internal view {
        if (calculatePositionRatio(user) < COLLATERAL_RATIO) {
            revert Engine__UnsafePositionRatio();
        }
    }

    function mintUSDL(uint256 mintAmount) public {
    if (mintAmount == 0) {
        revert Engine__InvalidAmount();
    }

    _accrueInterest();

    uint256 shares = _getUSDLToShares(mintAmount);

    if (shares == 0) {
        revert Engine__InvalidAmount();
    }

    s_userDebtShares[msg.sender] += shares;
    totalDebtShares += shares;

    _validatePosition(msg.sender);

    bool success = i_usdl.mintTo(msg.sender, mintAmount);
    if (!success) {
        revert Engine__TransferFailed();
    }

    // Checkpoint 5: Accruing Interest & Managing Borrow Rates
    function setBorrowRate(uint256 newRate) external onlyRateController {}

    // Checkpoint 6: Repaying Debt & Withdrawing Collateral
    function repayUpTo(uint256 amount) public {
        if (amount == 0) {
            revert Engine__InvalidAmount();
        }
    
        _accrueInterest();
    
        uint256 userShares = s_userDebtShares[msg.sender];
    
        if (userShares == 0) {
            revert Engine__InvalidAmount();
        }
    
        uint256 currentExchangeRate = debtExchangeRate;
        uint256 currentDebt = (userShares * currentExchangeRate) / PRECISION;
    
        uint256 actualRepayAmount = amount > currentDebt ? currentDebt : amount;
    
        uint256 sharesToBurn;
    
        if (actualRepayAmount == currentDebt) {
            sharesToBurn = userShares;
            actualRepayAmount = currentDebt;
        } else {
            sharesToBurn = (actualRepayAmount * PRECISION) / currentExchangeRate;
    
            if (sharesToBurn == 0) {
                revert Engine__InvalidAmount();
            }
    
            actualRepayAmount = (sharesToBurn * currentExchangeRate) / PRECISION;
        }
    
        s_userDebtShares[msg.sender] -= sharesToBurn;
        totalDebtShares -= sharesToBurn;
    
        i_usdl.burnFrom(msg.sender, actualRepayAmount);
    
        emit DebtSharesBurned(msg.sender, actualRepayAmount, sharesToBurn);
    }

    function withdrawCollateral(uint256 amount) external {
        if (amount == 0) {
            revert Engine__InvalidAmount();
        }
    
        uint256 userCollateral = s_userCollateral[msg.sender];
    
        if (amount > userCollateral) {
            revert Engine__InsufficientCollateral();
        }
    
        s_userCollateral[msg.sender] = userCollateral - amount;
    
        _validatePosition(msg.sender);
    
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert Engine__TransferFailed();
        }
    
        emit CollateralWithdrawn(msg.sender, amount, i_oracle.getETHUSDLPrice());
    }

    // Checkpoint 7: Liquidation - Enforcing System Stability
    function isLiquidatable(address user) public view returns (bool) {}

    function liquidate(address user) external {}
}
