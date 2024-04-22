// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IPaymentProxy {
    function transferRequest(
        address _token,
        address _from,
        address _to,
        uint256 _amount
    ) external;

    // bool public tx_lock;
    function getTxLock() external view returns (bool);

    function currentTransferRequestHash() external view returns (bytes32);

    function startTransferRequest() external returns (bytes32);

    function endTransferRequest() external returns (bytes32);

    function getTransferRequestStatus(
        bytes32 _hash
    ) external view returns (uint8);

    function transferCommit(bytes32 _hash, bool _status) external;
}
