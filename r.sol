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

    mapping (address => uint) depositsETH;
    mapping (address => uint) depositsHAK;
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
            require(msg.value >= amount);
            owner.transfer(amount);
            //Deposit dep = Deposit(amount, block.number);
            depositsETH[token] += amount;
        } else if (tokenID == 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C) { //deposit HAK
            require(msg.value >= amount);
            tokenID.transferFrom(msg.sender, owner, amount);
            //Deposit dep = Deposit(amount, block.number);
            depositsHAK[token] += amount;
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
        }revert();
    }


    function liquidate(address token, address account) onlyOwner payable external override returns (bool) {
        require(getCollateralRatio(token, account) <15000);
        IERC20 tokenID = token;
        if (tokenID == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) { //deposit ETH
            return depositETH[msg.sender] * 1.03;
        } else if (tokenID == 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C) { //deposit HAK
            return depositHAK[msg.sender] * 1.03;
        }
        uint256 amountOnDeposit = 
        uint256 amountBorrowed = borrowed[account]+owedInterest[account];
        deposits[account]=0;
        accruedInterest[account]= 0;
        borrowed[account]=0;
        owedInterest[account]=0;
        depositsETH[this] -= amountBorrowed;
        depositsHAK[this] +=amountOnDeposit;
        return true;
    }




    function getCollateralRatio(address token, address account) onlyOwner view external override returns (uint256) {
        IERC20 tokenID = token;
        PriceOracle po = PriceOracle();
        if (tokenId = 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C){
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
