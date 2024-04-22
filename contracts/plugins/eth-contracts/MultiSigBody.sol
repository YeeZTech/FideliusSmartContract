// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {MultiSigToolsWithReward} from "./MultiSigToolsWithReward.sol";
import {TokenClaimer} from "./utils/TokenClaimer.sol";

contract MultiSigBody is MultiSigToolsWithReward, TokenClaimer {
    constructor(
        address _multisig,
        address _reward
    ) MultiSigToolsWithReward(_multisig, _reward) {}

    function call_contract(
        uint64 id,
        address _addr,
        bytes memory _data,
        uint256 _value
    ) public only_signer is_majority_sig(id, "call_contract") {
        (bool success, ) = _addr.call{value: _value}(_data);
        require(success, "MultisigBody call failed");
    }

    function claimStdTokens(
        uint64 id,
        address _token,
        address payable to
    ) public only_signer is_majority_sig(id, "claimStdTokens") {
        _claimStdTokens(_token, to);
    }

    event RecvETH(uint256 v);

    receive() external payable {
        emit RecvETH(msg.value);
    }
}

contract MultiSigBodyFactory {
    event NewMultiSigBody(address addr, address _multisig);

    function createMultiSig(
        address _multisig,
        address _reward
    ) public returns (address) {
        MultiSigBody ms = new MultiSigBody(_multisig, _reward);
        emit NewMultiSigBody(address(ms), _multisig);
        return address(ms);
    }
}
