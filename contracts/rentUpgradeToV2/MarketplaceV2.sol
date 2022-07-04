//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "../rent/Marketplace.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

abstract contract MarketplaceV2 is Marketplace {
  using Counters for Counters.Counter;

  mapping(uint256 => address) public customTokenPaymentToProperty;

  function addPropertyToMarketWithCustomTokenPayment(
    uint256 propertyID,
    uint256 minTimeToRent,
    uint256 maxTimeToRent,
    uint256 price,           //per day
    uint256 deposit,         //amount in wei full
    address token            //token address
  )
    public
    isPropertyOwner(propertyID)
    isPropertyNotOnMarket(propertyID)
  {
    properties[propertyID].onMarket = true;
    properties[propertyID].minTimeToRent = minTimeToRent;
    properties[propertyID].maxTimeToRent = maxTimeToRent;
    properties[propertyID].price = price;
    properties[propertyID].deposit = deposit;
    customTokenPaymentToProperty[propertyID] = token;
    propertyOnMarket.increment();
    emit AddPropertyOnMarket(propertyID, price, block.timestamp);
  }

  function rentWithCustomTokenPayment(
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
    IERC20Upgradeable token = IERC20Upgradeable(customTokenPaymentToProperty[propertyID]);
    //price per one day * amount of days + deposit
    uint256 allValueToSend = cost(propertyID, timeToRent);
    token.transferFrom(msg.sender, address(this), allValueToSend);
    _rent(propertyID, timeToRent, msg.sender);
    emit RentProperty(
      propertyID,
      properties[propertyID].renter,
      properties[propertyID].timeDeal,
      properties[propertyID].timeToRent
    );
  }

  function endRentOwnerWithCustomTokenPayment(
    uint256 propertyID
  )
    public
    isPropertyOwner(propertyID)
    isPropertyOnMarket(propertyID)
    isRentEnded(propertyID)
    nonReentrant
  {
    require(properties[propertyID].rented == true, "Marketplace: value and deposit already sended");
    _endRentWithCustomTokenPayment(propertyID);
  }

  function endRentRenterWithCustomTokenPayment(
    uint256 propertyID
  )
    public
    isPropertyOnMarket(propertyID)
    isRentEnded(propertyID)
    nonReentrant
  {
    require(properties[propertyID].renter == msg.sender, "Marketplace: You not a renter");
    require(properties[propertyID].rented == true, "Marketplace: value and deposit already sended");
    _endRentWithCustomTokenPayment(propertyID);
  }

  function _endRentWithCustomTokenPayment(uint256 propertyID) private {
    IERC20Upgradeable token = IERC20Upgradeable(customTokenPaymentToProperty[propertyID]);
    uint256 contractCommision = _costForRent(propertyID) * commision / 1000000;
    contractEarned += contractCommision;
    uint256 earnedAmount = _costForRent(propertyID) - contractCommision;
    token.transfer(properties[propertyID].owner, earnedAmount);
    address renter = properties[propertyID].renter;
    token.transfer(renter, properties[propertyID].deposit);
    properties[propertyID].renter = address(0);
    properties[propertyID].timeDeal = 0;
    properties[propertyID].timeToRent = 0;
    properties[propertyID].rented = false;
    renterPropertyAmount[renter] -= 1;
    property.disapproveRent(renter, propertyID);
    emit EndRent(propertyID, block.timestamp);
  }

}
