//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

interface IProperty {

  event Mint(address to, uint256 id);
  event Burn(address from, uint256 id);

  function mint() external;
  function burn(uint256 tokenId) external;
  // function owner() external view returns(address);

}
