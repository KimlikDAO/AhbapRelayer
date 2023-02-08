import { ethers } from "ethers";
import { readFileSync, writeFileSync } from "fs";
import solc from "solc";

/** @type {!Object<ChainID, !Array<string>>} */
const ChainData = {
  "0xa869": ["api.avax-test.network/ext/bc/C/rpc", "avalanche", "AVAX"],
  "0x1": ["cloudflare-eth.com", "ethereum", "ETH", "Ethereum"],
  "0xa86a": ["api.avax.network/ext/bc/C/rpc", "avalanche", "AVAX", "Avalanche"],
  "0x89": ["polygon-rpc.com", "polygon", "MATIC"],
  "0xa4b1": ["arb1.arbitrum.io/rpc", "ethereum", "ETH"],
  "0x38": ["bsc-dataseed3.binance.org", "binance-coin", "BNB", "BNBChain"],
  "0x406": ["evm.confluxrpc.com", "conflux-network", "CFX"],
  "0xfa": ["rpc.ankr.com/fantom", "fantom", "FTM"],
}

/**
 * @param {ChainID}
 * @return {!Promise<number>}
 */
const getPrice = (chainId) => fetch(`https://api.coincap.io/v2/assets/${ChainData[chainId][1]}`)
  .then((res) => res.json())
  .then((data) => data["data"]["priceUsd"]);

/**
 * @param {ChainID} chainId
 * @param {string} privKey
 * @return {!Promise<void>}
 */
const deployToChain = async (chainId, privKey) => {
  /** @const {!ethers.Provider} */
  const provider = new ethers.JsonRpcProvider("https://" + ChainData[chainId][0]);
  /** @const {!ethers.Wallet} */
  const wallet = new ethers.Wallet(privKey, provider);
  /** @const {string} */
  const deployedAddress = ethers.getCreateAddress({
    from: wallet.address,
    nonce: 0
  });
  /** @const {number} */
  const nonce = await provider.getTransactionCount(wallet.address, "pending");

  console.log(`⛓️  Chain:         ${chainId}`);
  console.log(`📟 Deployer:      ${wallet.address}`);
  console.log(`📜 Contract:      ${deployedAddress}`);
  console.log(`🧮 Nonce:         ${nonce}, ${nonce == 0 ? "👍" : "👎"}`)

  console.log(`🌀 Compiling...   TCKT for ${chainId} and address ${deployedAddress}`);
  const chainName = ChainData[chainId][3];
  const compilerInput = JSON.stringify({
    language: "Solidity",
    sources: {
      "AhbapRelayer.sol": {
        content: readFileSync(`AhbapRelayer${chainName}.sol`, "utf-8")
      }
    },
    settings: {
      optimizer: {
        enabled: true,
        runs: 100_000,
      },
      outputSelection: {
        "AhbapRelayer.sol": {
          "AhbapRelayer": ["abi", "evm.bytecode.object"]
        }
      }
    },
  });
  console.log(`💾 Saving:        ${chainId}.verify.json`);
  writeFileSync(chainId + ".verify.json", compilerInput);

  /** @const {string} */
  const output = solc.compile(compilerInput);
  /** @const {!Object} */
  const solcJson = JSON.parse(output);
  const TCKT = solcJson.contracts["AhbapRelayer.sol"]["AhbapRelayer"];
  console.log(`📏 Binary size:   ${TCKT.evm.bytecode.object.length / 2} bytes`);

  const feeData = await provider.getFeeData();
  console.log(`🏭 Factory:       👍`);
  console.log(`⛽️ Gas price:     ${feeData.gasPrice / 1_000_000_000n}`);
  console.log(feeData);
  if (feeData.maxPriorityFeePerGas)
    console.log(`🫙  Max priority:  ${feeData.maxPriorityFeePerGas / 1_000_000_000n}`);

  const factory = new ethers.ContractFactory(TCKT.abi, TCKT.evm.bytecode.object, wallet);
  const deployTx = await factory.getDeployTransaction();

  /** @const {!bigint} */
  const estimatedGas = await provider.estimateGas(deployTx);
  console.log(`🙀 Gas estimate:  ${estimatedGas.toLocaleString('tr-TR')}`);
  const milliToken = Number(estimatedGas * feeData.gasPrice / 1_000_000_000_000_000n);
  const tokenPrice = await getPrice(chainId);
  const usdValue = ((tokenPrice * milliToken) | 0) / 1000;
  console.log(`💰 Estimated fee: ${milliToken / 1000} ${ChainData[chainId][2]} ` +
    `($${usdValue})        assuming 🪙  = $${tokenPrice}`);

  if (nonce != 0) return;
  const contract = await factory.deploy({
    maxFeePerGas: 25_000_000_000n,
    maxPriorityFeePerGas: 1_000_000_000n
  })
}

deployToChain("0x1", "");
