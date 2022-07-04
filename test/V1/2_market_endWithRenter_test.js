const { assert, expect } = require("chai");
const { ethers, upgrades, waffle } = require("hardhat");

describe("Market End With Renter", function () {

  let signer;
  let renter;
  let property;
  let rent;
  const secondsInDay = 86400;
  const price = ethers.utils.parseEther("0.00001");
  const deposit = price * 30;

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
  })

  it("Should add property to market", async () => {
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

  it("Should rent property", async () => {
    const signerBalanceBefore = await ethers.provider.getBalance(signer.address)
    const renterBalanceBeforeRent = await ethers.provider.getBalance(renter.address)
    const timeToRent = secondsInDay * 31
    const valueToSend = price * (timeToRent / secondsInDay) + deposit
    //give approve to rent contract
    await property.approve(rent.address, "1")
    //rent property
    await rent.connect(renter).rent(
      "1",                //propertyID
      timeToRent,         //timeToRent
      {value: valueToSend}
    )
    //get all renter property
    let renterProperties = await rent.getAllRenterProperties(renter.address)
    assert(
      (renterProperties[0].tokenID == 1) && (renterProperties[0].rented == true),
      "Rent first token"
    )
    //increasing time in blockchain for 32 days
    //32 days is when rent is over
    await ethers.provider.send("evm_increaseTime", [secondsInDay * 32])
    //ending with owner
    const renterBalanceBeforeRentEnd =  await ethers.provider.getBalance(renter.address)
    await rent.connect(renter).endRentRenter("1")
    const renterBalanceAfterRentEnd = await ethers.provider.getBalance(renter.address)
    //get all renter property
    renterProperties = await rent.getAllRenterProperties(renter.address)
    //renter property is zero
    assert(
      renterProperties.length == 0,
      "Renter zero"
    )
    const signerBalanceAfter = await ethers.provider.getBalance(signer.address)
    //check if ok with balance
    assert(
      signerBalanceBefore < signerBalanceAfter,
      "Earn from rent"
    )
    assert(
      renterBalanceAfterRentEnd < renterBalanceBeforeRent,
      "Lose after rent"
    )
    //with should get our deposit back
    //so before we end our rent
    //renter didnt have price for property + Deposit
    //after we end our rent
    //renter didnt have only price for property
    assert(
      renterBalanceBeforeRentEnd < renterBalanceAfterRentEnd,
      "Get deposit back"
    )
    await expect(
      rent.endRentOwner("1")
    ).to.be.revertedWith("Marketplace: value and deposit already sended")
  })

})
