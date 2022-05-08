// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Mimic is ERC20 {
    constructor() ERC20("Mimic Token", "MIM") {}
}
