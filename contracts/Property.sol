//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "./token/ERC721Rentable.sol";
import "./interfaces/IProperty.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Property is ERC721Rentable, IProperty {
  using Counters for Counters.Counter;

  //setting rent contract to give mint/burn permission
  function setRentAddress(address rent) external onlyOwner {
    setRent(rent);
  }

  function mint() external onlyRent {
    address sender = msg.sender;
    tokenIds.increment();
    uint256 current = tokenIds.current();
    _mint(sender, current);
    emit Mint(sender, current);
  }

  function burn(uint256 tokenId) external onlyRent {
    require(ownerOf(tokenId) == msg.sender, "Rent: only room owner");
    _burn(tokenId);
    emit Burn(msg.sender, tokenId);
  }

}
