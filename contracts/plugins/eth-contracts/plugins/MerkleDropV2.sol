// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "../utils/SafeMath.sol";
import "../utils/MerkleProof.sol";
import "../assets/TokenBankInterface.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";

contract MerkleDropV2 is Ownable {
    using SafeMath for uint;

    address public token;
    string public info;
    TokenBankInterface public token_bank;
    uint public total_dropped;
    bytes32 public merkle_root;
    uint256 public total_index;

    bool public paused;
    bool public enable_update_when_claim;
    mapping(bytes32 => bool) public claim_status;

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
        enable_update_when_claim = false;
    }

    event NewMerkleRoot(bytes32 merkle_root);

    function newRoot(
        bytes32 _old_root,
        bytes32 _root
    ) public onlyOwner returns (bytes32) {
        require(_old_root == merkle_root, "consistency check failed");
        require(_old_root != _root, "cannot be the same merkle root");
        merkle_root = _root;
        emit NewMerkleRoot(_root);
        return _root;
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

    event EnableUpdateWhenClaim(bool enable);

    function enableUpdateWhenClaim(bool enable) public onlyOwner {
        enable_update_when_claim = enable;
        emit EnableUpdateWhenClaim(enable);
    }

    event DropToken(address claimer, address to, uint amount, bytes32 new_root);

    function claim(
        address payable to,
        uint amount,
        bytes32[] memory proof
    ) public returns (bool) {
        require(paused == false, "already paused");
        {
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
            bool ret = MerkleProof.verify(proof, merkle_root, leaf);
            require(ret, "invalid merkle proof");
        }

        {
            bytes32 key = keccak256(abi.encodePacked(msg.sender, merkle_root));
            require(claim_status[key] == false, "already claimed");
            claim_status[key] = true;
        }

        token_bank.issue(token, to, amount);
        if (enable_update_when_claim) {
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender, uint256(0)));
            merkle_root = MerkleProof.update_root(proof, leaf);
        }

        total_dropped = total_dropped.safeAdd(amount);
        emit DropToken(msg.sender, to, amount, merkle_root);
        return true;
    }

    function simpleUpdate(
        address old_addr,
        uint256 old_amount,
        address addr,
        uint256 amount,
        bytes32[] memory proof
    ) public onlyOwner returns (bytes32) {
        if (proof[proof.length - 1] != merkle_root) {
            bytes32 old_leaf = keccak256(
                abi.encodePacked(old_addr, old_amount)
            );
            require(
                MerkleProof.verify(proof, merkle_root, old_leaf),
                "invalid proof"
            );
        } else {
            require(
                old_addr == address(0) && old_amount == 0,
                "invalid old info"
            );
        }
        bytes32 leaf = keccak256(abi.encodePacked(addr, amount));
        merkle_root = MerkleProof.update_root(proof, leaf);
        emit NewMerkleRoot(merkle_root);
        return merkle_root;
    }

    function verify(
        address addr,
        uint256 amount,
        bytes32[] memory proof
    ) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(addr, amount));
        return MerkleProof.verify(proof, merkle_root, leaf);
    }
}

contract MerkleDropV2Factory {
    event NewMerkleDropV2(address addr);

    function createMerkleDropV2(
        string memory _info,
        address _token_bank,
        address _token,
        bytes32 _merkle_root
    ) public returns (address) {
        MerkleDropV2 mm = new MerkleDropV2(
            _info,
            _token_bank,
            _token,
            _merkle_root
        );
        mm.transferOwnership(msg.sender);
        emit NewMerkleDropV2(address(mm));
        return address(mm);
    }
}
