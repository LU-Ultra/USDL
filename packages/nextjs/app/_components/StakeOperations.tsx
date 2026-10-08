import React, { useEffect, useState } from "react";
import TooltipInfo from "./TooltipInfo";
import { IntegerInput } from "@scaffold-ui/debug-contracts";
import { parseEther } from "viem";
import { useAccount } from "wagmi";
import { useScaffoldContract, useScaffoldReadContract, useScaffoldWriteContract } from "~~/hooks/scaffold-eth";
import { notification } from "~~/utils/scaffold-eth";

const StakeOperations = () => {
  const { address } = useAccount();
  const [stakeAmount, setStakeAmount] = useState("");
  const [withdrawDisabled, setWithdrawDisabled] = useState(true);

  const { writeContractAsync: writeUSDLContract } = useScaffoldWriteContract({
    contractName: "USDL",
  });

  const { data: usdlCStakingContract } = useScaffoldContract({ contractName: "USDLStaking" });

  const { writeContractAsync: writeStakingContract } = useScaffoldWriteContract({
    contractName: "USDLStaking",
  });

  const { data: shareBalance } = useScaffoldReadContract({
    contractName: "USDLStaking",
    functionName: "userShares",
    args: [address],
  });

  useEffect(() => {
    setWithdrawDisabled(shareBalance === 0n);
  }, [shareBalance]);

  const handleStake = async () => {
    if (!usdlCStakingContract) {
      notification.error("USDLStaking contract not found");
      return;
    }
    try {
      await writeUSDLContract({
        functionName: "approve",
        args: [usdlCStakingContract.address, stakeAmount ? parseEther(stakeAmount) : 0n],
      });

      await writeStakingContract({
        functionName: "stake",
        args: [stakeAmount ? parseEther(stakeAmount) : 0n],
      });
      setStakeAmount("");
    } catch (error) {
      console.error("Error staking:", error);
    }
  };

  const handleWithdraw = async () => {
    try {
      await writeStakingContract({
        functionName: "withdraw",
      });
    } catch (error) {
      console.error("Error withdrawing:", error);
    }
  };

  return (
    <div className="card bg-base-100 w-96 shadow-xl indicator">
      <TooltipInfo top={3} right={3} infoText="Use these controls to stake or unstake USDL" />
      <div className="card-body">
        <h2 className="card-title">Stake Operations (USDL)</h2>

        <div className="form-control">
          <label className="label">
            <span className="label-text">Stake</span>
          </label>
          <div className="flex gap-2 items-center">
            <IntegerInput value={stakeAmount} onChange={setStakeAmount} placeholder="Amount" disableMultiplyBy1e18 />
            <button className="btn btn-sm btn-primary" onClick={handleStake} disabled={!stakeAmount}>
              Stake
            </button>
          </div>
        </div>

        <div className="form-control">
          <label className="label">
            <span className="label-text">Withdraw</span>
          </label>
          <div className="flex gap-2 items-center">
            <button className="btn btn-sm btn-primary" onClick={handleWithdraw} disabled={withdrawDisabled}>
              Withdraw
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default StakeOperations;
