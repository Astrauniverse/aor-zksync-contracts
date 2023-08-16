// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract AstraOmniRiseToken is ERC20, ERC20Burnable {
    constructor() ERC20("Astra:OmniRise", "AOR") {
        _mint(msg.sender, 500000000 * 10 ** decimals());
    }
}