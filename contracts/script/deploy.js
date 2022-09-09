const { ethers, network } = require("hardhat");
const fs = require("fs");
const readline = require("readline");

// TODO - Pass these in as script arguments
// * CONTRACT_NAME
// * GWEI
// * CONSTRUCTOR_ARGS

// Constants
const CONTRACT_NAME = "LilNounsOracle";
const COMPILER_OUTPUT_PATH =
  "../artifacts/" + CONTRACT_NAME + ".sol/" + CONTRACT_NAME + ".json";
const GWEI = 1000000000;
const TARGET_GAS_PRICE_GWEI = 30;
const TARGET_GAS_PRICE_WEI = ethers.BigNumber.from(
  TARGET_GAS_PRICE_GWEI * GWEI
);
const CONSTRUCTOR_ARGS = [
  "0x55e0F7A3bB39a28Bd7Bcc458e04b3cF00Ad3219E",
  "0xCC8a0FB5ab3C7132c1b2A0109142Fb112c4Ce515",
  "0x11fb55d9580CdBfB83DE3510fF5Ba74309800Ad1",
];

// Helpers
const readlineInterface = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});
const promptUser = (query) =>
  new Promise((resolve) => readlineInterface.question(query, resolve));
const etherscanVerify = (contractAddress, chainId) => {
  console.log("Attempting to verify with etherscan...");
  let command =
    "forge verify-contract" +
    " --chain " +
    chainId +
    ' --constructor-args $(cast abi-encode "constructor(address,address,address)" 0x55e0F7A3bB39a28Bd7Bcc458e04b3cF00Ad3219E 0xCC8a0FB5ab3C7132c1b2A0109142Fb112c4Ce515 0x11fb55d9580CdBfB83DE3510fF5Ba74309800Ad1)' +
    " " +
    contractAddress +
    " src/" +
    CONTRACT_NAME +
    ".sol:" +
    CONTRACT_NAME +
    " $ETHERSCAN_API_KEY";

  console.log("Run this command to verify:\n");
  console.log(command);
  console.log("Then run this to check on verification result:\n");
  console.log("forge verify-check --chain-id " + chainId + " <GUID>");
};

async function main() {
  // Double check with user before deploying to non local network
  const networkName = network.name;
  console.log('Attempting to deploy to network "' + networkName + '"...');
  if (networkName !== "localhost" && networkName !== "hardhat") {
    const response = await promptUser(
      "You are attempting to deploy on a non-local network, " +
        networkName +
        ", " + " with a target gas price of " + TARGET_GAS_PRICE_GWEI + " gwei. " + 
        "Continue? yes/no "
    );
    console.log(response);
    if (response !== "yes") {
      console.log("Aborting deploy due to user input.");
      process.exit(0);
    }
  }

  // Create directories for deployment outputs if necessary
  const outputFolder = "./deployments/" + networkName;
  fs.mkdirSync(outputFolder, { recursive: true });
  const outputPath = outputFolder + "/" + CONTRACT_NAME + ".json";

  // Create contract factory
  const compilerOutput = require(COMPILER_OUTPUT_PATH);
  let factory = ethers.ContractFactory.fromSolidity(compilerOutput);
  const signer = await ethers.getSigner();
  factory = factory.connect(signer);

  // Every block check if the gasEstimate is low enough and deploy if it is
  ethers.provider.on("block", async (blockNumber) => {
    console.log();
    console.log("Block", blockNumber, "mined...");
    const gasPriceEstimateWei = ethers.BigNumber.from(
      await ethers.provider.getGasPrice()
    );
    const gasPriceEstimateGwei = ethers.utils.formatUnits(
      gasPriceEstimateWei,
      "gwei"
    );

    console.log("Current gas price:", gasPriceEstimateGwei, "gwei.");
    console.log("Target gas price: ", TARGET_GAS_PRICE_GWEI, "gwei.");
    if (gasPriceEstimateWei.lte(TARGET_GAS_PRICE_WEI)) {
      console.log("Gas price low enough! Starting deploying...");
      ethers.provider.removeAllListeners("block");

      // Deploy contract
      const deployedContract = await factory.deploy(...CONSTRUCTOR_ARGS);
      console.log(
        "Deployed contract to",
        deployedContract.address + ".",
        "Cost",
        deployedContract.deployTransaction.gasLimit.toString(),
        " gas (",
        ((deployedContract.deployTransaction.gasLimit * gasPriceEstimateGwei) / GWEI).toString(),
        "ether at 10 gwei/gas unit.)"
      );

      // Write out deploy artifacts
      fs.writeFileSync(
        outputPath,
        JSON.stringify({
          address: deployedContract.address,
          abi: compilerOutput.abi,
          compilerOutput: compilerOutput,
        })
      );
      console.log("Wrote deployed data to", outputPath + ".");

      if (networkName !== "localhost" && networkName !== "hardhat") {
        etherscanVerify(deployedContract.address, network.config.chainId);
      }
      process.exit(0);
    }
  });
}

main();
