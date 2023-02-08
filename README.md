## AhbapRelayer: Single address to donate to Ahbap, valid on all chains

Donate to [Ahbap](https://twitter.com/ahbap) using a single addresss:

> 0xABAB0cdBf16118f0FE9433e9B66Ce995E0D273c5

The contract deployed at this address transfers all ERC-20 tokens,
native tokens and NFTs to Ahbap addresses in a trustless & permissionless way.

[KimlikDAO](https://kimlikdao.org) will cover all the transfer fees, though
you don't have to trust us. The funds can be moved to Ahbap by _anyone_ by calling
the [`sweepNativeToken()`](https://github.com/KimlikDAO/AhbapRelayer/blob/main/AhbapRelayerEthereum.sol#L42-L44),
[`sweepMultiERC20()`](https://github.com/KimlikDAO/AhbapRelayer/blob/main/AhbapRelayerEthereum.sol#L76-L82), or
[`sweepNFT()`](https://github.com/KimlikDAO/AhbapRelayer/blob/main/AhbapRelayerEthereum.sol#L93-L95) methods.

The funds cannot be moved to anywhere else and the deployer has the same access as anyone (can only trigger the sweep methods, which transfers assets to Ahbap).

Currently deployed on Ethereum, Avalanche and BNB Chain.


| Chain             |   Link   |
|-------------------|----------|
| Ethereum | https://etherscan.io/address/0xABAB0cdBf16118f0FE9433e9B66Ce995E0D273c5#code |
| Avalanche | https://snowtrace.io/address/0xABAB0cdBf16118f0FE9433e9B66Ce995E0D273c5#code |
| BNB Chain | https://bscscan.com/address/0xABAB0cdBf16118f0FE9433e9B66Ce995E0D273c5#code |


We have requested addresses on other chains and simultaneously testing a
[Synapse](https://synapseprotocol.com) Bridge contract to deploy on chains where
Ahbap does not have a wallet.
