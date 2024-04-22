// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract TestERC20 is ERC20Permit {
    constructor() ERC20Permit("TestERC20") ERC20("Test ERC20", "TE") {
        _mint(msg.sender, 10 ** 36);
    }
}
