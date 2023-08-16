```solidity
contract AstraOmniRiseIDO is Context, ReentrancyGuard, Ownable {

    // The USDC token contract used to accept payment during the IDO
    ERC20 public usdTokenContract;

    // The AOR token contract to be sold during the IDO
    ERC20 public aorTokenContract;

    // Sale price per AOR 
    uint256 public salePrice;

    // IDO sale start time
    uint256 public saleStartTime;

    // IDO sale end time
    uint256 public saleEndTime;

    // Minimum deposit amount per address during IDO
    uint256 public minDeposit;

    // Maximum deposit amount per address during IDO
    uint256 public maxDeposit;

    // USDC deposit amount for each address
    mapping(address => uint256) public depositOf;

    // Total USDC deposit amount  
    uint256 public totalDeposit;

    // USDC refunded for each address
    mapping(address => uint256) public refundOf;

    // Fundraising goal amount for this IDO (in USDC)
    uint256 public goalAmount;

    // Claim interval for AOR after IDO ends 
    uint256 public claimInterval = 30*24*60*60;

    // AOR claim record for each address and term
    mapping(address => mapping(uint256 => uint256)) public claimRecordOf;

    /*
      usdTokenContract_ USDC token contract
      aorTokenContract_ AOR token contract  
      saleStartTime_ IDO sale start time (in seconds)
      saleEndTime_ IDO sale end time (in seconds)  
      minDeposit_ Minimum deposit amount per address (without decimal places)
      maxDeposit_ Maximum deposit amount per address (without decimal places)
      goalAmount_ Fundraising goal for this IDO (without decimal places)
    */

    constructor(
        ERC20 usdTokenContract_,
        ERC20 aorTokenContract_,
        uint256 saleStartTime_,
        uint256 saleEndTime_,
        uint256 minDeposit_,
        uint256 maxDeposit_,
        uint256 goalAmount_
    ) {
        // Initialization
    }

    // User deposits USDC to participate in IDO
    // quantity is deposit amount (real number x decimals) 
    function deposit(uint256 quantity) external nonReentrant;

    /*
      Withdraw token from IDO contract 
        token - ERC20 token contract address
        to - recipient address
        quantity - amount to withdraw
    */
    function withdraw(ERC20 token, address to, uint256 quantity) external nonReentrant onlyOwner;

    // User can refund after IDO ends
    function refund() external nonReentrant;

    // Get start time for claiming AOR in certain term
    function getClaimStartTime(uint8 term) view public returns (uint256) {
        return saleEndTime + claimInterval * (term - 1);
    }

    // Get refund amount for an address
    function getRefundAmount(address addr) view public returns (uint256) {
        // ...
    }

    // Get claimable AOR amount for an address in each term
    function getClaimAmount(address addr) view public returns (uint256) {
        // ...
    }

    // User claims AOR for a term after IDO ends
    function claim(uint8 term) external nonReentrant;

}

```
When deploying:

 1. Transfer the AOR tokens to be sold to the IDO contract
 2. Withdraw the USDC from the contract after sale ends