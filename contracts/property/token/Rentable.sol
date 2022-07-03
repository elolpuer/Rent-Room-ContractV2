// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../../storage/TokenStorage.sol";

abstract contract Rentable is TokenStorage {

  modifier onlyRent() {
    require(msg.sender == rentAddress, "Rentable: Only Rent Contract");
    _;
  }

  function setRent(address rent) internal {
    rentAddress = rent;
  }

}
