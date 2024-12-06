// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    uint256 private _tokenCounter;

    struct ClimateData {
        int256 temp;
        uint256 moisture;
        uint256 wind;
        string weatherPic;
        string details;
    }

    mapping(uint256 => ClimateData[]) private _climateRecords;
    mapping(uint256 => string) private _uriTemplate;

    event ClimateUpdated(uint256 indexed id, ClimateData data);

    constructor() ERC721("WeatherNFT", "WNFT") {}

    /// @notice Mint a new NFT
    /// @param recipient Address to receive the NFT
    /// @param startData Initial weather data
    /// @param baseURI Template for metadata
    function createNFT(
        address recipient,
        ClimateData memory startData,
        string memory baseURI
    ) external onlyOwner {
        uint256 tokenId = _tokenCounter;
        _safeMint(recipient, tokenId);
        _climateRecords[tokenId].push(startData);
        _uriTemplate[tokenId] = baseURI;
        _tokenCounter++;
    }

    /// @notice Update the climate data for an NFT
    /// @param id ID of the NFT
    /// @param newData New weather data
    function modifyClimate(uint256 id, ClimateData memory newData) external onlyOwner {
        require(_exists(id), "NFT does not exist");
        _climateRecords[id].push(newData);
        emit ClimateUpdated(id, newData);
    }

    /// @notice Retrieve climate records for an NFT
    /// @param id ID of the NFT
    /// @return Array of climate data
    function fetchRecords(uint256 id) external view returns (ClimateData[] memory) {
        require(_exists(id), "NFT does not exist");
        return _climateRecords[id];
    }

    /// @notice Get specific climate data by index
    /// @param id ID of the NFT
    /// @param idx Index of the data
    /// @return Specific climate data
    function getDataByIndex(uint256 id, uint256 idx) external view returns (ClimateData memory) {
        require(_exists(id), "NFT does not exist");
        require(idx < _climateRecords[id].length, "Index out of range");
        return _climateRecords[id][idx];
    }

    /// @notice Override tokenURI to generate dynamic metadata
    /// @param id ID of the NFT
    /// @return Generated URI
    function tokenURI(uint256 id) public view override returns (string memory) {
        require(_exists(id), "NFT does not exist");
        ClimateData memory currentData = _climateRecords[id][_climateRecords[id].length - 1];
        return string(abi.encodePacked(
            _uriTemplate[id],
            "?temp=", toString(currentData.temp),
            "&moisture=", toString(currentData.moisture),
            "&wind=", toString(currentData.wind),
            "&details=", currentData.details
        ));
    }

    /// @notice Helper to convert int256 to string
    function toString(int256 value) internal pure returns (string memory) {
        return value < 0 ? string(abi.encodePacked("-", uintToString(uint256(-value)))) : uintToString(uint256(value));
    }

    /// @notice Helper to convert uint256 to string
    function uintToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        bytes memory buffer;
        while (value != 0) {
            buffer = abi.encodePacked(uint8(48 + value % 10), buffer);
            value /= 10;
        }
        return string(buffer);
    }
}
