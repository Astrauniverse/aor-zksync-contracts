// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


abstract contract MetadataStorage is ERC721 {
    using Strings for uint256;

    struct Metadata {
        string image;
        string animation_url;
        string attr_name;
        string attr_type;
        string attr_rank;
        uint256 attr_hull;
        uint256 attr_energy;
        uint256 attr_speed;


        uint256 attr_fight;
        uint256 attr_exploration;
        uint256 attr_harvest;
    }

    // tokenId => Metadata
    mapping(uint256 => Metadata) public tokenMetadata;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        Metadata memory md = tokenMetadata[tokenId];
        string memory base = _baseURI();
        string memory image = md.image;
        string memory animation_url = md.animation_url;

        if (bytes(base).length > 0) {
            image =  string(abi.encodePacked(base, image));
            animation_url = string(abi.encodePacked(base, animation_url));
        }
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "AstraOmniRise Spaceship #',
            tokenId.toString(),
            '",',
            '"image": "',
            image,
            '",',
            '"animation_url": "',
            animation_url,
            '",',
            '"attributes": ',
            generateAttributes(md),
            "}"
        );
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    function generateAttributes(Metadata memory md) public pure returns (bytes memory) {
        uint256 fight = md.attr_fight;
        uint256 exploration = md.attr_exploration;
        uint256 harvest = md.attr_harvest;
        return
        abi.encodePacked(
            "[",
            _attr("NAME", md.attr_name),",",
            _attr("TYPE", md.attr_type),",",
            _attr("RANK", md.attr_rank),",",
            _attr("HULL", md.attr_hull.toString()),",",
            _attr("ENERGY", md.attr_energy.toString()),",",
            _attr("SPEED", md.attr_speed.toString()),fight>0?",":"",
            fight>0?string(_attr("FIGHT", fight.toString())):"",exploration>0?",":"",
            exploration>0?string(_attr("EXPLORATION", exploration.toString())):"",harvest>0?",":"",
            harvest>0?string(_attr("HARVEST", harvest.toString())):"",
            "]"
        );
    }

    function _attr(
        string memory name,
        string memory value
    ) private pure returns (bytes memory) {
        return
        abi.encodePacked(
            '{"trait_type":"',
            name,
            '","value":"',
            value,
            '"}'
        );
    }


    function _setTokenMetadata(uint256 tokenId, Metadata memory _metadata) internal virtual {
        require(_exists(tokenId), "MetadataStorage: metadata set of nonexistent token");
        tokenMetadata[tokenId] = _metadata;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        delete tokenMetadata[tokenId];
    }
}
