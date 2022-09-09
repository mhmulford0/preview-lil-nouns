import {
  useAccount,
  usePrepareContractWrite,
  useContractWrite,
  useWaitForTransaction,
} from "wagmi"
import { StyledDiv, StyledMintButton } from "./style"
import {
  LilNounsOracleAddress,
  LilNounsOracleAbi,
} from "../../../config/contracts/LilNounsOracle"

const getMintButtonText = (waitIsFetching, isConnected) => {
  if (!isConnected) {
    return "Connect an Account to Start Auction"
  }

  if (waitIsFetching) {
    return "Starting Auction..."
  }

  return "Start Auction"
}

const MintButton = ({ auctionState, nextBlockNumber, readIsFetching }) => {
  const { isConnected } = useAccount()
  const {
    config,
    error: prepareError,
    isError: isPrepareError,
  } = usePrepareContractWrite({
    addressOrName: LilNounsOracleAddress,
    contractInterface: LilNounsOracleAbi,
    functionName: "settleCurrentAndCreateNewAuction",
    args: [nextBlockNumber],
  })

  const {
    data,
    error: writeError,
    isError: isWriteError,
    isLoading: isWriteLoading,
    write,
  } = useContractWrite(config)

  const { waitIsFetching, waitIsSuccess } = useWaitForTransaction({
    hash: data?.hash,
  })

  const handleButtonClicked = () => {
    write()
  }

  return (
    <StyledDiv>
      <StyledMintButton
        disabled={
          !write ||
          waitIsFetching ||
          readIsFetching ||
          isWriteLoading ||
          auctionState !== 2
        }
        onClick={handleButtonClicked}
      >
        {getMintButtonText(waitIsFetching, isConnected)}
      </StyledMintButton>
      {waitIsSuccess && (
        <div>
          {" "}
          Successfully started the auction. Now win it auction on{" "}
          <a href="https://lilnouns.wtf">lilnouns.wtf</a>{" "}
        </div>
      )}
      {isPrepareError && auctionState !== 1 && (
        <div>Error preparing transaction: {prepareError?.message}</div>
      )}
      {isWriteError && (
        <div>Error sending transaction: {writeError?.message}</div>
      )}
      {data?.hash && (
        <div>
          {" "}
          View transaction on{" "}
          <a href={`https://etherscan.io/tx/${data?.hash}`}>Etherscan</a>.
        </div>
      )}
    </StyledDiv>
  )
}

export default MintButton
