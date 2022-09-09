import {
  // AuctionLinkSpan,
  AuctionStateSpan,
  Container,
  SubTitle,
  StyledH1,
} from "./style"

const getTextForAuctionState = (auctionState) => {
  return "DOWN FOR MAINTENANCE"
  // switch (auctionState) {
  //   case 0:
  //     return "AUCTION NOT STARTED" // NOT_STARTED
  //   case 1:
  //     return "AUCTION ONGOING" // ACTIVE
  //   case 2:
  //     return "AUCTION READY" // OVER_NOT_SETTLED
  //   case 3:
  //     return "AUCTION OVER" // OVER_AND_SETTLED
  //   default:
  //     return "AUCTION STATUS UNKNOWN"
  // }
}

const Title = ({ auctionState }) => {
  return (
    <div>
      <Container>
        <StyledH1>Preview Lil Nouns</StyledH1>
      </Container>
      <Container>
        <SubTitle>Preview the next Lil Noun before minting it.</SubTitle>
      </Container>
      <Container>
        <h2>
          <AuctionStateSpan auctionState={auctionState}>
            {" "}
            {getTextForAuctionState(auctionState)}{" "}
          </AuctionStateSpan>
          {/* <AuctionLinkSpan auctionState={auctionState}><a href="http://lilnouns.wtf">go to auction</a></AuctionLinkSpan> */}
        </h2>
      </Container>
    </div>
  )
}

export default Title
