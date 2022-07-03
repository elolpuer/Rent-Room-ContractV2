//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "./token/ERC721Rentable.sol";
import "../interfaces/IProperty.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Property is ERC721Rentable {
  using Counters for Counters.Counter;

  function mint(address to) external onlyRent returns(uint256) {
    tokenIds.increment();
    uint256 current = tokenIds.current();
    _mint(to, current);
    userPropertyAmount[to] += 1;
    emit Mint(to, current);
    return current;
  }

  function burn(uint256 tokenId, address from) external onlyRent {
    require(ownerOf(tokenId) == from, "Rent: only room owner");
    _burn(tokenId);
    userPropertyAmount[from] -= 1;
    emit Burn(from, tokenId);
  }

}
