// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "forge-std/Test.sol";
import {MockERC20} from "./MockERC20.sol";
import "../AhbapRelayerBNBCHain.sol";

address constant WETH_DEPLOYER = 0x88eFdaC29E3Ba290512E26c04908692Ae9810566;
address constant BSCUSD_DEPLOYER = 0x970609bA2C160a1b491b90867681918BDc9773aF;
address constant WBNB_DEPLOYER = 0x4E656459ed25bF986Eea1196Bc1B00665401645d;
address constant USDC_DEPLOYER = 0xFc19E4Ce0e0a27B09f2011eF0512669A0F76367A;
address constant anyUSDC_DEPLOYER = 0xfA9dA51631268A30Ec3DDd1CcBf46c65FAD99251;
address constant XRP_DEPLOYER = 0x88eFdaC29E3Ba290512E26c04908692Ae9810566;
address constant BUSD_DEPLOYER = 0xF07C30E4CD6cFff525791B4b601bD345bded7f47;

address constant AHBAP_RELAYER_DEPLOYER = 0xF370bc2B249f0CFA542F607a91B08A0207B5BD82;
address constant AHBAP_RELAYER = 0xABAB0cdBf16118f0FE9433e9B66Ce995E0D273c5;

contract AhbapRelayerBNBChainTest is Test {
    AhbapRelayerBNBChain relayer;

    function deploy(
        address deployer,
        IERC20 expectedContract,
        uint64 nonce,
        uint8 decimals,
        uint256 amount,
        string memory symbol
    ) internal {
        if (nonce > 0) vm.setNonce(deployer, nonce);
        vm.prank(deployer);
        MockERC20 token = new MockERC20(symbol, "", decimals);
        token.mint(amount * (10**decimals));
        assertEq(address(token), address(expectedContract));
        console.log(symbol, address(token));
    }

    function setUp() public {
        vm.prank(AHBAP_RELAYER_DEPLOYER);
        relayer = new AhbapRelayerBNBChain();
        assertEq(address(relayer), AHBAP_RELAYER);

        deploy(WETH_DEPLOYER, WETH, 30, 18, 10, "WETH");
        deploy(BSCUSD_DEPLOYER, BSCUSD, 0, 18, 11, "BSCUSD");
        deploy(WBNB_DEPLOYER, WBNB, 2, 18, 12, "WBNB");
        deploy(USDC_DEPLOYER, USDC, 11, 18, 13, "USDC");
        deploy(anyUSDC_DEPLOYER, anyUSDC, 308, 18, 14, "anyUSDC");
        deploy(XRP_DEPLOYER, XRP, 49, 18, 15, "XRP");
        deploy(BUSD_DEPLOYER, BUSD, 4, 18, 16, "BUSD");
    }

    function testBalancesTransferred() external {
        vm.deal(address(this), 9e18);
        vm.deal(AHBAP_BNBCHAIN, 0);

        WETH.transfer(AHBAP_BNBCHAIN, 10e18);
        BSCUSD.transfer(AHBAP_BNBCHAIN, 11e18);
        WBNB.transfer(AHBAP_BNBCHAIN, 12e18);
        USDC.transfer(AHBAP_BNBCHAIN, 13e18);
        anyUSDC.transfer(AHBAP_BNBCHAIN, 14e18);
        XRP.transfer(AHBAP_BNBCHAIN, 15e18);
        BUSD.transfer(AHBAP_BNBCHAIN, 16e18);

        relayer.sweepCommonERC20();

        assertEq(WETH.balanceOf(AHBAP_BNBCHAIN), 10e18);
        assertEq(BSCUSD.balanceOf(AHBAP_BNBCHAIN), 11e18);
        assertEq(WBNB.balanceOf(AHBAP_BNBCHAIN), 12e18);
        assertEq(USDC.balanceOf(AHBAP_BNBCHAIN), 13e18);
        assertEq(anyUSDC.balanceOf(AHBAP_BNBCHAIN), 14e18);
        assertEq(XRP.balanceOf(AHBAP_BNBCHAIN), 15e18);
        assertEq(BUSD.balanceOf(AHBAP_BNBCHAIN), 16e18);

        payable(address(relayer)).transfer(4e18);
        payable(address(relayer)).transfer(5e18);
        relayer.sweepNativeToken();

        assertEq(AHBAP_BNBCHAIN.balance, 9e18);
    }

    function testSelectors() external {
        assertEq(IERC20.balanceOf.selector, bytes4(0x70a08231));
        assertEq(IERC20.transfer.selector, bytes4(0xa9059cbb));
        assertEq(IERC721.transferFrom.selector, bytes4(0x23b872dd));
    }
}
