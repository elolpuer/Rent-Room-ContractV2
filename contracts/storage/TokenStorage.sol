//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";

contract TokenStorage {
  using Counters for Counters.Counter;

  address internal rentAddress;

  mapping(address => uint256) public userRentAmount;

  struct RentedToken {
    uint256 tokenId;
    bool isRent;
    address renter;
  }
  RentedToken[] rentedTokens;

  Counters.Counter internal tokenIds;


}
