// SPDX-License-Identifier: MIT
// cast address to address payable:
// https://ethereum.stackexchange.com/questions/65693/how-to-cast-address-to-address-payable-in-solidity-0-5-0

pragma solidity ^0.5.0;

contract Casino {
    address public owner;
    uint256 public minimumBet = 100 szabo; // 0.0001 ether
    uint256 public totalBet;
    uint256 public numberOfBets;
    uint256 public maxAmountOfBets = 10;
    uint256 public constant LIMIT_MAX_AMOUNT_BETS = 100;
    address[] public players;

    struct Player {
        uint256 amountBet;
        uint256 numberSelected;
    }

    mapping(address => Player) public playerInfo;

    event BetAdded(uint256 amount, uint256 numberSelected, address player);
    event CasinoReset();
    event PrizesDistributed(uint256 prizePerWinner, uint256 totalWinners);

    constructor(uint256 _minBet, uint256 _maxBets) public {
        owner = msg.sender;
        if(_minBet != 0)
            minimumBet = _minBet;
        if(_maxBets > 0 && _maxBets <= LIMIT_MAX_AMOUNT_BETS)
            maxAmountOfBets = _maxBets;
    }

    // payable is a modifier.
    // It means this function can receive ether when executed
    // sets value to msg.value (amount of wei)
    function bet(uint256 _numberSelected) public payable {
        require(!checkPlayerExists(msg.sender), "Player already placed bet");
        require(_numberSelected >= 1 && _numberSelected <= 10, "Number must be between 1 and 10");
        require(msg.value >= minimumBet, "Value not greater than minimum bet");

        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].numberSelected = _numberSelected;
        numberOfBets++;
        players.push(msg.sender);
        totalBet += msg.value;
        emit BetAdded(msg.value, _numberSelected, msg.sender);

        if(numberOfBets >= maxAmountOfBets) generateWinnerNumber();
    }

    // constant indicates this function does not call gas
    // since it is reading values that are already in the blockchain
    // players (is a state variable)
    function checkPlayerExists(address _player) public view returns(bool) {
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

    function distributePrizes(uint256 _winnerNumber) public {
        // why is it necesary to create fixed size array
        address payable[100] memory winners;
        // count for the array of winners
        uint256 count = 0;

        for(uint256 i = 0; i < players.length; i++) {
            address playerAddress = players[i];
            if(playerInfo[playerAddress].numberSelected == _winnerNumber) {
                winners[count] = address(uint160(playerAddress));
                count++;
            }
            // this will delete all the players betting data
            delete playerInfo[playerAddress];
        }

        // How much each winner gets
        uint256 winnerEtherAmount = totalBet / winners.length;
        resetData();

        for(uint256 j = 0; j < count; j++) {
            // Check that the address in this fixed array is not empty
            // QuestionToSelf: how to allow dynamic number of players?
            // and what does address(0) mean exactly
            if(winners[count] != address(0)) {
                winners[j].transfer(winnerEtherAmount);
            }
        }
        emit PrizesDistributed(winnerEtherAmount, winners.length);
    }

    function resetData() public { // TODO: emit event
        players.length = 0; // delete players array
        totalBet = 0;
        numberOfBets = 0;
        emit CasinoReset();
    }

    // Fallback function in case someone sends ether to the contract,
    // so it doesn't get lost and to increase the treasury of thi
    //  contract that will be distributed in each game
    function() external payable {}

    // used to destroy contract.
    // last resort when contract has been compromised
    // and can't be secured
    function kill() public {
        if(msg.sender == owner) {
            selfdestruct(address(uint160(owner)));
        }
    }
}
