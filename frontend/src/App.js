import {
  LayoutContainer,
  LayoutItem,
  LayoutItemContent,
  ContentContainer
} from "./style"
import { BigNumber } from "ethers"
import { useContractRead } from "wagmi"
import { useState, useEffect } from "react"
import Title from "./components/Title/title"
import Connect from "./components/Connect/connect"
import Display from "./components/Display/display"
import {
  LilNounsOracleAddress,
  LilNounsOracleAbi,
} from "./config/contracts/LilNounsOracle"

const App = () => {
  const [dataUri, setDataUri] = useState("#")
  const [auctionState, setAuctionState] = useState(undefined)
  const [readIsFetching, setReadIsFetching] = useState(true)
  const [blockNumber, setBlockNumber] = useState(BigNumber.from(0))
  const [nounId, setNounId] = useState(BigNumber.from(0))
  const { data, isFetching: isReadFetchingUpdated } = useContractRead({
    addressOrName: LilNounsOracleAddress,
    contractInterface: LilNounsOracleAbi,
    functionName: "fetchNextNounAndAuctionState",
    watch: true,
    overrides: { blockTag: "pending" },
  })

  useEffect(() => {
    setReadIsFetching(isReadFetchingUpdated)
    if (data) {
      setNounId(data[1])
      setAuctionState(data[3])
      setDataUri("data:image/svg+xml;base64," + data[2])
      setBlockNumber(data[0])
    }
  }, [data, isReadFetchingUpdated])

  return (
    <LayoutContainer>
      <LayoutItem />
      <LayoutItemContent>
        <ContentContainer className="App">
          <Title auctionState={auctionState} />
          <Connect />
          <div>
            <b>Next Block</b>: {blockNumber.toString()}{" "}
            {readIsFetching && "(updating...)"}{" "}
          </div>
          <Display
            nounId={nounId}
            dataUri={dataUri}
            nextBlockNumber={blockNumber}
            auctionState={auctionState}
            readIsFetching={readIsFetching}
          />
        </ContentContainer>
      </LayoutItemContent>
      <LayoutItem />
    </LayoutContainer>
  )
}

export default App
