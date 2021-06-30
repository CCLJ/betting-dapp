import React, { Component } from "react";

class Main extends Component {
  constructor(props) {
    super(props);
    this.state = {
      lastWinner: 0,
      numberOfBets: 0,
      minimumBet: 0,
      totalBet: 0,
      maxAmountOfBets: 0,
      timer: 0,
      selectedNumber: 0,
      betAmount: 0.1,
    };
    this.getContractVariablesForState = this.getContractVariablesForState.bind(this);
    this.voteNumber = this.voteNumber.bind(this);
    this.handleBetSubmit = this.handleBetSubmit.bind(this);
    this.handleBetChange = this.handleBetChange.bind(this);
    this.selectedNumberLiClass = this.selectedNumberLiClass.bind(this);
  }

  getContractVariablesForState() {
    this.props.contract.methods.minimumBet((err, result) => {
      if(result != null){
         this.setState({
            minimumBet: parseFloat(this.props.web3.fromWei(result, 'ether'))
         })
      }
    })
    this.props.contract.methods.totalBet((err, result) => {
        if(result != null){
          this.setState({
              totalBet: parseFloat(this.props.web3.fromWei(result, 'ether'))
          })
        }
    })
    this.props.contract.methods.numberOfBets((err, result) => {
        if(result != null){
          this.setState({
              numberOfBets: parseInt(result)
          })
        }
    })
    this.props.contract.methods.maxAmountOfBets((err, result) => {
        if(result != null){
          this.setState({
              maxAmountOfBets: parseInt(result)
          })
        }
    })
  }

  voteNumber(number) {
    console.log(number)
    this.setState({ selectedNumber: number });
  }

  selectedNumberLiClass(number) {
    if(this.state.selectedNumber === number) return "number-selected"

    return "";
  }

  handleBetChange(event) {
    console.log(event.target.value)
    this.setState({ betAmount: event.target.value })
  }

  handleBetSubmit(event) {
    event.preventDefault();

    console.log(this.state.betAmount, this.state.selectedNumber, this.props)
    if(!this.state.betAmount) {
      alert("Bet amount must be a decimal number greater than " + this.state.minimumBet)
      return false;
    }

    if(this.state.selectedNumber === 0) {
      alert("Select a number to bet on")
      return false;
    }

    console.log("everything valid")
    this.props.contract.methods.bet(this.state.selectedNumber, {
      gas: 300000,
      from: this.props.accounts[0],
      value: this.props.web3.utils.toWei(this.state.betAmount.toString(), 'ether')
    }, (err, result) => {
      // Result is the transaction address of that function
      console.log(err, result, "Error when betting")
    })
  }

  render() {
    return (
        <div className="main-container">
          <h1>Bet for your best number and win huge amounts of Ether</h1>
          <div className="block">
            <b>Number of bets:</b> &nbsp;
            <span>{this.state.numberOfBets}</span>
          </div>
          <div className="block">
            <b>Last number winner:</b> &nbsp;
            <span>{this.state.lastWinner}</span>
          </div>
          <div className="block">
            <b>Total ether bet:</b> &nbsp;
            <span>{this.state.totalBet} ether</span>
          </div>
          <div className="block">
            <b>Minimum bet:</b> &nbsp;
            <span>{this.state.minimumBet} ether</span>
          </div>
          <div className="block">
            <b>Max amount of bets:</b> &nbsp;
            <span>{this.state.maxAmountOfBets} ether</span>
          </div>

          <hr/>

          <h2>Vote for the next number and place your bet in ETH</h2>
          <form onSubmit={this.handleBetSubmit}>
            <label htmlFor="ethBet"></label>
            <input id="ethBet"
                   className="bet-input"
                   onChange={this.handleBetChange}
                   type="number"
                   placeholder={this.state.minimumBet}
                   value={this.state.betAmount} />
            <input type="submit" value="Bet!" className="bet-submit" />
          </form>
          <ul>
             <li className={this.selectedNumberLiClass(1)} onClick={() => {this.voteNumber(1)}}>1</li>
             <li className={this.selectedNumberLiClass(2)} onClick={() => {this.voteNumber(2)}}>2</li>
             <li className={this.selectedNumberLiClass(3)} onClick={() => {this.voteNumber(3)}}>3</li>
             <li className={this.selectedNumberLiClass(4)} onClick={() => {this.voteNumber(4)}}>4</li>
             <li className={this.selectedNumberLiClass(5)} onClick={() => {this.voteNumber(5)}}>5</li>
             <li className={this.selectedNumberLiClass(6)} onClick={() => {this.voteNumber(6)}}>6</li>
             <li className={this.selectedNumberLiClass(7)} onClick={() => {this.voteNumber(7)}}>7</li>
             <li className={this.selectedNumberLiClass(8)} onClick={() => {this.voteNumber(8)}}>8</li>
             <li className={this.selectedNumberLiClass(9)} onClick={() => {this.voteNumber(9)}}>9</li>
             <li className={this.selectedNumberLiClass(10)} onClick={() => {this.voteNumber(10)}}>10</li>
          </ul>
       </div>
    )
  }
}

export default Main;
