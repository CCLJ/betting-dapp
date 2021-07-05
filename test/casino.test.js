const { assert } = require('chai');

const Casino = artifacts.require('./Casino.sol');

require('chai')
  .use(require('chai-as-promised'))
  .should()

function etherToWei(ether) {
  return web3.utils.toWei(ether, 'Ether')
}

contract('Casino', accounts => {
  let casino;

  before(async () => {
    casino = await Casino.new(etherToWei('0.001'), 100);
  })

  describe('Casino deployment', async () => {
    it('has a minimumBet', async () => {
      const minBet = await casino.minimumBet();
      assert.equal(minBet.toString(), '1000000000000000');
    })

    it('has a maxAmountOfBets', async () => {
      const maxBets = await casino.maxAmountOfBets();
      assert.equal(maxBets, 100);
    })
  })

  describe('betting', async () => {
    it('adds the bet to the bet pot', async () => {
      let result;
      let bettingAccount = accounts[1];

      result = await web3.eth.getBalance(bettingAccount);
      assert.equal(result.toString(), etherToWei('100'));

      const betTransaction = await casino.bet(2, { from: bettingAccount, value: etherToWei('0.01') });

      result = await web3.eth.getBalance(bettingAccount);
      // this takes gas to, so value will not be 99.99. Don't know how to predict gas cost
      assert.notEqual(result.toString(), etherToWei('100'));

      result = await casino.totalBet();
      assert.equal(result.toString(), etherToWei('0.01'));

      result = await casino.numberOfBets();
      assert.equal(result.toString(), '1');
      
      result = await casino.players(0);
      assert.equal(result, bettingAccount);

      result = await casino.playerInfo(bettingAccount);
      assert.equal(result.amountBet.toString(), etherToWei('0.01'));
      assert.equal(result.numberSelected.toString(), '2');

      const transactionEvents = betTransaction.logs;
      assert.equal(transactionEvents.length, 1);
      assert.equal(transactionEvents[0].event, 'BetAdded');
      assert.equal(transactionEvents[0].args['0'].toString(), etherToWei('0.01'));
      assert.equal(transactionEvents[0].args['1'].toString(), '2');
      assert.equal(transactionEvents[0].args['2'].toString(), bettingAccount);
    })
  })
});
