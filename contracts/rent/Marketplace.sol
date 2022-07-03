//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "./Factory.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract Marketplace is Factory, ReentrancyGuardUpgradeable {
  using Counters for Counters.Counter;

  modifier isPropertyOnMarket(uint256 propertyID) {
    require(properties[propertyID].onMarket == false, "Marketplace: Already on market");
    _;
  }

  modifier isRentEnded(uint256 propertyID) {
    require(properties[propertyID].timeDeal + properties[propertyID].timeToRent < block.timestamp, "Marketplace: rent not ended");
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

  function changePropertyDeposit(
    uint256 propertyID,
    uint256 newDeposit
  )
    public
    isPropertyOwner(propertyID)
    isPropertyRented(propertyID)
    isPropertyOnMarket(propertyID)
  {
    properties[propertyID].deposit = newDeposit;
    emit ChangeDeposit(propertyID, newDeposit);
  }

  function changePropertyPrice(
    uint256 propertyID,
    uint256 newPrice
  )
    public
    isPropertyOwner(propertyID)
    isPropertyRented(propertyID)
    isPropertyOnMarket(propertyID)
  {
    properties[propertyID].price = newPrice;
    emit ChangePropertyPrice(propertyID, newPrice);
  }

  function changePropertyMinTimeToRent(
    uint256 propertyID,
    uint256 newMinTimeToRent
  )
    public
    isPropertyOwner(propertyID)
    isPropertyRented(propertyID)
    isPropertyOnMarket(propertyID)
  {
    properties[propertyID].minTimeToRent = newMinTimeToRent;
    emit ChangePropertyMinTimeToRent(propertyID, newMinTimeToRent);
  }

  function changePropertyMaxTimeToRent(
    uint256 propertyID,
    uint256 newMaxTimeToRent
  )
    public
    isPropertyOwner(propertyID)
    isPropertyRented(propertyID)
    isPropertyOnMarket(propertyID)
  {
    properties[propertyID].maxTimeToRent = newMaxTimeToRent;
    emit ChangePropertyMaxTimeToRent(propertyID, newMaxTimeToRent);
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
    uint256 timeToRent  //time to rent for example renter choosed 30 days he will own this property
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
    uint256 allValueToSend = _costForRent(propertyID) + properties[propertyID].deposit;
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

  //for end incentives we lock value and deposit in contract
  //so renter or owner have incentives to end rent
  //if one of these functions was called, the other cannot be called
  function endRentOwner(
    uint256 propertyID
  )
    public
    isPropertyOwner(propertyID)
    isPropertyOnMarket(propertyID)
    isRentEnded(propertyID)
    nonReentrant
  {
    require(properties[propertyID].rented == true, "Marketplace: value and deposit already sended");
    _endRent(propertyID);
  }

  function endRentRenter(
    uint256 propertyID
  )
    public
    isPropertyOnMarket(propertyID)
    isRentEnded(propertyID)
    nonReentrant
  {
    require(properties[propertyID].renter == msg.sender, "Marketplace: You not a renter");
    require(properties[propertyID].rented == true, "Marketplace: value and deposit already sended");
    _endRent(propertyID);
  }

  function _endRent(uint256 propertyID) private {
    uint256 contractCommision = _costForRent(propertyID) * commision / 1*10**6;
    contractEarned += contractCommision;
    uint256 earnedAmount = _costForRent(propertyID) - contractCommision;
    (bool success, ) = properties[propertyID].owner.call{value: earnedAmount}("");
    require(success, "Marketplace: not success sending earnedAmount");
    (bool success2, ) = properties[propertyID].renter.call{value: properties[propertyID].deposit}("");
    require(success2, "Marketplace: not success sending deposit");
    properties[propertyID].renter = address(0);
    properties[propertyID].timeDeal = 0;
    properties[propertyID].timeToRent = 0;
    properties[propertyID].rented = false;
    emit EndRent(propertyID, block.timestamp);
  }

  function _costForRent(uint256 propertyID) private view returns(uint256) {
    return properties[propertyID].price * (properties[propertyID].timeToRent / 1 days);
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
