
var BiddingContract = artifacts.require("./BiddingContract.sol");

contract('BiddingContract', function(accounts) {
  var joshs_address = accounts[0];
  var marys_address = accounts[1];
  var franks_address= accounts[2];

  it("should assert true", function() {
    var bidding_contract;

    return BiddingContract.deployed().then(function(instance){
      bidding_contract = instance;

      return bidding_contract.getHighBid.call();
    }).then(function(result){

      console.log("Initial Bid = ",result.toNumber());
      // Make a new bid from other people
      bidding_contract.placeBid("Mary", {from:marys_address, value: 5});

      return bidding_contract.minutesLeft.call();
    }).then(function(result){

      console.log("Time remaining in bid: ", result.toNumber());
      return bidding_contract.getHighBid.call();
    }).then(function(result){

      console.log("Mary's Bid = ", result.toNumber());
      bidding_contract.placeBid("Frank", {from:franks_address, value: 3});

      return bidding_contract.getHighBid.call();
    }).then(function(result){

      console.log("Mary's Bid = ", result.toNumber());
    //   bidding_contract.placeBid("Josh", {from:joshs_address, value:10});
    //   return bidding_contract.getClaimAmount.call();
    // }).then(function(result){
    //  console.log("Mary is eligible to withdraw: ", result.toNumber());
      //assert.isTrue(result.toNumber() == 5);
    });
  });
});
