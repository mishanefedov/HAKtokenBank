pragma solidity 0.7.0;

import './bank.sol';
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Bank is IBank {

    struct Deposit {
        uint amount;
        uint blockNumber;
    }

    mapping (address => Deposit[]) depositsETH;
    mapping (address => Deposit[]) depositsHAK;
    mapping (address => Deposit[]) borrowedETH;
    mapping (address => Deposit[]) borrowedHAK;
    mapping (unit => type2) name;
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
            Deposit dep = Deposit(amount, block.number);
            depositsETH[token].push(dep);
        } else if (tokenID == 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C) { //deposit HAK
            require(msg.value >= amount);
            tokenID.transferFrom(msg.sender, owner, amount);
            Deposit dep = Deposit(amount, block.number);
            depositsHAK[token].push(dep);
        }
    }

    function withdraw(address token, uint256 amount) onlyOwner external override returns (uint256) {
        IERC20 tokenID = token;
        if (tokenID == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) { //withdraw ETH
            //require(this.balance >= amount);
            uint interest = 0;
            uint balance = 0;
            for (uint i=depositsETH[token].length-1; i>=0; i--) {
                Deposit temp = depositsETH[token];
                balance += (temp[i].amount);
                if (balance >= amount) {
                    interest = (temp[i].blockNumber - block.number)*1.03*amount;
                }
            }
            uint interest = depositsETH[token].getamount
            depositsETH[msg.sender] -= amount;
            msg.sender.transfer(amount);
        } else if (tokenID == 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C) { //withdraw HAK
            require(deposits[msg.sender] >= amount);
            depositsHAK[msg.sender] -= amount;
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
        if(amount>borrowed[msg.sender]){
                amountRepayable = borrowed[msg.sender];
        } else {
            amountRepayable = borrowed[msg.sender];
        }
        if (tokenID == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) { //deposit ETH
            owner.transfer(amountRepayable);
        } else if (tokenID == 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C) { //deposit HAK
            tokenID.transferFrom(amountRepayable);
        }

        borrowed[msg.sender] -=  1.00 * amountRepayable * (0.95);
        return borrowed[msg.sender];
    }


    function liquidate(address token, address account) onlyOwner payable external override returns (bool) {

    }

    function getCollateralRatio(address token, address account) onlyOwner view external override returns (uint256) {

//0xc3F639B8a6831ff50aD8113B438E2Ef873845552
    }

    function getBalance(address token) onlyOwner view external override returns (uint256) {
        if (tokenID == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) { //deposit ETH
            return depositETH[msg.sender] * 1.03;
        } else if (tokenID == 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C) { //deposit HAK
            return depositHAK[msg.sender] * 1.03;
        }
    }
}
