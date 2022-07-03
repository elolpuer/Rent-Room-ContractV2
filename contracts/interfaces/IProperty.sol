//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

interface IProperty {


  event Mint(address to, uint256 id);
  event Burn(address from, uint256 id);
  event ApproveRent(address to, uint256 tokenId);
  event DisapproveRent(address to, uint256 tokenId);

  function mint(address to) external returns(uint256);
  function burn(uint256 tokenId, address from) external;
  function userPropertyAmount(address user) external returns(uint256);
  // function owner() external view returns(address);

}
