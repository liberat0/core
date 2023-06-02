// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/ERC721A/contracts/ERC721A.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }
}
