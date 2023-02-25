// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721, Ownable {
    using Strings for uint256;

    uint256 public constant MAX_TOKENS = 10000;
    uint256 private constant TOKENS_RESERVED = 5;
    // uint public price = 100000000000000000; // 0.1 ETH
    uint256 public price = 0;
    uint256 public constant MAX_MINT_PER_TX = 1;

    bool public isSaleActive;
    uint256 public totalSupply;
    mapping(address => uint256) private mintedPerWallet;

    string public baseUri;
    string public baseExtension = ".json";

    constructor() ERC721("Ai3.co", "AI3CO") {
        baseUri = "ipfs://xxxxxxxxxxxxxxxxxxxxxxxxxxxxx/";
        for (uint256 i = 1; i <= TOKENS_RESERVED; ++i) {
            _safeMint(msg.sender, i);
        }
        totalSupply = TOKENS_RESERVED;
    }

    // Public Functions
    function mint(uint256 _numTokens) external payable {
        require(isSaleActive, "The sale is paused.");
        require(
            _numTokens <= MAX_MINT_PER_TX,
            "You cannot mint that many in one transaction."
        );
        require(
            mintedPerWallet[msg.sender] + _numTokens <= MAX_MINT_PER_TX,
            "You cannot mint that many total."
        );
        uint256 curTotalSupply = totalSupply;
        require(
            curTotalSupply + _numTokens <= MAX_TOKENS,
            "Exceeds total supply."
        );
        require(_numTokens * price <= msg.value, "Insufficient funds.");

        for (uint256 i = 1; i <= _numTokens; ++i) {
            _safeMint(msg.sender, curTotalSupply + i);
        }
        mintedPerWallet[msg.sender] += _numTokens;
        totalSupply += _numTokens;
    }

    // Owner-only functions
    function flipSaleState() external onlyOwner {
        isSaleActive = !isSaleActive;
    }

    function setBaseUri(string memory _baseUri) external onlyOwner {
        baseUri = _baseUri;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function withdrawAll() external payable onlyOwner {
        uint256 balance = address(this).balance;
        uint256 balanceOne = (balance * 70) / 100;
        uint256 balanceTwo = (balance * 30) / 100;
        (bool transferOne, ) = payable(
            0x7ceB3cAf7cA83D837F9d04c59f41a92c1dC71C7d
        ).call{value: balanceOne}("");
        (bool transferTwo, ) = payable(
            0x7ceB3cAf7cA83D837F9d04c59f41a92c1dC71C7d
        ).call{value: balanceTwo}("");
        require(transferOne && transferTwo, "Transfer failed.");
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }
}
