// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "forge-std/Test.sol";
import {MockERC20} from "./MockERC20.sol";
import "../AhbapRelayerEthereum.sol";

address constant USDT_DEPLOYER = 0x36928500Bc1dCd7af6a2B4008875CC336b927D57;
address constant BNB_DEPLOYER = 0x00C5E04176d95A286fccE0E68c683Ca0bfec8454;
address constant USDC_DEPLOYER = 0x95Ba4cF87D6723ad9C0Db21737D862bE80e93911;
address constant BUSD_DEPLOYER = 0x1074253202528777561f83817d413e91BFa671d4;
address constant OKB_DEPLOYER = 0x4A164CA582D169f7caad471250991Dd861ddA981;
address constant MATIC_DEPLOYER = 0x78655080b65f42E2ceE5FA5673689CC44D4E1cFC;
address constant SHIB_DEPLOYER = 0xB8f226dDb7bC672E27dffB67e4adAbFa8c0dFA08;
address constant HEX_DEPLOYER = 0x896f23373667274e8647b99033c2a8461ddD98CC;

address constant AHBAP_RELAYER_DEPLOYER = 0xF370bc2B249f0CFA542F607a91B08A0207B5BD82;
address constant AHBAP_RELAYER = 0xABAB0cdBf16118f0FE9433e9B66Ce995E0D273c5;

contract AhbapRelayerEthereumTest is Test {
    AhbapRelayer relayer;

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
        relayer = new AhbapRelayer();
        assertEq(address(relayer), AHBAP_RELAYER);

        deploy(USDT_DEPLOYER, USDT, 6, 6, 10, "USDT");
        deploy(BNB_DEPLOYER, BNB, 0, 18, 11, "BNB");
        deploy(USDC_DEPLOYER, USDC, 20, 6, 12, "USDC");
        deploy(BUSD_DEPLOYER, BUSD, 1, 18, 13, "BUSD");
        deploy(OKB_DEPLOYER, OKB, 0, 18, 14, "OKB");
        deploy(MATIC_DEPLOYER, MATIC, 5, 18, 15, "MATIC");
        deploy(SHIB_DEPLOYER, SHIB, 83, 18, 16, "SHIB");
        deploy(HEX_DEPLOYER, HEX, 1, 8, 17, "HEX");
    }

    function testBalancesTransferred() external {
        vm.deal(address(this), 9e18);
        vm.deal(AHBAP_ETHEREUM, 0);

        USDT.transfer(AHBAP_ETHEREUM, 10e6);
        BNB.transfer(AHBAP_ETHEREUM, 11e18);
        USDC.transfer(AHBAP_ETHEREUM, 12e6);
        BUSD.transfer(AHBAP_ETHEREUM, 13e18);
        OKB.transfer(AHBAP_ETHEREUM, 14e18);
        MATIC.transfer(AHBAP_ETHEREUM, 15e18);
        SHIB.transfer(AHBAP_ETHEREUM, 16e18);
        HEX.transfer(AHBAP_ETHEREUM, 17e8);

        relayer.sweepCommonERC20();

        assertEq(USDT.balanceOf(AHBAP_ETHEREUM), 10e6);
        assertEq(BNB.balanceOf(AHBAP_ETHEREUM), 11e18);
        assertEq(USDC.balanceOf(AHBAP_ETHEREUM), 12e6);
        assertEq(BUSD.balanceOf(AHBAP_ETHEREUM), 13e18);
        assertEq(OKB.balanceOf(AHBAP_ETHEREUM), 14e18);
        assertEq(MATIC.balanceOf(AHBAP_ETHEREUM), 15e18);
        assertEq(SHIB.balanceOf(AHBAP_ETHEREUM), 16e18);
        assertEq(HEX.balanceOf(AHBAP_ETHEREUM), 17e8);

        payable(address(relayer)).transfer(4e18);
        payable(address(relayer)).transfer(5e18);
        relayer.sweepNativeToken();

        assertEq(AHBAP_ETHEREUM.balance, 9e18);
    }

    function testSelectors() external {
        assertEq(IERC20.balanceOf.selector, bytes4(0x70a08231));
        assertEq(IERC20.transfer.selector, bytes4(0xa9059cbb));
        assertEq(IERC721.transferFrom.selector, bytes4(0x23b872dd));
    }
}
