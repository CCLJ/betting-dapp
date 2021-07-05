pragma solidity >=0.4.21 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Casino.sol";

contract TestCasino {

  function testItStoresAValue() public {
    Casino casino = Casino(DeployedAddresses.Casino());

    // casino.set(89);

    // uint expected = 89;

    // Assert.equal(casino.get(), expected, "It should store the value 89.");
  }

}
