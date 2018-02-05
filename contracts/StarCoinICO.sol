pragma solidity ^0.4.11;

import "./Haltable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./StarCoin.sol";
import "./InvestorWhiteList.sol";

contract StarCoinICO is Haltable {
  using SafeMath for uint;

  string public constant name = "StarCoin ICO";

  StarCoin public token;

  address public beneficiary;

  // remember to set this once the pre-ICO address is known
  address public constant preSaleAddress = 0x45a69909e13c4c3797e7d8a691d21c59bd818731;


  InvestorWhiteList public investorWhiteList;

  uint public hardCap;

  uint public softCap;

  uint public collected = 0;

  uint public tokensSold = 0;

  uint public weiRefunded = 0;

  uint public startBlock;

  uint public endBlock;

  bool public softCapReached = false;

  bool public crowdsaleFinished = false;

  mapping (address => uint) public deposited;

  // This is where the thresholds for referral bonuses are defined

  uint constant VOLUME_20_REF_7 = 5000 ether;

  uint constant VOLUME_15_REF_6 = 2000 ether;

  uint constant VOLUME_12d5_REF_5d5 = 1000 ether;

  uint constant VOLUME_10_REF_5 = 500 ether;

  uint constant VOLUME_7_REF_4 = 250 ether;

  uint constant VOLUME_5_REF_3 = 100 ether;

  event SoftCapReached(uint softCap);

  event NewContribution(address indexed holder, uint tokenAmount, uint etherAmount);

  event NewReferralTransfer(address indexed investor, address indexed referral, uint tokenAmount);

  event Refunded(address indexed holder, uint amount);

  modifier icoActive() {
    require(block.number >= startBlock && block.number < endBlock);
    _;
  }

  modifier icoEnded() {
    require(block.number >= endBlock);
    _;
  }

  modifier minInvestment() {
    require(msg.value >= 0.5 * 1 ether);
    _;
  }

  modifier inWhiteList() {
    require(investorWhiteList.isAllowed(msg.sender));
    _;
  }

  function StarCoinICO(
    uint _hardCapSTAR,
    uint _softCapSTAR,
    address _token,
    address _beneficiary,
    address _investorWhiteList,
    uint _startBlock,
    uint _endBlock
  ) {
    hardCap = _hardCapSTAR.mul(1 ether);
    softCap = _softCapSTAR.mul(1 ether);

    token = StarCoin(_token);
    beneficiary = _beneficiary;
    investorWhiteList = InvestorWhiteList(_investorWhiteList);

    startBlock = _startBlock;
    endBlock = _endBlock;

  }

  function() payable minInvestment inWhiteList {
    doPurchase();
  }

  function refund() external icoEnded {
    require(softCapReached == false);
    require(deposited[msg.sender] > 0);

    uint refund = deposited[msg.sender];

    deposited[msg.sender] = 0;
    msg.sender.transfer(refund);

    weiRefunded = weiRefunded.add(refund);
    Refunded(msg.sender, refund);
  }

  function withdraw() external onlyOwner {
    require(softCapReached);
    beneficiary.transfer(collected);
    token.transfer(beneficiary, token.balanceOf(this));
    crowdsaleFinished = true;
  }

  function calculateBonus(uint tokens) internal constant returns (uint bonus) {
    // 20 %
    if (msg.value >= VOLUME_20_REF_7) {
      return tokens.mul(20).div(100);
    }
    // 15 %
    if (msg.value >= VOLUME_15_REF_6) {
      return tokens.mul(15).div(100);
    }
    // 12.5 %
    if (msg.value >= VOLUME_12d5_REF_5d5) {
      return tokens.mul(125).div(1000);
    }
    // 10 %
    if (msg.value >= VOLUME_10_REF_5) {
      return tokens.mul(10).div(100);
    }
    // 7 %
    if (msg.value >= VOLUME_7_REF_4) {
      return tokens.mul(7).div(100);
    }
    // 5 %
    if (msg.value >= VOLUME_5_REF_3) {
      return tokens.mul(5).div(100);
    }

    return 0;
  }

  function calculateReferralBonus(uint tokens) internal constant returns (uint bonus) {
    if (msg.value >= VOLUME_20_REF_7) {
      return tokens.mul(7).div(100);
    }

    if (msg.value >= VOLUME_15_REF_6) {
      return tokens.mul(6).div(100);
    }

    if (msg.value >= VOLUME_12d5_REF_5d5) {
      return tokens.mul(55).div(1000);
    }

    if (msg.value >= VOLUME_10_REF_5) {
      return tokens.mul(5).div(100);
    }

    if (msg.value >= VOLUME_7_REF_4) {
      return tokens.mul(4).div(100);
    }

    if (msg.value >= VOLUME_5_REF_3) {
      return tokens.mul(3).div(100);
    }

    return 0;
  }

  function setNewWhiteList(address newWhiteList) external onlyOwner {
    require(newWhiteList != 0x0);
    investorWhiteList = InvestorWhiteList(newWhiteList);
  }

  function doPurchase() private icoActive inNormalState {
    require(!crowdsaleFinished);

    uint tokens = msg.value;
    uint referralBonus = calculateReferralBonus(tokens); // It is based on the number of STAR not ETH!! => Some of the tests are incorrect
    address referral = investorWhiteList.getReferralOf(msg.sender);

    tokens = tokens.add(calculateBonus(tokens));

    uint newTokensSold = tokensSold.add(tokens);

    if (referralBonus > 0 && referral != 0x0) {
      newTokensSold = newTokensSold.add(referralBonus);
    }

    require(newTokensSold <= hardCap);

    if (!softCapReached && newTokensSold >= softCap) {
      softCapReached = true;
      SoftCapReached(softCap);
    }

    collected = collected.add(msg.value);

    tokensSold = newTokensSold;

    deposited[msg.sender] = deposited[msg.sender].add(msg.value);

    token.transfer(msg.sender, tokens);
    NewContribution(msg.sender, tokens, msg.value);

    if (referralBonus > 0 && referral != 0x0) {
      token.transfer(referral, referralBonus);
      NewReferralTransfer(msg.sender, referral, referralBonus);
    }
  }

  function transferOwnership(address newOwner) onlyOwner icoEnded {
    super.transferOwnership(newOwner);
  }
}
