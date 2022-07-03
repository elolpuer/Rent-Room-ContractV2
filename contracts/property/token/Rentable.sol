// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../../storage/TokenStorage.sol";
import "../../interfaces/IRent.sol";

abstract contract Rentable is TokenStorage {

  modifier onlyRent() {
    require(msg.sender == address(rent), "Rentable: Only Rent Contract");
    _;
  }

  function setRent(address _rent) internal {
    rent = IRent(_rent);
  }

}
