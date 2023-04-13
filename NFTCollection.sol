// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC721/IERC721Receiver.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/utils/Counters.sol";

contract NFTMinter is IERC721Receiver {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _collectionIds;

    struct Collection {
        address owner;
        string name;
        string symbol;
        uint256 percentage;
    }

    mapping(uint256 => Collection) private _collections;
    mapping(uint256 => mapping(uint256 => bool)) private _nftsInCollection;

    event CollectionCreated(uint256 indexed collectionId, address indexed owner, string name, string symbol, uint256 percentage);
    event NFTMinted(uint256 indexed tokenId, address indexed owner, uint256 collectionId);
    event NFTAddedToCollection(uint256 indexed tokenId, uint256 indexed collectionId);
    event NFTRemovedFromCollection(uint256 indexed tokenId, uint256 indexed collectionId);

    function createCollection(string memory name, string memory symbol, uint256 percentage) public returns (uint256) {
        _collectionIds.increment();
        uint256 collectionId = _collectionIds.current();
        _collections[collectionId] = Collection(msg.sender, name, symbol, percentage);
        emit CollectionCreated(collectionId, msg.sender, name, symbol, percentage);
        return collectionId;
    }

    function mintNFT(address to) public returns (uint256) {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        emit NFTMinted(tokenId, to, 0);
        return tokenId;
    }

    function addToCollection(uint256 collectionId, uint256 tokenId) public {
        require(_collections[collectionId].owner == msg.sender, "NFTMinter: caller is not the collection owner");
        require(!_nftsInCollection[collectionId][tokenId], "NFTMinter: NFT is already in the collection");
        _nftsInCollection[collectionId][tokenId] = true;
        emit NFTAddedToCollection(tokenId, collectionId);
    }

    function removeFromCollection(uint256 collectionId, uint256 tokenId) public {
        require(_collections[collectionId].owner == msg.sender, "NFTMinter: caller is not the collection owner");
        require(_nftsInCollection[collectionId][tokenId], "NFTMinter: NFT is not in the collection");
        _nftsInCollection[collectionId][tokenId] = false;
        emit NFTRemovedFromCollection(tokenId, collectionId);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
