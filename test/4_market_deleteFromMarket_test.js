const { assert, expect } = require("chai");
const { ethers, upgrades, waffle } = require("hardhat");

describe("Changing property entities", function () {

  let signer;
  let renter;
  let property;
  let rent;
  const secondsInDay = 86400;
  const price = ethers.utils.parseEther("0.00001");
  const deposit = price * 30;
  const minTimeToRent = secondsInDay * 30
  const maxTimeToRent = secondsInDay * 60

  before(async () => {
    const signers = await ethers.getSigners()
    signer = signers[0]
    renter = signers[1]
    const Property = await ethers.getContractFactory("Property");
    const Rent = await ethers.getContractFactory("Rent");
    property = await upgrades.deployProxy(Property, ["Property", "PRT"], { initializer: "initialize" })
    await property.deployed()
    rent = await upgrades.deployProxy(Rent, [property.address], { initializer: "initialize" })
    await rent.deployed()
    //set rent address to property
    await property.setRentAddress(rent.address)
    //create property on rent contract
    await rent.createProperty()
    //adding property to market
    await rent.addPropertyToMarket(
      "1",                //propertyID
      minTimeToRent,      //minTimeToRent
      maxTimeToRent,      //maxTimeToRent
      price,              //price per day
      deposit             //deposit
    )
  })

  it("Should delete property from market", async () => {
    const propertyBefore = await rent.getProperty("1")
    assert(
      true == propertyBefore.onMarket,
      "Property on market"
    )
    await rent.deletePropertyFromMarket("1")
    const propertyAfter = await rent.getProperty("1")
    assert(
      false == propertyAfter.onMarket,
      "Property not on market"
    )
  });

})
