// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./MultiSigInterface.sol";

interface RewardInterface {
    function reward(address payable to, uint256 amount) external;
}

//We do not inherit from MultiSigTools
contract MultiSigToolsWithReward {
    MultiSigInterface public multisig_contract;
    RewardInterface public reward_contract;

    constructor(address _contract, address _rewarder) {
        require(_contract != address(0x0));
        reward_contract = RewardInterface(_rewarder);

        multisig_contract = MultiSigInterface(_contract);
    }

    modifier only_signer() {
        require(
            multisig_contract.is_signer(msg.sender),
            "only a signer can call in MultiSigTools"
        );
        _;
    }

    modifier is_majority_sig(uint64 id, string memory name) {
        uint256 gas_start = gasleft();
        bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));
        if (
            multisig_contract.update_and_check_reach_majority(
                id,
                name,
                hash,
                msg.sender
            )
        ) {
            _;
        }
        uint256 gasused = (gas_start - gasleft()) * tx.gasprice;
        if (reward_contract != RewardInterface(address(0x0))) {
            reward_contract.reward(payable(tx.origin), gasused);
        }
    }

    modifier is_majority_sig_with_hash(
        uint64 id,
        string memory name,
        bytes32 hash
    ) {
        uint256 gas_start = gasleft();
        if (
            multisig_contract.update_and_check_reach_majority(
                id,
                name,
                hash,
                msg.sender
            )
        ) {
            _;
        }
        uint256 gasused = (gas_start - gasleft()) * tx.gasprice;
        if (reward_contract != RewardInterface(address(0x0))) {
            reward_contract.reward(payable(tx.origin), gasused);
        }
    }

    event ChangeRewarder(address _old, address _new);

    function changeRewarder(
        uint64 id,
        address _rewarder
    ) public only_signer is_majority_sig(id, "changeRewarder") {
        address old = address(reward_contract);
        reward_contract = RewardInterface(_rewarder);
        emit ChangeRewarder(old, _rewarder);
    }

    event TransferMultiSig(address _old, address _new);

    function transfer_multisig(
        uint64 id,
        address _contract
    ) public only_signer is_majority_sig(id, "transfer_multisig") {
        require(_contract != address(0x0));
        address old = address(multisig_contract);
        multisig_contract = MultiSigInterface(_contract);
        emit TransferMultiSig(old, _contract);
    }
}
