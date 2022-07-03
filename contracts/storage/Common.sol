//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

interface Common {

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

}
