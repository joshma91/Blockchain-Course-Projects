pragma solidity ^0.4.15;

/**
 * Project work: Bidding contract
 * Implements the shell for the contract exercise described in the last section
 * Part of an online course.
 * http://acloudfan.com/learn-blockchain
 *
 * PLEASE NOTE : THIS IS A SHELL AND WILL REQUIRE YOU TO CODE THE FUNCTIONS
 *               OTHERWISE YOU WILL GET COMPILATION ERRORS
 **/

contract BiddingContract {

  string    name;
  string    description;
  uint      duration;
  uint      startBid;

  uint      createdAt;
  address   owner;
  bool      ended;

  struct Bidder {
    address   bidder;
    string    name;
    uint      bidAmount;
    // Ethers pull pattern used
    bool      claimedEthers;
  }

  // Declare the events
  event HighBidChanged(address addr, string nm, uint  newHighBid);
  event BidFailed(address addr, string nm, uint bidAmt);

  // Maintain all bidders in an array
  mapping(address=>Bidder) losersMapping;

  // This maintains the high bidder
  Bidder    highBidder;

  // duration in minutes
  // start price in ethers
  function BiddingContract(string nm, string desc, uint dur, uint sBid) {
    // constructor
    name=nm;
    description=desc;
    duration=dur;
    startBid=sBid;
    // Initalize createdAt to current time
    createdAt = now;
    owner = msg.sender;
    ended = false;

    //set highBidder as the address who initialized contract instance
    highBidder.bidder = owner;
    highBidder.name = nm;
    highBidder.bidAmount = sBid;
    highBidder.claimedEthers = true; //doesn't get ethers back
  }

  // Bid function is what gets called by any bidder
  function  placeBid(string bidderName) payable {

    uint bid = msg.value;
    // check if the duration has not expired
    // if it has then throw an exception
    if(didBidEnd()) revert();

    // currentBid = highBidder.bidAmount
    uint currentBid = highBidder.bidAmount;
    //When the bid is too small emit a BidFailed event
    if(bid <= currentBid) {
      BidFailed(msg.sender, name, bid);
      revert();
    } else {
      //since the current bid is greater, we put the old highBidder into the losers array
      if(highBidder.bidAmount != 0){
        /*losersMapping[highBidder.bidder].bidder = highBidder.bidder;
        losersMapping[highBidder.bidder].name = highBidder.name;
        losersMapping[highBidder.bidder].bidAmount = highBidder.bid;
        losersMapping[highBidder.bidder].claimedEthers = highBidder.claimedEthers;*/

        losersMapping[highBidder.bidder] = highBidder;
      }

      //assign current bidder to high bidder;
      highBidder.bidder = msg.sender;
      highBidder.name = bidderName;
      highBidder.bidAmount = bid;
      highBidder.claimedEthers = false;

      // emit High bid event
      HighBidChanged(highBidder.bidder, highBidder.name, highBidder.bidAmount);
    }
  }

  function getHighBid() constant returns(uint){
    // Return the bid amount held in high bidder
    return highBidder.bidAmount;
  }

  // This is invoked by anyone to chek if there is are ehters
  // in the contract that they can claim
  // Losers will be added to the bidders array ... the claim flag in struct
  // maintains the status of whether the caller has already been given the ethers or not
  function  getClaimAmount() returns(uint){

    // check if msg.sender in the bidders`
    // check if claims flag is FALSE
    // return the bid amount
    if(losersMapping[msg.sender].bidAmount == 0 ||
      losersMapping[msg.sender].claimedEthers == true) {
        return 0;
      } else {
        return losersMapping[msg.sender].bidAmount;
      }

  }

  // Losers will call this to get their bid ethers back
  function claimEthers() {
    // Check if caller is eligible for clain - getClaimAmout
    // If they are then send ethers to them
    // set the claimedEthers flag to true
    uint sendAmt = getClaimAmount();
    if(sendAmt > 0){
      assert(msg.sender.send(sendAmt));
      losersMapping[msg.sender].claimedEthers = true;
      return;
    }
    //if address not found, bidamt is 0, or already claimed
    revert();
  }

  function minutesLeft() returns (uint){
    return (now - createdAt + duration);
    //return (now*1 hours - (createdAt + duration)*1 hours);
  }
  // Can a bid end if there are unclaimed ethers
  // In later version the claims data will be moved to a separate contract
  // Claims will be made losers against the separate contract
  function  didBidEnd() returns (bool) {
    // bidders.length == 0 for bid to end
    // check if the bidding is active i.e., not expired
    if(ended == true ||
      ((createdAt*1 minutes + duration) < now*1 minutes)) return true;
  }

  modifier OwnerOnly(){
    if(msg.sender == owner) _;
    else revert();
  }

  // This ends the bidding
  // Only owner can call this function - apply modifier
  // All ethers returned to the owner as part of self destruct
  function endBidding() OwnerOnly {
      ended = true;
  }

}
