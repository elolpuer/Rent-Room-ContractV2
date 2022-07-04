//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./Rentable.sol";

abstract contract ERC721Rentable is ERC721Upgradeable, OwnableUpgradeable, Rentable {

    //setting rent contract to give mint/burn permission
    function setRentAddress(address _rent) external onlyOwner {
      setRent(_rent);
    }

    function isRented(uint256 tokenId) public returns(bool rented, address renter) {
      Property memory _property = rent.getProperty(tokenId);
      return (_property.rented, _property.renter);
    }

    modifier isRentedMod(uint256 tokenId) {
      (bool rented, ) = isRented(tokenId);
      require(rented == false, "ERC721Rentable: token already rented");
      _;
    }

    function initialize(string memory name, string memory symbol) public initializer {
      __ERC721_init(name, symbol);
      __Ownable_init();
    }

    function approveRent(address to, uint256 tokenId) public isRentedMod(tokenId) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Rentable: approveRent caller is not owner nor approved");
        require(approveRented[tokenId] == address(0), "ERC721Rentable: approveRent already exist");
        require(to != address(0), "ERC721Rentable: Zero Address Approve to");
        approveRented[tokenId] = to;
        emit ApproveRent(to, tokenId);
    }

    function disapproveRent(address to, uint256 tokenId) public isRentedMod(tokenId) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Rentable: disapproveRent caller is not owner nor approved");
        approveRented[tokenId] = address(0);
        emit DisapproveRent(to, tokenId);
    }
    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override isRentedMod(tokenId) {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override isRentedMod(tokenId) {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override isRentedMod(tokenId) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }


}
