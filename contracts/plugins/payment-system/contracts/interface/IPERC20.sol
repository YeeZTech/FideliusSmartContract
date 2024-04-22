// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IPERC {
    function confirmTransfer(
        address _to,
        uint256 _amount
    ) external returns (bool);

    function is_proxy_required() external view returns (bool);

    function burn(address _owner, uint _amount) external returns (bool);
}
