//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

interface IRent {

  event CreateProperty (address _owner, uint256 id);
  event DeleteProperty (address _owner, uint256 id);
  event AddPropertyOnMarket (uint256 id, uint256 price, uint256 time);
  event DeletePropertyFromMarket (uint256 id, uint256 time);
  event RentProperty (
    uint id,
    address renter,
    uint timeDeal,
    uint timeToRent
  );

  event CloseRoomOwnerForever(address payable _owner, uint _id);
  event CloseRoomRenter(uint _id);
  event CloseRoomOwnerFromThisRenter(address payable _owner, uint _id);
  event ChangeKey(uint _id);

}
