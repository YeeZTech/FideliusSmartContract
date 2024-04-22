// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PERCBaseUpgradable} from "./PERCBaseUpgradable.sol";
import {IPaymentProxy} from "./interface/PaymentProxyInterface.sol";
import {TokenClaimer} from "contracts/plugins/eth-contracts/utils/TokenClaimer.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract PERCToken is
    PERCBaseUpgradable,
    OwnableUpgradeable,
    AccessControlUpgradeable,
    TokenClaimer
{
    bytes32 public constant TRUSTED_ROLE = keccak256("TRUSTED_ROLE");

    PERCTokenFactory public tokenFactory;

    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);

    function initialize(
        PERCTokenFactory _tokenFactory,
        PERCBaseUpgradable _parentToken,
        uint _parentSnapShotBlock,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        bool _transfersEnabled,
        address _pool
    ) public initializer {
        tokenFactory = _tokenFactory;
        __PERCBaseUpgradable_init(
            _parentToken,
            _parentSnapShotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled,
            _pool
        );
        __Ownable_init(msg.sender);
        //__AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function claimStdTokens(
        address _token,
        address payable to
    ) public onlyOwner {
        _claimStdTokens(_token, to);
    }

    function createCloneToken(
        string memory _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string memory _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled,
        address _pool
    ) public returns (PERCToken) {
        uint256 snapshot = _snapshotBlock == 0
            ? block.number - 1
            : _snapshotBlock;
        PERCToken cloneToken = tokenFactory.createCloneToken(
            this,
            snapshot,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled,
            _pool
        );
        emit NewCloneToken(address(cloneToken), snapshot);
        cloneToken.transferOwnership(msg.sender);
        cloneToken.grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        cloneToken.revokeRole(DEFAULT_ADMIN_ROLE, address(this));
        return cloneToken;
    }

    function addTransferListener(address _addr) public onlyOwner {
        _addTransferListener(_addr);
    }

    function removeTransferListener(address _addr) public onlyOwner {
        _removeTransferListener(_addr);
    }

    event NewPaymentProxy(address _pool);

    function changePaymentProxy(address _pool) public onlyOwner {
        payment_proxy = _pool;
        emit NewPaymentProxy(_pool);
    }

    event ProxyRequired(bool proxy_required);

    function changeProxyRequire(bool _bool) public onlyOwner {
        proxy_required = _bool;
        emit ProxyRequired(_bool);
    }

    function is_proxy_required() public view returns (bool) {
        return proxy_required;
    }

    function burn(
        address _owner,
        uint _amount
    ) public onlyRole(TRUSTED_ROLE) returns (bool) {
        IPaymentProxy(payment_proxy).transferRequest(
            address(this),
            _owner,
            address(0x1),
            _amount
        );
        require(balanceOf(_owner) >= _amount, "insufficient amount");
        return doTransfer(_owner, address(0x1), _amount);
    }

    function generateTokens(
        address _owner,
        uint _amount
    ) public onlyRole(TRUSTED_ROLE) returns (bool) {
        return _generateTokens(_owner, _amount);
    }

    function destroyTokens(
        address _owner,
        uint _amount
    ) public onlyRole(TRUSTED_ROLE) returns (bool) {
        return _destroyTokens(_owner, _amount);
    }

    function enableTransfers(bool _transfersEnabled) public onlyOwner {
        _enableTransfers(_transfersEnabled);
    }
}

/// @dev This contract is used to generate clone contracts from a contract.
///  In solidity this is the way to create a contract from a contract of the
///  same class
contract PERCTokenFactory {
    event NewToken(address indexed _cloneToken, uint _snapshotBlock);

    //address public proxyAdmin;

    PERCToken public impl;

    constructor() {
        //proxyAdmin = _proxyAdmin;
        impl = new PERCToken();
    }

    /// @notice Update the DApp by creating a new token with new functionalities
    ///  the msg.sender becomes the controller of this clone token
    /// @param _parentToken Address of the token being cloned
    /// @param _snapshotBlock Block of the parent token that will
    ///  determine the initial distribution of the clone token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @param _transfersEnabled If true, tokens will be able to be transferred
    /// @return The address of the new token contract
    function createCloneToken(
        PERCToken _parentToken,
        uint _snapshotBlock,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        bool _transfersEnabled,
        address _pool
    ) public returns (PERCToken) {
        bytes memory data = abi.encodeCall(
            PERCToken.initialize,
            (
                this,
                _parentToken,
                _snapshotBlock,
                _tokenName,
                _decimalUnits,
                _tokenSymbol,
                _transfersEnabled,
                _pool
            )
        );

        TransparentUpgradeableProxy newToken = new TransparentUpgradeableProxy(
            address(impl),
            msg.sender,
            data
        );

        emit NewToken(address(newToken), _snapshotBlock);

        PERCToken(address(newToken)).transferOwnership(msg.sender);

        PERCToken(address(newToken)).grantRole(bytes32(0), msg.sender);
        PERCToken(address(newToken)).revokeRole(bytes32(0), address(this));

        return PERCToken(address(newToken));
    }
}
