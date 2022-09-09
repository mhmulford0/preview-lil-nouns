import { useAccount, useConnect, useDisconnect, useEnsName } from "wagmi"
import { AddressSpan, StyledButton } from "./style"

export function Connect() {
  const { address, isConnected } = useAccount()
  const { data: ensName } = useEnsName({ address })
  const { connect, connectors, error, isLoading } = useConnect()
  const injectedConnector = connectors[0]
  const { disconnect } = useDisconnect()

  if (isConnected) {
    return (
      <div>
        <span>
          <b>Account</b>:{" "}
        </span>
        <AddressSpan>
          {ensName ? `${ensName} (${address})` : address}{" "}
        </AddressSpan>
        <StyledButton onClick={disconnect}>Disconnect</StyledButton>
      </div>
    )
  }

  return (
    <div>
      <span>
        <b>Account</b>: Not connected.{" "}
      </span>
      <StyledButton
        disabled={!injectedConnector.ready}
        onClick={() => connect({ connector: injectedConnector })}
      >
        {!isLoading && "Connect"}
        {!injectedConnector.ready && " (unsupported)"}
        {isLoading && "Connecting..."}
      </StyledButton>

      {error && <div>{error.message}</div>}
    </div>
  )
}

export default Connect
