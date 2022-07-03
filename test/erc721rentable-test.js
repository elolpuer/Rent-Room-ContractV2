const { assert, expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("Property Creation", function () {

  let signer;
  let property;
  let rent;

  before(async () => {
    signer = await ethers.getSigner()
    const Property = await ethers.getContractFactory("Property");
    const Rent = await ethers.getContractFactory("Rent");
    property = await upgrades.deployProxy(Property, ["Property", "PRT"], { initializer: "initialize" })
    await property.deployed()
    rent = await upgrades.deployProxy(Rent, [property.address], { initializer: "initialize" })
    await rent.deployed()
    //set rent address to property
    await property.setRentAddress(rent.address)
  })

  it("Should mint property as erc721", async () => {
    //create property on rent contract
    await rent.createProperty(
      ethers.utils.parseEther("1")
    )
    //check property owner on rent contract
    assert.equal(
      signer.address,
      (await rent.properties("0")).owner,
      "Property Creation: signer not owner or property was not creat"
    )
    //check if property exist on property contract
    assert(
      await property.userPropertyAmount(signer.address) == 1,
      "Property Creation: on property contract signer address not exist"
    )
  });

  it("Should delete property", async () => {
    //delete property on rent contract
    await rent.deleteProperty(
      "0" //Property id on array
    )

    //check property on rent contract set to zero
    assert.equal(
      "0x0000000000000000000000000000000000000000",
      (await rent.properties("0")).owner,
      "Property Delete: property was not delete"
    )

    //check if property not exist on property contract
    assert(
      await property.userPropertyAmount(signer.address) == 0,
      "Property Delete: on property contract signer address exist"
    )

  })


});
