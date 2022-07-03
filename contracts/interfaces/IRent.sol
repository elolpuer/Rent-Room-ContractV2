//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

interface IRent {

  event CreateProperty (address _owner, uint _price, uint256 id);
  event DeleteProperty (address _owner, uint256 id);
  event RentRoom (address payable _owner, address payable _rentOwner, uint _id,uint _timeDeal, uint _timeRentEnded,uint _price);
  event CloseRoomOwnerForever(address payable _owner, uint _id);
  event CloseRoomRenter(uint _id);
  event CloseRoomOwnerFromThisRenter(address payable _owner, uint _id);
  event ChangeKey(uint _id);

}
