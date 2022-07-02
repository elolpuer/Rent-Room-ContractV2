const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("ERC721Rentable Mint", function () {
  it("Should mint token", async function () {
    const signer = await ethers.getSigner()
    const ERC721Rentable = await ethers.getContractFactory("ERC721Rentable");
    const erc721 = await upgrades.deployProxy(ERC721Rentable, "Property", "PRT", { initializer: initialize })
    await erc721.deployed()
    await erc721.mint(signer.address)
  });
});
