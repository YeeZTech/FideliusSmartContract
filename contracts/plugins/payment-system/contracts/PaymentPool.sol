// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {TokenClaimer} from "contracts/plugins/eth-contracts/utils/TokenClaimer.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IPERC} from "../contracts/interface/IPERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TokenInterface} from "contracts/plugins/eth-contracts/erc20/TokenInterface.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AddressArray} from "contracts/plugins/eth-contracts/utils/AddressArray.sol";

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract PaymentPool is
    OwnableUpgradeable,
    TokenClaimer,
    AccessControlUpgradeable
{
    using SafeERC20 for IERC20;
    using AddressArray for address[];

    bytes32 public constant TRUSTED_ROLE = keccak256("TRUSTED_ROLE");

    string public bank_name;
    uint256 public nonce;
    bool public tx_lock;

    address[] involved_tokens;
    address[][] involved_addr;
    uint256[][] old_balance;

    struct receipt {
        address addr;
        uint256 amount;
        address token;
        bool status; //true for receiver, false for sender
    }

    struct request_info {
        bool exist;
        address from;
        uint8 status; //0 is init or pending, 1 is for succ, 2 is for fail
        receipt[] receipts;
    }
    mapping(bytes32 => request_info) public requests;
    mapping(address => mapping(address => uint256)) public pending_balance;
    mapping(bytes32 => uint256) public pending_asset;

    event withdraw_token(address token, address to, uint256 amount);
    event issue_token(address token, address to, uint256 amount);

    event RecvETH(uint256 v);

    receive() external payable {
        emit RecvETH(msg.value);
    }

    function initialize(string memory name) public initializer {
        __Ownable_init(msg.sender);
        //__AccessControl_init();
        bank_name = name;
        nonce = 0;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function claimStdTokens(
        address _token,
        address payable to
    ) public onlyOwner {
        _claimStdTokens(_token, to);
    }

    function balance(address erc20_token_addr) public view returns (uint) {
        if (erc20_token_addr == address(0x0)) {
            return address(this).balance;
        }
        return IERC20(erc20_token_addr).balanceOf(address(this));
    }

    function transfer(
        address erc20_token_addr,
        address payable to,
        uint tokens
    ) public onlyOwner returns (bool success) {
        require(tokens <= balance(erc20_token_addr), "Pool not enough tokens");
        if (erc20_token_addr == address(0x0)) {
            (bool _success, ) = to.call{value: tokens}("");
            require(_success, "Pool transfer eth failed");
            emit withdraw_token(erc20_token_addr, to, tokens);
            return true;
        }
        IERC20(erc20_token_addr).safeTransfer(to, tokens);
        emit withdraw_token(erc20_token_addr, to, tokens);
        return true;
    }

    function startTransferRequest()
        public
        onlyRole(TRUSTED_ROLE)
        returns (bytes32)
    {
        require(!tx_lock, "startTransferRequest cannot be nested");
        tx_lock = true;
        nonce++;
        bytes32 h = currentTransferRequestHash();
        requests[h].exist = true;
        requests[h].from = msg.sender;
        requests[h].status = 1; //by default, it's succ until we get transfer requests.
        return h;
    }

    function endTransferRequest()
        public
        onlyRole(TRUSTED_ROLE)
        returns (bytes32)
    {
        bytes32 h = currentTransferRequestHash();
        for (uint k = 0; k < involved_tokens.length; k++) {
            address token_addr = involved_tokens[k];
            for (uint i = 0; i < involved_addr[k].length; i++) {
                address addr = involved_addr[k][i];
                uint256 bal = IERC20(token_addr).balanceOf(addr);
                if (bal < old_balance[k][i]) {
                    TokenInterface(token_addr).generateTokens(
                        address(this),
                        old_balance[k][i] - bal
                    );
                    receipt memory recp;
                    recp.token = token_addr;
                    recp.addr = addr;
                    recp.amount = old_balance[k][i] - bal;
                    recp.status = false;

                    requests[h].receipts.push(recp);

                    pending_balance[addr][token_addr] += (old_balance[k][i] -
                        bal);
                } else if (bal > old_balance[k][i]) {
                    TokenInterface(token_addr).destroyTokens(
                        addr,
                        bal - old_balance[k][i]
                    );
                    receipt memory recp;
                    recp.token = token_addr;
                    recp.addr = addr;
                    recp.amount = bal - old_balance[k][i];
                    recp.status = true;

                    requests[h].receipts.push(recp);
                }
            }
        }
        delete old_balance;
        delete involved_tokens;
        delete involved_addr;
        tx_lock = false;
        return keccak256(abi.encodePacked(nonce));
    }

    function currentTransferRequestHash() public view returns (bytes32) {
        return keccak256(abi.encodePacked(nonce));
    }

    function getTransferRequestStatus(
        bytes32 _hash
    ) public view returns (uint8) {
        return requests[_hash].status;
    }

    function getPendingBalance(
        address _owner,
        address token_addr
    ) public view returns (uint256) {
        return pending_balance[_owner][token_addr];
    }

    event TransferRequest(
        bytes32 request_hash,
        address token_addr,
        address from,
        address to,
        uint256 amount
    );

    function transferRequest(
        address token_addr,
        address _from,
        address _to,
        uint256 _amount
    ) public onlyRole(TRUSTED_ROLE) {
        bytes32 h = currentTransferRequestHash();
        if (IPERC(token_addr).is_proxy_required()) {
            requests[h].status = 0; //since we have transfers, we make it pending
            require(tx_lock, "proxy required");
            if (!involved_tokens.exists(token_addr)) {
                involved_tokens.push(token_addr);
                address[] memory a;
                involved_addr.push(a);
                uint256[] memory b;
                old_balance.push(b);
            }
            uint256 ind = involved_tokens.index_of(token_addr);
            if (!involved_addr[ind].exists(_from)) {
                involved_addr[ind].push(_from);
                old_balance[ind].push(IERC20(token_addr).balanceOf(_from));
            }
            if (!involved_addr[ind].exists(_to)) {
                involved_addr[ind].push(_to);
                old_balance[ind].push(IERC20(token_addr).balanceOf(_to));
            }
            emit TransferRequest(h, token_addr, _from, _to, _amount);
        } else {
            //IPERC(token_addr).confirmTransfer(_to, _amount);
            //do nothing
        }
    }

    event TransferCommit(bytes32 hash, bool status);

    function transferCommit(
        bytes32 _hash,
        bool _status
    ) public onlyRole(TRUSTED_ROLE) {
        request_info storage request = requests[_hash];
        require(request.status == 0, "only pending tx can be committed");
        if (_status) {
            request.status = 1;
        } else {
            request.status = 2;
        }
        if (_status) {
            for (uint i = 0; i < request.receipts.length; i++) {
                receipt memory rt = request.receipts[i];
                if (rt.status == false) continue;
                if (rt.addr != address(0x1)) {
                    IPERC(rt.token).confirmTransfer(rt.addr, rt.amount);
                } else {
                    IPERC(rt.token).confirmTransfer(address(0), rt.amount);
                }
            }
        } else {
            for (uint i = 0; i < request.receipts.length; i++) {
                receipt memory rt = request.receipts[i];
                if (rt.status == true) continue;
                IPERC(rt.token).confirmTransfer(rt.addr, rt.amount);
            }
        }
        for (uint i = 0; i < request.receipts.length; i++) {
            receipt memory rt = request.receipts[i];
            if (rt.status == true) continue;
            pending_balance[rt.addr][rt.token] -= rt.amount;
        }

        emit TransferCommit(_hash, _status);
    }

    function getTxLock() public view returns (bool) {
        return tx_lock;
    }
}

// contract PaymentPoolFactory {
//     event CreatePaymentPool(string name, address addr);

//     function newPaymentPool(string memory name) public returns (address) {
//         PaymentPool addr = new PaymentPool(name);
//         emit CreatePaymentPool(name, address(addr));
//         addr.transferOwnership(msg.sender);
//         return address(addr);
//     }
// }
