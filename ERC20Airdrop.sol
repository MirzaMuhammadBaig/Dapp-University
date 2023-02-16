// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./test.sol";
import "hardhat/console.sol";

contract AirDrop {
    bytes32 public immutable root;
    uint256 public immutable rewardAmount;
    uint256 private _totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);

    mapping(address => bool) claimed;
    mapping(address => uint256) private _balances;

    constructor(bytes32 _root, uint256 _rewardAmount) {
        root = _root;
        rewardAmount = _rewardAmount;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function claim(bytes32[] calldata _proof) external {
        require(!claimed[msg.sender], "Already claimed air drop");
        claimed[msg.sender] = true;
        bytes32 _leaf = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verify(_proof, root, _leaf),
            "Incorrect merkle proof"
        );
        _mint(msg.sender, rewardAmount);
    }
}
