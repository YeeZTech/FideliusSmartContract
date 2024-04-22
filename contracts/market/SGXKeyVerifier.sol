// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ECDSA} from "solady/src/utils/ECDSA.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {KeyVerifierInterface} from "./interface/KeyVerifierInterface.sol";
import {SignatureVerifier} from "./SignatureVerifier.sol";

contract SGXKeyVerifier is Ownable, KeyVerifierInterface {
    constructor() Ownable(msg.sender) {}

    using ECDSA for bytes32;
    using SignatureVerifier for bytes;

    mapping(address => bool) public verifier_addrs;
    uint256 public available_verifiers_num;

    event SetVerifierAddr(address addr, bool to_add);

    function set_verifier_addr(address addr, bool to_add) public onlyOwner {
        if (to_add && verifier_addrs[addr]) {
            return;
        }
        if (!to_add && !verifier_addrs[addr]) {
            return;
        }

        if (to_add) {
            available_verifiers_num = available_verifiers_num + 1;
        } else {
            require(verifier_addrs[addr], "invalid to remove");
            available_verifiers_num = available_verifiers_num - 1;
        }
        verifier_addrs[addr] = to_add;
        emit SetVerifierAddr(addr, to_add);
    }

    function set_verifier_pkey(
        bytes memory _pkey,
        bool to_add
    ) public onlyOwner {
        set_verifier_addr(_pkey.getAddressFromPublicKey(), to_add);
    }

    function verify_pkey(
        bytes memory _pkey,
        bytes memory _pkey_sig
    ) public view returns (bool) {
        bytes32 hash = keccak256(abi.encodePacked(_pkey))
            .toEthSignedMessageHash();
        address addr = hash.recover(_pkey_sig);
        return verifier_addrs[addr];
    }
}

contract SGXKeyVerifierFactory {
    event NewSGXKeyVerifier(address addr);

    function createSGXKeyVerifier() public returns (address) {
        SGXKeyVerifier m = new SGXKeyVerifier();
        m.transferOwnership(msg.sender);
        emit NewSGXKeyVerifier(address(m));
        return address(m);
    }
}
