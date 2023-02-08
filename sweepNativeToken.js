import { ethers } from "ethers";

const AHBAP_RELAYER_ABI = [
  "function sweepNativeToken() external",
];

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

const sweepNativeToken = async (chainId, privKey) => {
  /** @const {!ethers.Provider} */
  const provider = new ethers.JsonRpcProvider("https://" + ChainData[chainId][0]);
  /** @const {!ethers.Wallet} */
  const wallet = new ethers.Wallet(privKey, provider);

  const ahbapRelayer = new ethers.Contract(
    "0xABAB0cdBf16118f0FE9433e9B66Ce995E0D273c5", AHBAP_RELAYER_ABI, wallet);

  const options = {
    gasLimit: 120_000,
    type: 2,
    maxFeePerGas: 25_000_000_000n,
    maxPriorityFeePerGas: 1_000_000_000n,
    accessList: [{
      address: "0xfb1bffc9d739b8d520daf37df666da4c687191ea",
      storageKeys: []
    }, {
      address: "0x868D27c361682462536DfE361f2e20B3A6f4dDD8",
      storageKeys: [
        "0x0000000000000000000000000000000000000000000000000000000000000000"
      ]
    }]
  }
  await ahbapRelayer.sweepNativeToken(options);
}

sweepNativeToken("0xa86a", "");
