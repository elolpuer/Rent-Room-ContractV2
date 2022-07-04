//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract CustomToken is ERC20Upgradeable {

  function initialize(address renter, string memory name, string memory symbol) public initializer {
    __ERC20_init(name, symbol);
    _mint(msg.sender, 10 * 10**18);
    _mint(renter, 10 * 10**18);
  }

}
