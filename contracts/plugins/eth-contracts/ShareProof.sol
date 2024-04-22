// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./erc20/ERC20Impl.sol";
import "./utils/TokenClaimer.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";

contract ShareProof is ERC20Base, Ownable, TokenClaimer {
    uint[] public heightlist;

    function getHeightlist(uint n) public view returns (uint) {
        return heightlist[n];
    }

    constructor(
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol
    )
        ERC20Base(
            ERC20Base(address(0x0)),
            0,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            false
        )
    {}

    function claimStdTokens(
        address _token,
        address payable to
    ) public onlyOwner {
        _claimStdTokens(_token, to);
    }

    function getCheckpointLength() public view returns (uint) {
        return heightlist.length;
    }

    function generateProof(
        address _owner,
        uint _amount
    ) public onlyOwner returns (bool) {
        require(_generateTokens(_owner, _amount), "generate token failed");
        heightlist.push(block.number);
        return true;
    }

    function destroyProof(
        address _owner,
        uint _amount
    ) public onlyOwner returns (bool) {
        require(_destroyTokens(_owner, _amount), "destory token failed");
        heightlist.push(block.number);
        return true;
    }

    function transferProof(address from, address to) public onlyOwner {
        uint256 _amount = balanceOf(from);
        _destroyTokens(from, _amount);
        _generateTokens(to, _amount);
    }
}

/// @dev This contract is used to generate clone contracts from a contract.
///  In solidity this is the way to create a contract from a contract of the
///  same class
contract ShareProofFactory {
    event NewProof(address indexed _cloneToken);

    /// @notice Update the DApp by creating a new token with new functionalities
    ///  the msg.sender becomes the controller of this clone token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @return The address of the new token contract
    function createShareProof(
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol
    ) public returns (address) {
        ShareProof newToken = new ShareProof(
            _tokenName,
            _decimalUnits,
            _tokenSymbol
        );
        emit NewProof(address(newToken));

        newToken.transferOwnership(msg.sender);

        return address(newToken);
    }
}
