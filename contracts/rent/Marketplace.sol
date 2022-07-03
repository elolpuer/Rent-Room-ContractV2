//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "./Factory.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Marketplace is Factory {
  using Counters for Counters.Counter;

  modifier isPropertyOnMarket(uint256 propertyID) {
    require(properties[propertyID].onMarket == false, "Marketplace: Already on market");
    _;
  }

  function addPropertyToMarket(
    uint256 propertyID,
    uint256 minTimeToRent,
    uint256 maxTimeToRent,
    uint256 price,           //per day
    uint256 deposit          //amount in wei full
  )
    public
    isPropertyOwner(propertyID)
    isPropertyOnMarket(propertyID)
  {
    properties[propertyID].onMarket = true;
    properties[propertyID].minTimeToRent = minTimeToRent;
    properties[propertyID].maxTimeToRent = maxTimeToRent;
    properties[propertyID].price = price;
    properties[propertyID].deposit = deposit;
    propertyOnMarket.increment();
    emit AddPropertyOnMarket(propertyID, price, block.timestamp);
  }

  function deletePropertyFromMarket(
    uint256 propertyID
  )
    public
    isPropertyOwner(propertyID)
    isPropertyOnMarket(propertyID)
    isPropertyRented(propertyID)
  {
    properties[propertyID].onMarket = false;
    propertyOnMarket.decrement();
    emit DeletePropertyFromMarket(propertyID, block.timestamp);
  }

  function rent(
    uint256 propertyID,
    uint256 timeToRent
  )
    public
    payable
    isPropertyOnMarket(propertyID)
    isPropertyRented(propertyID)
  {
    require(
      properties[propertyID].minTimeToRent <= timeToRent
      &&
      properties[propertyID].maxTimeToRent >= timeToRent,
      "Marketplace: Time to Rent is not ok"
    );
    //price per one day * amount of days + deposit
    uint256 allValueToSend = properties[propertyID].price * (timeToRent / 1 days) + properties[propertyID].deposit;
    require(allValueToSend == msg.value, "Marketplace: Not enough value for rent");
    _rent(propertyID, timeToRent, msg.sender);
    emit RentProperty(
      propertyID,
      properties[propertyID].renter,
      properties[propertyID].timeDeal,
      properties[propertyID].timeToRent
    );
  }

  function _rent(uint256 propertyID, uint256 timeToRent, address renter) private {
    properties[propertyID].timeDeal = block.timestamp;
    properties[propertyID].renter = renter;
    properties[propertyID].timeToRent = timeToRent;
    properties[propertyID].rented = true;
  }

  function getAllRenterProperties(address user) public view returns(Property[] memory) {
    Property[] memory _renterProperty = new Property[](renterPropertyAmount[user]);
    for (uint256 i = 0; i < properties.length; i++) {
      if (properties[i].renter == user && properties[i].rented == true) {
        _renterProperty[i] = properties[i];
      }
    }
    return _renterProperty;
  }

  function getAllPropertiesOnMarket() public view returns(Property[] memory) {
    Property[] memory _propertyOnMarket = new Property[](propertyOnMarket.current());
    for (uint256 i = 0; i < properties.length; i++) {
      if (properties[i].onMarket == true) {
        _propertyOnMarket[i] = properties[i];
      }
    }
    return _propertyOnMarket;
  }

}
