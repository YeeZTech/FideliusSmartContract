// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface KeyVerifierInterface {
    function verify_pkey(
        bytes memory _pkey,
        bytes memory _pkey_sig
    ) external view returns (bool);
}
