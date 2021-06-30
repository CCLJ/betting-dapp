// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.7.0;

contract Casino {
    address public owner;
    uint256 public minimumBet;
    uint256 public totalBet;
    uint256 public numberOfBets;
    uint256 public maxAmountOfBets = 100;
    address[] public players;

    struct Player {
        uint256 amountBet;
        uint256 numberSelected;
    }

    mapping(address => Player) public playerInfo;

    constructor(uint256 _minBet) public {
        owner = msg.sender;
        if(_minBet != 0) minimumBet = _minBet;
    }

    // payable is a modifier.
    // It means this function can receive ether when executed
    // sets value to msg.value (amount of wei)
    function bet(uint256 _numberSelected) public payable {
        require(!checkPlayerExists(msg.sender));
        require(_numberSelected >= 1 && _numberSelected <= 10);
        require(msg.value >= minmumBet);

        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].numberSelected = _numberSelected;
        numberOfBets++;
        players.push(msg.sender);
        totalBet += msg.value;

        if(numberOfBets >= maxAmountOfBets) generateWinnerNumber();
    }

    // constant indicates this function does not call gas
    // since it is reading values that are already in the blockchain
    // players (is a state variable)
    function checkPlayerExists(address _player) public constant returns(bool) {
        for(uint256 i = 0; i < players.length; i++) {
            if(players[i] == _player) return true;
        }

        return false;
    }

    function generateWinnerNumber() public {
        // this isn't secure since block number will not change
        // for the current block, so miners can see it
        // QuestionToSelf: when is this block generated
        uint256 winnerNumber = block.number % 10 + 1;
        distributePrizes(winnerNumber);
    }

    function distributePrizes(uint256 _winnerNumber) {
        // why is it necesary to create fixed size array
        address[100] memory winners;
        // count for the array of winners
        uint256 count = 0;

        for(uint256 i = 0; i < players.length; i++) {
            address playerAddress = players[i];
            if(playerInfo[playerAddress].numberSelected == _winnerNumber) {
                winners[count] = playerAddress;
                count++;
            }
            // this will delete all the players betting data
            delete playerAddress[playerAddress];
        }
        resetData();

        // How much each winner gets
        uint256 winnerEtherAmount = totalBet / winners.length;

        for(uint256 j = 0; j < count; j++) {
            // Check that the address in this fixed array is not empty
            // QuestionToSelf: how to allow dynamic number of players?
            // and what does address(0) mean exactly
            if(winners[count] != address(0)) {
                winners[j].transfer(winnerEtherAmount);
            }
        }
    }

    function resetData() public {
        players.length = 0; // delete players array
        totalBet = 0;
        numberOfBets = 0;
    }

    // Fallback function in case someone sends ether to the contract,
    // so it doesn't get lost and to increase the treasury of thi
    //  contract that will be distributed in each game
    function() public payable {}

    // used to destroy contract.
    // last resort when contract has been compromised
    // and can't be secured
    function kill() public {
        if(msg.sender == owner) {
            selfdestruct(owner);
        }
    }
}
