import styled from "styled-components"

export const LayoutContainer = styled.div`
  display: flex;
  font-size: 18px;
`

export const LayoutItem = styled.div`
  width: 20%;
  @media (max-width: 900px) {
    margin-left: auto;
    margin-right: auto;
    flex-direction: column;
  }
`

export const LayoutItemContent = styled.div`
  display: flex;
  justify-content: center;
  flex-direction: row;
  flex-grow: 1;
`

export const ContentContainer = styled.div`
  display: flex;
  justify-content: center;
  flex-direction: column;
  flex-grow: 1;
  max-width: 1320px;
`
