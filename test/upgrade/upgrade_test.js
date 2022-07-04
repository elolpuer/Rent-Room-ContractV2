const { assert, expect } = require("chai");
const { ethers, upgrades, waffle } = require("hardhat");

describe("Updated (With custom token) Market End With Owner", function () {

  let signer;
  let renter;
  let property;
  let rent;
  let token;
  const secondsInDay = 86400;
  const price = ethers.utils.parseEther("0.00001");
  const deposit = price * 30;

  before(async () => {
    const signers = await ethers.getSigners()
    signer = signers[0]
    renter = signers[1]
    const CustomToken = await ethers.getContractFactory("CustomToken");
    token = await upgrades.deployProxy(CustomToken, [renter.address, "CustomToken", "CST"], { initializer: "initialize" });
    await token.deployed()
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
  })



  it("Should add property V1", async () => {
    //adding property to market
    await rent.addPropertyToMarket(
      "1",                //propertyID
      secondsInDay * 30,  //minTimeToRent
      secondsInDay * 60,  //maxTimeToRent
      price,              //price per day
      deposit             //deposit
    )
    //get all properties on market
    const propertiesOnMarket = await rent.getAllPropertiesOnMarket()
    //check if at least one
    assert.isAtLeast(
        propertiesOnMarket.length,
        1,
        "Market Test: At least one property on market"
      )
  });

  it("Should update rent", async () => {
    const RentV2 = await ethers.getContractFactory("RentV2");
    const rentV2 = await upgrades.upgradeProxy(rent.address, RentV2)
    //create property on rent contract
    await rentV2.createProperty()
    //adding property to market
    await rentV2.addPropertyToMarketWithCustomTokenPayment(
      "2",                //propertyID
      secondsInDay * 30,  //minTimeToRent
      secondsInDay * 60,  //maxTimeToRent
      price,              //price per day
      deposit,            //deposit
      token.address
    )
    //get all properties on market
    const propertiesOnMarket = await rentV2.getAllPropertiesOnMarket()
    //check if at least one
    assert.isAtLeast(
        propertiesOnMarket.length,
        2,
        "Market Test: At least one property on market"
      )
  })


})
