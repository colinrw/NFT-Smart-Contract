// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// Import contracts
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// Import helper functions
import { Base64 } from './libraries/Base64.sol';

// Inherit OpenZeppelin contract ERC721URIStorage
// We can use all functionalities from this contract in our contract! :)
contract MyEpicNFT is ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
    // So, we make a baseSvg variable here that all our NFTs can use.
    string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string svgPartTwo = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = ["My", "Your", "Ours", "Their", "His", "Her"];
    string[] secondWords = ["Astonishing", "Fabulous", "Fenominal", "Amazing", "Excellent", "formidable"];
    string[] thirdWords = ["Cat", "Dog", "NFT", "Dad", "Death", "Wallet"];

    // Background colors
    string[] colors = ["#FFD0DE", "#9FCABF", "#102A3E", "#FF8385", "#617F46", "#613F82"];

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721 ("Bleompot NFT Collection", "BLMPT") {
        console.log("Deploying NFT project in 3..2..1");
    }

    function getTotalNFTsMintedSoFar() public view returns (uint256) {
        return _tokenIds.current();
    }

    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));

        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));

        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));

        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function pickRandomColor(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));

        rand = rand % colors.length;
        return colors[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    // Function that gets called within our Contract by external users
    function makeAnEpicNFT() public {
        require(_tokenIds.current() >= getTotalNFTsMintedSoFar(), "SOLD OUT");
        uint256 newItemId = _tokenIds.current();

        console.log('-------');
        console.log(_tokenIds.current());

        // Grab random numbers
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(abi.encodePacked(first, second, third));

        // Concat the strings together
        string memory randomColor = pickRandomColor(newItemId);
        string memory finalSvg = string(abi.encodePacked(svgPartOne, randomColor, svgPartTwo, combinedWord, "</text></svg>"));
        
        // Get the JSON object for the NFT
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )   
                )
            )
        );

        // Just liek before, we prepend data:application/json;base64, to our data
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");
        
        // The magical function that actually mints the NFT and sends it to the person calling the contract
        // In this case the NFT will be send to `msg.sender` aka the caller of the function
        _safeMint(msg.sender, newItemId);

        // The URI of a token is the metadata of this particular minted NFT
        _setTokenURI(newItemId, finalTokenUri);
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

        // The amount of tokens within this Contract gets incremented by 1
        // A Contract can't have duplicated ID's
        _tokenIds.increment();

        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}