pragma solidity 0.6.6;

import "./JUSD.sol";
import "./Mimic.sol";
import "./cJUSD.sol";
import "./Farming.sol";
import "./Swap.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

contract Auto is Ownable{
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    string public name = "Auto-Compound Contract";

    ERC20 internal MimicToken;
    ERC20 internal JUSDToken;
    ERC20 internal cJUSDToken;
    Farming internal FarmContract;
    Swap internal SwapContract;

    /* Other Contract Address */
    address internal FarmAddress;
    address internal SwapAddress;
    address internal JUSDAddress;
    mapping (address => uint256) cjusdbuyprice;

   uint256 stakingBalance;
    constructor(
        address _JUSDToken,
        address _MimicToken,
        address _Farming,
        address _cJUSDToken,
        address _Swap
    ) public {
        /* Initial Token with token address */
        MimicToken = ERC20Burnable(_MimicToken);
        JUSDToken = ERC20(_JUSDToken);
        cJUSDToken = ERC20Burnable(_cJUSDToken);

        /* Initial Farm and Swap Contract with token address */
        SwapContract = Swap(_Swap);
        FarmContract = Farming(_Farming);

        /* Initial Farm and Swap Contract address */
        FarmAddress = _Farming;
        SwapAddress = _Swap;
        JUSDAddress = _JUSDToken;
    }

    function deposit(uint256 _amount, address _token) public {
        require(FarmContract.checkWhitelisted(_token) && _amount > 0);
        uint256 decimals = ERC20(_token).decimals();
        uint256 balance = _amount;
        /* Transfer any token that in whitelist from user to Auto-Compound Contract */
        ERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        if(_token!= JUSDAddress){
        /*Swap any token to jusd*/
         SwapContract.swapToJUSD(_amount , decimals);
         /*Transfer to Swap Contract*/
         ERC20(_token).safeTransfer(SwapAddress, _amount);
        }
        if(decimals != 18){
             uint256 remain = 18 - decimals;
             balance = _amount.mul(10 ** remain);
         }
          /* Auto-Compound:: Approve JUSD for spend amount to Farm */
         JUSDToken.approve(FarmAddress, balance);
        /* Stake JUSD in Farm Contract with Auto-Compound */
         FarmContract.stakeTokens(balance, JUSDAddress);
         stakingBalance = stakingBalance.add(balance);
         uint256 cjp = SwapContract.cJUSDPrice();
         uint256 cjrate = balance.div(cjp);
         cjusdbuyprice[msg.sender] = cjp;
          cJUSDToken.safeTransfer(msg.sender, cjrate);
    }

    function claimAndSwap(address _token) public onlyOwner {
        /* Claim Mimic Token */
        FarmContract.claimRewards(_token);
        /* Check Mimic Token balance */
        uint256 mimbal = MimicToken.balanceOf(address(this));
        /* Swap Mimic To JUSD */
        MimicToken.approve(SwapAddress, mimbal);
        SwapContract.mimToJUSD(mimbal);
    }

    function depositToFarm(uint256 _amount) public onlyOwner {
        /* Auto-Compound:: Approve JUSD for spend amount to Farm */
        JUSDToken.approve(FarmAddress, _amount);
        /* Stake JUSD in Farm Contract with Auto-Compound */
        FarmContract.stakeTokens(_amount, JUSDAddress);
    }

    function withdraw(uint256 _amount) public {
        uint256 cjp = SwapContract.cJUSDPrice();
        uint256 balance = _amount.div(cjp);
        /* Transfer cJUSD to Auto Compound */
        cJUSDToken.safeTransferFrom(msg.sender, address(this), _amount);
        /* Unstake JUSD from Farming Contract */
        FarmContract.unstakeTokens(balance, JUSDAddress);
        /* Return JUSD to user */
        JUSDToken.safeTransfer(msg.sender, balance);
        uint256 remain = stakingBalance.sub(balance);
        stakingBalance = remain;
    }

    function getStakingBalance()public view returns (uint256){
        return stakingBalance;
    }
    function getcJUSDBalance() public view returns (uint256) {
        return cJUSDToken.balanceOf(address(this));
    }

    function getJUSDBalance() public view returns (uint256) {
        return JUSDToken.balanceOf(address(this));
    }
    function cJUSDBuyPrice(address _account)public view returns (uint256){
        return cjusdbuyprice[_account];
    }
}
