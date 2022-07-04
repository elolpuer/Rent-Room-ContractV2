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

  it("Should change property Deposit", async () => {
    const newDeposit = price * 60;
    //Changing
    await rent.changePropertyDeposit("1", newDeposit)
    const property = await rent.getProperty("1")
    assert(
      newDeposit == property.deposit,
      "changing deposit"
    )
  });

  it("Should change property Price", async () => {
    const newPrice = ethers.utils.parseEther("0.01")
    //Changing
    await rent.changePropertyPrice("1", newPrice)
    const property = await rent.getProperty("1")
    assert(
      newPrice.toString() == property.price.toString(),
      "changing price"
    )
  });

  it("Should change property minTimeToRent", async () => {
    const newMinTimeToRent = minTimeToRent + secondsInDay
    //Changing
    await rent.changePropertyMinTimeToRent("1", newMinTimeToRent)
    const property = await rent.getProperty("1")
    assert(
      newMinTimeToRent == property.minTimeToRent,
      "changing minTimeToRent"
    )
  });

  it("Should change property maxTimeToRent", async () => {
    const newMaxTimeToRent = maxTimeToRent + secondsInDay
    //Changing
    await rent.changePropertyMaxTimeToRent("1", newMaxTimeToRent)
    const property = await rent.getProperty("1")
    assert(
      newMaxTimeToRent == property.maxTimeToRent,
      "changing minTimeToRent"
    )
  });

})
