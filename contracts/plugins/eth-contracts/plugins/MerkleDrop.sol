// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "../utils/SafeMath.sol";
import "../utils/MerkleProof.sol";
import "../assets/TokenBankInterface.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";

contract MerkleDrop is Ownable {
    using SafeMath for uint;

    address public token;
    string public info;
    TokenBankInterface public token_bank;
    uint public total_dropped;
    bytes32 public merkle_root;

    bool public paused;
    mapping(address => bool) private claim_status;

    constructor(
        string memory _info,
        address _token_bank,
        address _token,
        bytes32 _merkle_root
    ) {
        token = _token;
        info = _info;
        token_bank = TokenBankInterface(_token_bank);
        total_dropped = 0;
        merkle_root = _merkle_root;
        paused = false;
    }

    event MerkleDropPause(bool pause);

    function pause() public onlyOwner {
        paused = true;
        emit MerkleDropPause(true);
    }

    function unpause() public onlyOwner {
        paused = false;
        emit MerkleDropPause(false);
    }

    event DropToken(address claimer, address to, uint amount);

    function claim(
        address payable to,
        uint amount,
        bytes32[] memory proof
    ) public returns (bool) {
        require(paused == false, "already paused");
        require(claim_status[msg.sender] == false, "you claimed already");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));

        bool ret = MerkleProof.verify(proof, merkle_root, leaf);
        require(ret, "invalid merkle proof");

        claim_status[msg.sender] = true;
        token_bank.issue(token, to, amount);
        total_dropped = total_dropped.safeAdd(amount);
        emit DropToken(msg.sender, to, amount);
        return true;
    }
}

contract MerkleDropFactory {
    event NewMerkleDrop(address addr);

    function createMerkleDrop(
        string memory _info,
        address _token_bank,
        address _token,
        bytes32 _merkle_root
    ) public returns (address) {
        MerkleDrop mm = new MerkleDrop(
            _info,
            _token_bank,
            _token,
            _merkle_root
        );
        mm.transferOwnership(msg.sender);
        emit NewMerkleDrop(address(mm));
        return address(mm);
    }
}
