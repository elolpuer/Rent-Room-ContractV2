//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces/IProperty.sol";

contract RentStorage {
  using Counters for Counters.Counter;

  uint256 public commision = 100; //0.01%
  uint256 public contractEarned;

  struct Property {
      uint256 tokenID;
      address owner;
      address renter;
      uint256 timeDeal;         //deal time - when renter rented property
      uint256 timeToRent;       //time to rent for example renter choosed 30 days he will own this property
      uint256 minTimeToRent;    //in mls /* for example min = 30 days
      uint256 maxTimeToRent;    //in mls                max = 364 days*/
      uint256 price;            //per day
      uint256 deposit;          //deposit for unfortunate situations
      bool rented;
      bool onMarket;
  }
  Property[] public properties;

  IProperty internal property;

  mapping(address => uint256) public renterPropertyAmount;
  Counters.Counter public propertyOnMarket;

}
