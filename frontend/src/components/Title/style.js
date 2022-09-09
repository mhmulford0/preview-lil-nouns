import styled from "styled-components"

export const Container = styled.div`
  display: flex;
  justify-content: center;
`

export const StyledH1 = styled.h1`
  font-size: 48px;
  margin-bottom: 0px;
  @media (max-width: 1100px) {
    font-size: 2em;
  }
`

export const Noun3935Img = styled.img`
  width: 57px;
`

export const SubTitle = styled.div`
  font-size: 18px;
  @media (max-width: 1100px) {
    font-size: 16px;
  }
`

export const AuctionStateSpan = styled.span`
  color: ${(props) => {
    switch (props.auctionState) {
      case 0:
        return "purple" // 'AUCTION NOT STARTED' // NOT_STARTED
      case 1:
        return "red" // 'AUCTION ONGOING' // ACTIVE
      case 2:
        return "green" // 'READY' // OVER_NOT_SETTLED
      case 3:
        return "yellow" // OVER_AND_SETTLED
      default:
        return "orange"
    }
  }};
`

// export const AuctionLinkSpan = styled.span`
//   display: ${(props) => ( props.auctionState === 1 ? 'auto' : 'none')};
//   font-size: 18px;
//   font-weight: normal;
//   font-style: italic;
// `
