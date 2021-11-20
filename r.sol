pragma solidity 0.7.0;

import './bank.sol';
import './IPriceOracle.sol';
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Bank is IBank {

    /*struct Deposit {
        uint amount;
        uint blockNumber;
    }*/

    struct Account { // Note that token values have an 18 decimal precision
        uint256 deposit;           // accumulated deposits made into the account
        uint256 interest;          // accumulated interest
        uint256 lastInterestBlock; // block at which interest was last computed
    }

    mapping (address => Account) depositsETH;
    mapping (address => Account) depositsHAK;
    mapping (address => uint) borrowedETH;
    mapping (address => uint) borrowedHAK;
    
    address payable public owner;

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
    } 

    function deposit(address token, uint256 amount) onlyOwner payable external override returns (bool) {
        IERC20 tokenID = token;
        if (tokenID == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) { //deposit ETH
            require(msg.sender.value >= amount);
            owner.transfer(amount);
            if (depositsETH[token])
            //Deposit dep = Deposit(amount, block.number);
            depositsETH[token] += amount;
        } else if (tokenID == 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C) { //deposit HAK
            require(msg.sender.value >= amount);
            tokenID.transferFrom(msg.sender, owner, amount);
            //Deposit dep = Deposit(amount, block.number);
            depositsHAK[token] += amount;
        }
    }

    function currentInterest(address account, string cType, uint amount) private returns (uint) {
        uint interest;
        if (cType == "ETH") {

            interest = depositsETH[account].deposit * (block.number - depositsETH[account].lastInterestBlock) * 0.03;
            depositsETH[account].interest += interest;
            depositsETH[account].lastInterestBlock = block.number;
            return interest;
        }
        if (cType == "HAK") {
            interest = depositsHAK[account].deposit * (block.number - depositsHAK[account].lastInterestBlock) * 0.03;
            depositsHAK[account].interest += interest;
            depositsHAK[account].lastInterestBlock = block.number;
            return interest;
        }
    }

    function withdraw(address token, uint256 amount) onlyOwner external override returns (uint256) {
        IERC20 tokenID = token;
        if (tokenID == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) { //withdraw ETH
            require(depositsETH[msg.sender] >= amount);
            uint interest;
            if (amount == 0) {
                interest = depositsETH[msg.sender] * 1.03 * block.number;
                depositsETH[msg.sender] = 0;
                return interest;
            }
            interest = amount * block.number * 0.03;
            depositsETH[msg.sender] -= amount;
            depositsETH[msg.sender] += interest;
            msg.sender.transfer(amount);
            return interest + amount;
        } else if (tokenID == 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C) { //withdraw HAK
            require(deposits[msg.sender] >= amount);
            uint interest;
            if (amount == 0) {
                interest = depositsHAK[msg.sender] * 1.03 * block.number;
                depositsHAK[msg.sender] = 0;
                return interest;
            }
            interest = amount * block.number * 0.03;
            depositsHAK[msg.sender] -= amount;
            depositsHAK[msg.sender] += interest;
            tokenID.transferFrom(msg.sender, owner, amount);
        }
    }

    function borrow(address token, uint256 amount) onlyOwner external override returns (uint256) {
        
    }

    function repay(address token, uint256 amount) onlyOwner payable external override returns (uint256) {
        require(getCollateralRatio(token, ));
        IERC20 tokenID = token;
        require(msg.sender.getBalance >= amount);
        uint256 amountRepayable;
        
        if (tokenID == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) { //deposit ETH
            if(amount>borrowedETH[msg.sender]){
                amountRepayable = borrowedETH[msg.sender];
            } else {
                amountRepayable = amount;
            }
            owner.transfer(amountRepayable);
            borrowedETH[msg.sender] -=  1.00 * amountRepayable * (0.95);
            return borrowedETH[msg.sender];
        } else if (tokenID == 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C) { //deposit HA
            if(amount>borrowedHAK[msg.sender]){
                amountRepayable = borrowedHAK[msg.sender];
            } else {
                amountRepayable = amount;
            }
            tokenID.transferFrom(amountRepayable);
            borrowedHAK[msg.sender] -=  1.00 * amountRepayable * (0.95);
            return borrowedHAK[msg.sender];
        }
        return -1;
    }


    function liquidate(address token, address account) onlyOwner payable external override returns (bool) {
        IERC20 tokenID = token;
        if (getCollateralRatio(tokenID,account)<15000) {
            
            uint amountOnDeposit = deposits[account] +accruedInterest[account];
            uint amountBorrowed = borrowed[account]+owedInterest[account];
            deposits[account]=0;
            accruedInterest[account]= 0;
            borrowed[account]=0;
            owedInterest[account]=0;
            depositsETH[this] -= amountBorrowed;
            depositsHAK[this] +=amountOnDeposit;
            return true;
        } else revert();
    }




    function getCollateralRatio(address token, address account) onlyOwner view external override returns (uint256) {
        IERC20 tokenID = token;
        PriceOracle po = PriceOracle();
        if (tokenId = 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C)
        {
            return po.call.getVirtualPrice(tokenID)*depositsHAK[account]*10000/ borrowedETH[account];
        } else revert();
    }

    function getBalance(address token) onlyOwner view external override returns (uint256) {
        IERC20 tokenID = token;
        if (tokenID == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) { //deposit ETH
            return depositETH[msg.sender] * 1.03;
        } else if (tokenID == 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C) { //deposit HAK
            return depositHAK[msg.sender] * 1.03;
        }
    }
}
