import styled from "styled-components"

export const Container = styled.div`
  display: flex;
  @media (max-width: 900px) {
    flex-direction: column;
  }
  justify-content: center;
`

export const StyledP = styled.p`
  min-width: 200px;
  margin: 20px 20px 0px 20px;
  @media (max-width: 900px) {
    margin: 10px 10px 0px 10px;
  }
`

export const StyledDiv = styled.div`
  display: flex;
  flex-direction: column;
`

export const InfoSectionDiv = styled.div`
  display: ${(props) => (props.showInfo ? "auto" : "none")};
`

export const StyledImg = styled.img`
  opacity: ${(props) =>
    props.readIsFetching || props.auctionState === 1 ? "0.5" : "1"};
  height: 100%;
  min-width: 320px;
`

export const StyledH3 = styled.h3`
  text-align: center;
`

export const ShowInfoPromt = styled.div`
  padding-top: 10px;
  padding-bottom: 10px;
  text-align: right;
`

// TODO consolidate with the StyledButton in connect.jsx
export const StyledButton = styled.button`
  font-size: 15px;
`
