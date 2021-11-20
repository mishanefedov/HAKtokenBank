pragma solidity 0.7.0;

import './bank.sol';
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Bank is IBank {

    mapping (address => uint) depositsETH;
    mapping (address => uint) depositsHAK;
    mapping (address => uint) borrowedETH;
    mapping (address => uint) borrowedHAK;

    address payable public owner;
    uint balance;

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
        } else if (tokenID == 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C) { //deposit HAK
            tokenID.transferFrom(msg.sender, owner, amount);
        }
    }

    function withdraw(address token, uint256 amount) onlyOwner external override returns (uint256) {
        IERC20 tokenID = token;
        if (tokenID == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) { //deposit ETH
            require(this.balance >= amount);
            owner.transfer(amount);
        } else if (tokenID == 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C) { //deposit HAK
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
