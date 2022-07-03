//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces/IProperty.sol";
import "../interfaces/IRent.sol";
import "./Common.sol";

abstract contract TokenStorage is IProperty, Common {
  using Counters for Counters.Counter;

  IRent rent;

  mapping(uint256 => address) public approveRented;
  mapping(address => uint256) public userPropertyAmount;

  Counters.Counter internal tokenIds;

}
