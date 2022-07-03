//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces/IProperty.sol";
import "../interfaces/IRent.sol";

abstract contract RentStorage is IRent {
  using Counters for Counters.Counter;

  uint256 public commision; //0.01%
  uint256 public contractEarned;

  Property[] public properties;

  IProperty internal property;

  mapping(address => uint256) public renterPropertyAmount;
  Counters.Counter public propertyOnMarket;

}
