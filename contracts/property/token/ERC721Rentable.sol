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

    modifier isRented(uint256 tokenId) {
      Property memory _property = rent.getProperty(tokenId);
      require(_property.rented == false, "ERC721Rentable: Property is rent");
      _;
    }

    function initialize(string memory name, string memory symbol) public initializer {
      __ERC721_init(name, symbol);
      __Ownable_init();
    }

    function approveRent(address to, uint256 tokenId) public isRented(tokenId) {
        require(_isApprovedOrOwner(to, tokenId), "ERC721Rentable: approveRent caller is not owner nor approved");
        require(approveRented[tokenId] == address(0), "ERC721Rentable: approveRent already exist");
        approveRented[tokenId] = to;
        emit ApproveRent(to, tokenId);
    }

    function disapproveRent(address to, uint256 tokenId) public isRented(tokenId) {
        require(_isApprovedOrOwner(to, tokenId), "ERC721Rentable: disapproveRent caller is not owner nor approved");
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
    ) public override isRented(tokenId) {
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
    ) public override isRented(tokenId) {
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
    ) public override isRented(tokenId) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }


}
