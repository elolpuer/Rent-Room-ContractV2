//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces/IProperty.sol";
import "./RentStorage.sol";

abstract contract RentStorageV2 is RentStorage {
  
  mapping(uint256 => address) public customTokenPaymentToProperty;

}
