//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./Rentable.sol";

abstract contract ERC721Rentable is ERC721Upgradeable, OwnableUpgradeable, Rentable {

    event ApproveRent();
    event DisapproveRent();

    modifier isRented(uint256 tokenId) {
      (bool isOnRent, uint256 rentedId) = findRentedIdByTokenId(tokenId);
      if (isOnRent == false) {
        require(false, "Not on rent");
      }
      require(rentedTokens[rentedId].isRent == false, "Token is rented");
      _;
    }

    function initialize(string memory name, string memory symbol) public initializer {
      __ERC721_init(name, symbol);
      __Ownable_init();
    }

    function approveRent(address to, uint256 tokenId) public isRented(tokenId) {
        require(_isApprovedOrOwner(to, tokenId), "ERC721: transfer caller is not owner nor approved");
        emit ApproveRent();
    }

    function disapproveRent(address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(to, tokenId), "ERC721: transfer caller is not owner nor approved");
        emit DisapproveRent();
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
    ) public override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function findRentedIdByTokenId(uint256 tokenId) private view returns(bool, uint256) {
      for (uint256 i = 0; i < rentedTokens.length; i++) {
        if (rentedTokens[i].tokenId == tokenId) {
          return (true, i);
        }
      }
      return (false, 0);
    }

}
