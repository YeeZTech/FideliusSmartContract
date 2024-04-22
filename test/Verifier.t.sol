// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SGXKeyVerifierFactory, SGXKeyVerifier} from "contracts/market/SGXKeyVerifier.sol";
import "lib/forge-std/src/Test.sol";

contract VerifierTest is Test {
    SGXKeyVerifierFactory factory;
    SGXKeyVerifier verifier;
    bytes pkey;
    bytes program_hash;
    bytes pkey_sig;

    function setUp() public {
        factory = new SGXKeyVerifierFactory();
        verifier = new SGXKeyVerifier();
    }

    function test_SGXKeyVerifier() public {
        verifier.set_verifier_addr(
            0xf4267391072B27D76Ed8f2A9655BCf5246013F2d,
            true
        );
        pkey = hex"362a609ab5a6eecafdb2289890bd7261871c04fb5d7323d4fc750f6444b067a12a96efbe24c62572156caa514657d4a535101d2147337f41f51fcdfcf8f43a53";
        pkey_sig = hex"d9b0a2d2a1c669c7cfd40e1bb71041597140cfff38ec36ff4027405bc18e0b0f2109b354641feda4c4c38bc17836e8b1d15b2054b0c359347595783f9d0664021b";
        bool ret = verifier.verify_pkey(pkey, pkey_sig);
        assertEq(ret, true);
    }
}