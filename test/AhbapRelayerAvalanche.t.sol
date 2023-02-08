// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "forge-std/Test.sol";
import {MockERC20} from "./MockERC20.sol";
import "../AhbapRelayerAvalanche.sol";

address constant USDTe_DEPLOYER = 0x50Ff3B278fCC70ec7A9465063d68029AB460eA04;
address constant USDT_DEPLOYER = 0x503560430E4b5814Dda09Ac789C3508Bb41b24B2;
address constant USDCe_DEPLOYER = USDTe_DEPLOYER;
address constant USDC_DEPLOYER = 0xcb9968Cb0d6612e1167e445774997C63a0792dbF;
address constant BUSDe_DEPLOYER = USDTe_DEPLOYER;
address constant BUSD_DEPLOYER = 0xf537880c505BfA7cdA6c8c49D7efa53D45b52D40;
address constant SHIBe_DEPLOYER = USDTe_DEPLOYER;
address constant WAVAX_DEPLOYER = 0x808cE8deC9E10beD8d0892aCEEf9F1B8ec2F52Bd;

address constant AHBAP_RELAYER_DEPLOYER = 0xF370bc2B249f0CFA542F607a91B08A0207B5BD82;
address constant AHBAP_RELAYER = 0xABAB0cdBf16118f0FE9433e9B66Ce995E0D273c5;

contract AhbapRelayerAvalancheTest is Test {
    AhbapRelayerAvalanche relayer;

    function deploy(
        address deployer,
        IERC20 expectedContract,
        uint64 nonce,
        uint8 decimals,
        uint256 amount,
        string memory symbol
    ) internal {
        vm.setNonce(deployer, nonce);
        vm.prank(deployer);
        MockERC20 token = new MockERC20(symbol, "", decimals);
        token.mint(amount * (10**decimals));
        assertEq(address(token), address(expectedContract));
        console.log(symbol, address(token));
    }

    function setUp() public {
        vm.prank(AHBAP_RELAYER_DEPLOYER);
        relayer = new AhbapRelayerAvalanche();
        assertEq(address(relayer), AHBAP_RELAYER);

        deploy(BUSDe_DEPLOYER, BUSDe, 95, 18, 14, "BUSD.e");
        deploy(BUSD_DEPLOYER, BUSD, 2, 18, 15, "BUSD");
        deploy(USDTe_DEPLOYER, USDTe, 106, 6, 10, "USDT.e");
        deploy(USDT_DEPLOYER, USDT, 2, 6, 11, "USDt");
        deploy(USDCe_DEPLOYER, USDCe, 44526, 6, 12, "USDC.e");
        deploy(USDC_DEPLOYER, USDC, 4, 6, 13, "USDC");
        deploy(SHIBe_DEPLOYER, SHIBe, 334102, 18, 16, "SHIB.e");
        deploy(WAVAX_DEPLOYER, WAVAX, 48, 18, 17, "WAVAX");
    }

    function testBalancesTransferred() external {
        vm.deal(address(this), 9e18);
        vm.deal(AHBAP_AVALANCHE, 0);

        USDTe.transfer(AHBAP_AVALANCHE, 10e6);
        USDT.transfer(AHBAP_AVALANCHE, 11e6);
        USDCe.transfer(AHBAP_AVALANCHE, 12e6);
        USDC.transfer(AHBAP_AVALANCHE, 13e6);
        BUSDe.transfer(AHBAP_AVALANCHE, 14e18);
        BUSD.transfer(AHBAP_AVALANCHE, 15e18);
        SHIBe.transfer(AHBAP_AVALANCHE, 16e18);
        WAVAX.transfer(AHBAP_AVALANCHE, 17e18);
        relayer.sweepCommonERC20();

        assertEq(USDTe.balanceOf(AHBAP_AVALANCHE), 10e6);
        assertEq(USDT.balanceOf(AHBAP_AVALANCHE), 11e6);
        assertEq(USDCe.balanceOf(AHBAP_AVALANCHE), 12e6);
        assertEq(USDC.balanceOf(AHBAP_AVALANCHE), 13e6);
        assertEq(BUSDe.balanceOf(AHBAP_AVALANCHE), 14e18);
        assertEq(BUSD.balanceOf(AHBAP_AVALANCHE), 15e18);
        assertEq(SHIBe.balanceOf(AHBAP_AVALANCHE), 16e18);
        assertEq(WAVAX.balanceOf(AHBAP_AVALANCHE), 17e18);

        payable(address(relayer)).transfer(4e18);
        payable(address(relayer)).transfer(5e18);
        relayer.sweepNativeToken();

        assertEq(AHBAP_AVALANCHE.balance, 9e18);
    }

    function testSelectors() external {
        assertEq(IERC20.balanceOf.selector, bytes4(0x70a08231));
        assertEq(IERC20.transfer.selector, bytes4(0xa9059cbb));
        assertEq(IERC721.transferFrom.selector, bytes4(0x23b872dd));
    }
}
