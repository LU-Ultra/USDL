# USDL workload

The group fills in `packages/hardhat/contracts/USDLEngine.sol`, then shows that USDL can be minted, repaid, liquidated, and steered back toward $1.

Work in this order. The next person starts only after the previous one has pushed.

| Order | Person | Functions to write | Finished when |
|---|---|---|---|
| 1 | A | `addCollateral`, `calculateCollateralValue` | ETH can be deposited and its dollar value shows on the site |
| 2 | B | `_getCurrentExchangeRate`, `_accrueInterest`, `_getUSDLToShares`, `setBorrowRate` | Debt grows with time, and changing the borrow rate saves the interest already earned |
| 3 | C | `getCurrentDebtValue`, `calculatePositionRatio`, `_validatePosition`, `mintUSDL`, `repayUpTo`, `withdrawCollateral` | A user can mint up to 150%, repay, and withdraw only while the position stays safe |
| 4 | D | `isLiquidatable`, `liquidate`, plus the check that the borrow rate stays at least as high as the savings rate | A second account can repay an unsafe position and take the ETH plus the 10% bonus |
| 5 | E | Run `yarn simulate` and `yarn interest-rate-controller` | The group can show the price falling below $1 and coming back |

Each person, when it is their turn:

```sh
git pull
```

Edit only their functions. Test with `yarn chain`, `yarn deploy`, and `yarn start`, then:

```sh
git add packages/hardhat/contracts/USDLEngine.sol
git commit -m "Implement their part"
git push
```

Only one person edits `USDLEngine.sol` at a time.

## When the project is finished

The coding is finished when all five parts are pushed and one person has pulled the combined code, deployed it, and run the full demo on the local chain:

1. Deposit ETH and mint USDL.
2. Repay and withdraw.
3. Liquidate an unsafe position from a second account.
4. Run the simulation and show the price return toward $1.

Sepolia is only needed if the course asks for a public link. A short demo or written explanation of those four steps is the course hand-in.
