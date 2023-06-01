// SPDX-License-Identifier: CC0-1.0

/// @title Custom Nouns

/**
 * ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
 * █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█
 * █░░░░░░░░░██████████████░░██████████████░░░█
 * █░░░░░░░░░██▒▒▒▒▒░░░░░██░░██▒▒▒▒▒░░░░░██░░░█
 * █░░░████████▒▒▒▒▒░░░░░██████▒▒▒▒▒░░░░░██░░░█
 * █░░░██░░░░██▒▒▒▒▒░░░░░██░░██▒▒▒▒▒░░░░░██░░░█
 * █░░░██░░░░██▒▒▒▒▒░░░░░██░░██▒▒▒▒▒░░░░░██░░░█
 * █░░░░░░░░░██████████████░░██████████████░░░█
 * █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█
 * ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
 * ╔═══════════════════╗ ╔════════════════════╗
 * ║ https://nouns.wtf ║ ║ NO RIGHTS RESERVED ║
 * ╚═══════════════════╝ ╚════════════════════╝
 */

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CustomNouns is ERC721 {
    mapping(address => uint256) public stakeOf;
    mapping(uint256 => string) public imageData;
    ERC20 public pixel = ERC20(address(0));
    uint256 public totalSupply;

    constructor() ERC721("Custom Nouns", "CUSTOMNOUNS") {}

    function mint(uint256 _initialValue, string memory _imageData) public {
        uint256 tokenId = ++totalSupply;

        if (_initialValue > 0) {
            stake(tokenId, _initialValue);
        }

        _safeMint(msg.sender, tokenId);
    }

    function burn(uint256 _tokenId) public {
        unstake(_tokenId, stakeOf[msg.sender]);

        _burn(_tokenId);

        totalSupply--;
    }

    function stake(uint256 _tokenId, uint256 _value) public {
        if (_value <= 0) {
            revert("Staked value must not be less than or equal to 0");
        }

        pixel.transferFrom(msg.sender, address(this), _value);
    }

    function unstake(uint256 _tokenId, uint256 _value) public {
        if (_value > stakeOf[msg.sender]) {
            revert("Value to unstake must not be greater than staked value");
        }

        pixel.transferFrom(address(this), msg.sender, _value);
    }
}
