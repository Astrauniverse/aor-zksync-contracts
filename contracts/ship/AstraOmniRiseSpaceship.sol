// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./MetadataStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

contract AstraOmniRiseSpaceship is DefaultOperatorFilterer,ERC721, ERC721Enumerable, MetadataStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    Counters.Counter private _tokenIdCounter;

    EnumerableSet.AddressSet private  _minters;

    constructor() ERC721("AstraOmniRise Spaceship", "AORSS") {}

    function isMinter(address value) public view returns (bool) {
        return _minters.contains(value);
    }

    function addMinter(address value) public onlyOwner returns (bool) {
        return _minters.add(value);
    }
    function removeMinter(address value) public onlyOwner returns (bool) {
        return _minters.remove(value);
    }

    function getMinters() public view returns (address[] memory){
        return _minters.values();
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    function safeMint(address to, Metadata memory md) public {

        require(isMinter(_msgSender()) , "AstraOmniRiseSpaceship: caller is not the minter");

        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        require(bytes(md.image).length > 0 , "AstraOmniRiseSpaceship: metadata error");
        require(bytes(md.animation_url).length > 0 , "AstraOmniRiseSpaceship: metadata error");
        require(bytes(md.attr_name).length > 0 , "AstraOmniRiseSpaceship: metadata error");
        require(bytes(md.attr_type).length > 0 , "AstraOmniRiseSpaceship: metadata error");
        require(bytes(md.attr_rank).length > 0 , "AstraOmniRiseSpaceship: metadata error");
        _setTokenMetadata(tokenId,md);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
    internal
    override(ERC721, ERC721Enumerable) onlyAllowedOperator(from)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, MetadataStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, MetadataStorage)
    returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


    function setApprovalForAll(address operator, bool approved)
    public
    override (IERC721,ERC721) onlyAllowedOperatorApproval(operator)
    {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public
    override (IERC721,ERC721) onlyAllowedOperatorApproval(operator)
    {
        super.approve(operator, tokenId);
    }
}