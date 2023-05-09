// SPDX-License-Identifier: CC0-1.0

/// @title Hub

/**
 * ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
 * █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█
 * █░░░░░░░░░██████████████░░██████████████░░░█
 * █░░░░░░░░░██░░░░░▒▒▒▒▒██░░██░░░░░▒▒▒▒▒██░░░█
 * █░░░████████░░░░░▒▒▒▒▒██████░░░░░▒▒▒▒▒██░░░█
 * █░░░██░░░░██░░░░░▒▒▒▒▒██░░██░░░░░▒▒▒▒▒██░░░█
 * █░░░██░░░░██░░░░░▒▒▒▒▒██░░██░░░░░▒▒▒▒▒██░░░█
 * █░░░░░░░░░██████████████░░██████████████░░░█
 * █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█
 * ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
 * ╔═══════════════════╗ ╔════════════════════╗
 * ║ https://nouns.wtf ║ ║ NO RIGHTS RESERVED ║
 * ╚═══════════════════╝ ╚════════════════════╝
*/


pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract Hub is ERC721, ERC721Burnable {


    mapping(uint256 => string) public nouns;


    constructor() ERC721("Hub Nouns", "HUBNOUN") {
    }
    

    function stake(uint256 _amount, string calldata _runLengthEncodedImage) public {

    }

    function unstake() public {

    }

    function merge() public {

    }

    function increaseStake(uint256 _amount) public {

    }

    function decreaseStake(uint256 _amount) public {

    }

    function vote(uint256 _proposalId) external {
       
    }

    function createProposal() external {

    }

    function crowdsourceProposal() external {

    }
}
