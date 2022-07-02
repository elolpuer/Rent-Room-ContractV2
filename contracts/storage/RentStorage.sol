//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces/IProperty.sol";

contract RentStorage {

  mapping(uint => uint) public keys;
  mapping(uint => uint) public deposit;
  struct Room  {
      uint ID;
      address payable Owner;
      address payable RentOwner;
      uint TimeDeal;
      uint TimeRentEnded;
      string Name;
      string Description;
      uint Price;
      bool Rented;
  }
  Room[] internal rooms;

  IProperty internal property;

}
