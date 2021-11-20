pragma solidity 0.7.0;

import './bank.sol';
import './IPriceOracle.sol';
import "@openzeppelin/contracts/math/SafeMath.sol";


contract Account {

}
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
        require(getCollateralRatio(token, account) > 1500);
        IERC20 tokenID = token;
        require(msg.sender.getBalance >= amount);
        uint256 amountRepayable;
        
        if (tokenID == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) { //deposit ETH
            if(amount>borrowedETH[msg.sender].deposit){
                amountRepayable = borrowedETH[msg.sender].deposit;
            } else {
                amountRepayable = amount;
            }
            owner.transfer(amountRepayable);
            borrowedETH[msg.sender].deposit -=  1.00 * amountRepayable * (0.95);
            return borrowedETH[msg.sender].deposit;
        } else if (tokenID == 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C) { //deposit HA
            if(amount>borrowedHAK[msg.sender].deposit){
                amountRepayable = borrowedHAK[msg.sender].deposit;
            } else {
                amountRepayable = amount;
            }
            tokenID.transferFrom(amountRepayable);
            borrowedHAK[msg.sender].deposit -=  1.00 * amountRepayable * (0.95);
            return borrowedHAK[msg.sender].deposit;
        }revert();
    }


    function liquidate(address token, address account) onlyOwner payable external override returns (bool) {
        require(getCollateralRatio(token, account) <15000);
        IERC20 tokenID = token;
        if (tokenID == 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C) { //deposit HAK
            depositHAK[msg.sender].deposit += (depositHAK[account].deposit - borrowedHAK[account] + currentInterest(account, "HAK", depositHAK[account].deposit));
            depositHAK[account].deposit = 0;
            depositHAK[account].interest =0;
            borrowedHAK[account] = 0;
            return true;
        }return false;
    }




    function getCollateralRatio(address token, address account) onlyOwner view external override returns (uint256) {
        IPriceOracle po = new PriceOracle();
        if (token = 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C){
            return po.call.getVirtualPrice(token)*depositsHAK[account]*10000/ borrowedETH[account];
        } else revert();
    }

    function getBalance(address token) onlyOwner view external override returns (uint256) {
        if (token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) { //deposit ETH
            return depositETH[msg.sender] * 1.03;
        } else if (token == 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C) { //deposit HAK
            return depositHAK[msg.sender] * 1.03;
        }
    }
}
