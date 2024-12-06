// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MyNFT.sol";

contract MyNFTTest is Test {
    MyNFT private nftContract;

    address private admin = address(0x111);
    address private recipient = address(0x222);

    function setUp() public {
        vm.startPrank(admin);
        nftContract = new MyNFT();
        vm.stopPrank();
    }

    function testCreateNFT() public {
        vm.startPrank(admin);

        MyNFT.ClimateData memory initialData = MyNFT.ClimateData({
            temp: 22,
            moisture: 55,
            wind: 12,
            weatherPic: "weather_image_url",
            details: "Clear skies"
        });

        string memory metadataTemplate = "https://weatherapi.example.com";

        nftContract.createNFT(recipient, initialData, metadataTemplate);
        assertEq(nftContract.ownerOf(0), recipient);

        MyNFT.ClimateData[] memory history = nftContract.fetchRecords(0);
        assertEq(history.length, 1);
        assertEq(history[0].temp, 22);
        assertEq(history[0].moisture, 55);

        vm.stopPrank();
    }

    function testModifyClimate() public {
        vm.startPrank(admin);

        MyNFT.ClimateData memory initialData = MyNFT.ClimateData({
            temp: 22,
            moisture: 55,
            wind: 12,
            weatherPic: "weather_image_url",
            details: "Clear skies"
        });

        nftContract.createNFT(recipient, initialData, "https://weatherapi.example.com");

        MyNFT.ClimateData memory updatedData = MyNFT.ClimateData({
            temp: 18,
            moisture: 65,
            wind: 10,
            weatherPic: "updated_weather_image",
            details: "Rainy"
        });

        nftContract.modifyClimate(0, updatedData);

        MyNFT.ClimateData[] memory history = nftContract.fetchRecords(0);
        assertEq(history.length, 2);
        assertEq(history[1].temp, 18);
        assertEq(history[1].details, "Rainy");

        vm.stopPrank();
    }

    function testTokenURI() public {
        vm.startPrank(admin);

        MyNFT.ClimateData memory initialData = MyNFT.ClimateData({
            temp: 22,
            moisture: 55,
            wind: 12,
            weatherPic: "weather_image_url",
            details: "Clear skies"
        });

        nftContract.createNFT(recipient, initialData, "https://weatherapi.example.com");

        string memory expectedURI = "https://weatherapi.example.com?temp=22&moisture=55&wind=12&details=Clear skies";
        assertEq(nftContract.tokenURI(0), expectedURI);

        vm.stopPrank();
    }

    function testUnauthorizedAccess() public {
        vm.startPrank(recipient);

        MyNFT.ClimateData memory data = MyNFT.ClimateData({
            temp: 25,
            moisture: 60,
            wind: 15,
            weatherPic: "unauthorized_image_url",
            details: "Unauthorized update"
        });

        vm.expectRevert("Ownable: caller is not the owner");
        nftContract.createNFT(recipient, data, "https://weatherapi.example.com");

        vm.stopPrank();
    }
}
