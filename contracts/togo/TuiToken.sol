// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract TuiToken is ERC20, ERC20Burnable {
    constructor(address owner,uint256 amount) ERC20("TUI", "TUI") {
        _mint(owner, amount * 10 ** decimals());
    }
}