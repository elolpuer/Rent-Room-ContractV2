//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces/IProperty.sol";

abstract contract TokenStorage is IProperty {
  using Counters for Counters.Counter;

  address public rentAddress;

  mapping(address => uint256) public userPropertyAmount;

  struct RentedToken {
    uint256 tokenId;
    bool isRent;
    address renter;
  }
  RentedToken[] rentedTokens;

  Counters.Counter internal tokenIds;

}
