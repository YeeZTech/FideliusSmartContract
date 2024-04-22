// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ECDSA} from "solady/src/utils/ECDSA.sol";

library SignatureVerifier {
    using ECDSA for bytes32;

    function verify_signature(
        bytes32 hash,
        bytes memory sig,
        bytes memory pkey
    ) internal view returns (bool) {
        address expected = getAddressFromPublicKey(pkey);
        return hash.recover(sig) == expected;
    }

    function getAddressFromPublicKey(
        bytes memory _publicKey
    ) internal pure returns (address addr) {
        bytes32 hash = keccak256(_publicKey);
        assembly {
            mstore(0, hash)
            addr := mload(0)
        }
    }
}
