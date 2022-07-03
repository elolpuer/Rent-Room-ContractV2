//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "../storage/Common.sol" ;

interface IRent is Common {

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
  event EndRent(uint256 id, uint256 time);
  event ChangeDeposit(uint256 id, uint256 newDeposit);
  event ChangePropertyPrice(uint256 id, uint256 newPrice);
  event ChangePropertyMinTimeToRent(uint256 id, uint256 newMinTimeToRent);
  event ChangePropertyMaxTimeToRent(uint256 id, uint256 newMaxTimeToRent);

  function getProperty(uint256 propertyId) external returns(Property memory);

}
