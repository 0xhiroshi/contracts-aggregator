// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Script} from "forge-std/Script.sol";
import {ERC20EnabledLooksRareAggregator} from "../../contracts/ERC20EnabledLooksRareAggregator.sol";
import {LooksRareAggregator} from "../../contracts/LooksRareAggregator.sol";
import {LooksRareProxy} from "../../contracts/proxies/LooksRareProxy.sol";
import {LooksRareV2Proxy} from "../../contracts/proxies/LooksRareV2Proxy.sol";
import {SeaportProxy} from "../../contracts/proxies/SeaportProxy.sol";
import {IImmutableCreate2Factory} from "../../contracts/interfaces/IImmutableCreate2Factory.sol";

contract LooksRareV2ProxyDeployment is Script {
    LooksRareAggregator internal looksRareAggregator;
    LooksRareProxy internal looksRareProxy;
    SeaportProxy internal seaportProxy;

    IImmutableCreate2Factory private constant CREATE2_FACTORY =
        IImmutableCreate2Factory(0x0000000000FFe8B47B3e2130213B802212439497);

    error WrongChain();

    function _run(address looksrareV2) internal {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // TODO: Replace address later
        looksRareAggregator = LooksRareAggregator(payable(address(0)));

        _deployLooksRareV2Proxy(looksrareV2);

        vm.stopBroadcast();
    }

    function _deployLooksRareV2Proxy(address marketplace) private {
        // Just going to use the same salt for mainnet and goerli even though they will result
        // in 2 different contract addresses, as LooksRareProtocol's contract address is different
        // for mainnet and goerli.
        address looksRareV2ProxyAddress = CREATE2_FACTORY.safeCreate2({
            salt: vm.envBytes32("LOOKS_RARE_V2_PROXY_SALT"),
            initializationCode: abi.encodePacked(
                type(LooksRareV2Proxy).creationCode,
                abi.encode(marketplace, address(looksRareAggregator))
            )
        });
        looksRareAggregator.addFunction(looksRareV2ProxyAddress, LooksRareV2Proxy.execute.selector);
    }
}
