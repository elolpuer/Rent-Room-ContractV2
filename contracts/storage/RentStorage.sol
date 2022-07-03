//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces/IProperty.sol";

contract RentStorage {
  
  mapping(uint => uint) public keys;
  mapping(uint => uint) public deposit;
  struct Property {
      uint id;
      address owner;
      address renter;
      uint timeDeal;
      uint timeRentWillEnd;
      uint price;
      bool rented;
  }
  Property[] public properties;

  IProperty internal property;

}
