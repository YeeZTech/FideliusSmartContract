// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Ownable} from "solady/src/auth/Ownable.sol";

interface TrustListInterface {
    function is_trusted(address addr) external returns (bool);
}

contract TrustListTools is Ownable {
    TrustListInterface public trustlist;

    modifier is_trusted(address addr) {
        require(
            trustlist != TrustListInterface(address(0)),
            "trustlist is 0x0"
        );
        require(trustlist.is_trusted(addr), "not a trusted issuer");
        _;
    }

    event ChangeTrustList(address _old, address _new);

    function changeTrustList(address _addr) public onlyOwner {
        address old = address(trustlist);
        trustlist = TrustListInterface(_addr);
        emit ChangeTrustList(old, _addr);
    }
}
