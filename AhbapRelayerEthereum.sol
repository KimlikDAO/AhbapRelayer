// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

// Ahbap Ethereum address.
// See https://twitter.com/ahbap/status/1622963311514996739?s=20&t=-cK1P2pUhc-FtTQUWW1Lew
address payable constant AHBAP_ETHEREUM = payable(
    0xe1935271D1993434A1a59fE08f24891Dc5F398Cd
);

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
}

interface IERC721 {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;
}

// The top 8 tokens on Ethereum by market cap according to etherscan.io
IERC20 constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
IERC20 constant BNB = IERC20(0xB8c77482e45F1F44dE1745F52C74426C631bDD52);
IERC20 constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
IERC20 constant BUSD = IERC20(0x4Fabb145d64652a948d72533023f6E7A623C7C53);
IERC20 constant OKB = IERC20(0x75231F58b43240C9718Dd58B4967c5114342a86c);
IERC20 constant MATIC = IERC20(0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0);
IERC20 constant SHIB = IERC20(0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE);
IERC20 constant stETH = IERC20(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);

/**
 * Sends all BNB and ERC-20 tokens sent to this address to `AHBAP_ETHEREUM`.
 * There is limited support for NFTs, proceed with caution.
 */
contract AhbapRelayerEthereum {
    receive() external payable {}

    function sweepNativeToken() external {
        AHBAP_ETHEREUM.transfer(address(this).balance);
    }

    /**
     * Transfers the entire balance of a select list of tokens to
     * AHBAP_ETHEREUM.
     *
     * The list is obtained by sorting the token by market cap on
     * snowtrace.io an taking the top 8.
     *
     * For other tokens use `sweepMultiERC20()` or `sweepSingleERC20()` methods.
     */
    function sweepCommonERC20() external {
        USDT.transfer(AHBAP_ETHEREUM, USDT.balanceOf(address(this)));
        BNB.transfer(AHBAP_ETHEREUM, BNB.balanceOf(address(this)));
        USDC.transfer(AHBAP_ETHEREUM, USDC.balanceOf(address(this)));
        BUSD.transfer(AHBAP_ETHEREUM, BUSD.balanceOf(address(this)));
        OKB.transfer(AHBAP_ETHEREUM, OKB.balanceOf(address(this)));
        MATIC.transfer(AHBAP_ETHEREUM, MATIC.balanceOf(address(this)));
        SHIB.transfer(AHBAP_ETHEREUM, SHIB.balanceOf(address(this)));
        stETH.transfer(AHBAP_ETHEREUM, stETH.balanceOf(address(this)));
    }

    /**
     * Transfers the entire balance of the given 5 tokens to
     * `AHBAP_ETHEREUM`.
     *
     * If you have fewer than 5 tokens, pad the remainder with, say, WAVAX so
     * the transaction doesn't revert.
     *
     * @param tokens A list of ERC20 contract addresses whose balance wil be
     *               sent to `AHBAP_ETHEREUM`.
     */
    function sweepMultiERC20(IERC20[5] calldata tokens) external {
        tokens[0].transfer(AHBAP_ETHEREUM, tokens[0].balanceOf(address(this)));
        tokens[1].transfer(AHBAP_ETHEREUM, tokens[1].balanceOf(address(this)));
        tokens[2].transfer(AHBAP_ETHEREUM, tokens[2].balanceOf(address(this)));
        tokens[3].transfer(AHBAP_ETHEREUM, tokens[3].balanceOf(address(this)));
        tokens[4].transfer(AHBAP_ETHEREUM, tokens[4].balanceOf(address(this)));
    }

    /**
     * Transfers the entire balance of the given token to `AHBAP_ETHEREUM`.
     *
     * @param token Contract addres of the token to move
     */
    function sweepSingleERC20(IERC20 token) external {
        token.transfer(AHBAP_ETHEREUM, token.balanceOf(address(this)));
    }

    function sweepNFT(IERC721 nft, uint256 tokenId) external {
        nft.transferFrom(address(this), AHBAP_ETHEREUM, tokenId);
    }
}
