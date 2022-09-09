import { useState } from "react"
import {
  Container,
  StyledP,
  StyledDiv,
  InfoSectionDiv,
  ShowInfoPromt,
  StyledButton,
  StyledImg,
  StyledH3,
} from "./style"
import MintButton from "./MintButton/mint-button"

const Display = ({
  nounId,
  dataUri,
  nextBlockNumber,
  auctionState,
  readIsFetching,
}) => {
  const [showInfo, setShowInfo] = useState(false)
  const handleShowInfo = () => {
    setShowInfo(true)
  }
  const handleHideInfo = () => {
    setShowInfo(false)
  }

  return (
    <Container>
      <StyledDiv>
        <StyledH3>Next Lil Noun #{nounId.toString()}</StyledH3>
        <StyledImg
          src={dataUri}
          readIsFetching={readIsFetching}
          auctionState={auctionState}
        ></StyledImg>
        <MintButton
          auctionState={auctionState}
          nextBlockNumber={nextBlockNumber}
          readIsFetching={readIsFetching}
        />
        {!showInfo && (
          <ShowInfoPromt>
            What is Preview Lil Nouns?{" "}
            <StyledButton onClick={handleShowInfo}>Show Info</StyledButton>
          </ShowInfoPromt>
        )}
      </StyledDiv>
      <InfoSectionDiv showInfo={showInfo}>
        <StyledDiv>
          <StyledP>
            <b>What is Preview Lil Nouns?</b> Preview is an alternative frontend
            for the <a href="https://lilnouns.wtf">Lil Nouns auction</a> that
            displays the next Lil Noun that would be minted if the auction were
            started in the next block.
          </StyledP>
          <StyledP>
            <b>How do I use it?</b> Watch for good looking Lil Nouns, and if you
            see one worth bidding for, start the auction as quickly as possible.
            Your transaction must be confirmed in the very next block.
          </StyledP>
          <StyledP>
            <b>What if my transaction is confirmed too late?</b> The app uses a
            that proxy{" "}
            <a href="https://etherscan.io/address/0xc0aabf8fbe161225b18e6ad0bd51c060c1e1b5b4">
              contract
            </a>{" "}
            that will revert the transaction if it is processed after the
            intended block. In that case, no auction will start and you will be
            refunded the majority of the gas cost of the transaction.
          </StyledP>
          <StyledP>
            <b>How much does it cost?</b> If your transaction is successful, you
            will pay for the gas to settle the previous auction and start the
            new one. Unsuccessful transactions are ~7 times cheaper because you
            don't pay those gas costs.
          </StyledP>
          <StyledP>
            <b>How does prediction work?</b> Lil Noun traits depend on the{" "}
            <a href="https://github.com/lilnounsDAO/lilnouns-monorepo/blob/363cfd263319a2a5be1c32f464eeda476361e8c8/packages/nouns-contracts/contracts/NounsSeeder.sol#L30">
              {" "}
              noun ID and the hash
            </a>{" "}
            of the previous block at the time the noun is minted. The app can
            predict what the next noun will be, but only within one block.
          </StyledP>
          <StyledP>
            <b>Disclaimer</b> This pre-alpha software is provided as is and
            without warranty. The developers are not liable any claims or
            damages associated your use of the application.
          </StyledP>
          <StyledP>
            Created by <a href="https://twitter.com/nvonpentz">@nvonpentz</a>.
            Code available on{" "}
            <a href="https://etherscan.io/address/0xc0aabf8fbe161225b18e6ad0bd51c060c1e1b5b4">
              Etherscan
            </a>{" "}
            and Github (soon).
          </StyledP>
          <ShowInfoPromt>
            <StyledButton onClick={handleHideInfo}>Hide</StyledButton>
          </ShowInfoPromt>
        </StyledDiv>
      </InfoSectionDiv>
    </Container>
  )
}

export default Display
