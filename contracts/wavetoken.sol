// SPDX-License-Identifier: MIT
/**
 * Official wave token (WAVE) Contract
 * LinkedIn: https://www.linkedin.com/in/mark-lopez-50203a83/
 * Twitter: https://x.com/DarkMarkLolo
 * Telegram: https://t.me/@MaLo_Kram
 */
pragma solidity ^0.8.24;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract wavetoken is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public owner;

    uint256 private _totalSupply = 1000000000 * 10**18;
    string public name = "wave token";
    string public symbol = "WAVE";
    uint8 public decimals = 18;
    uint256 public maxWallet = (_totalSupply * 2) / 100; // 2% Limit

    constructor() {
        owner = msg.sender;
        _balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    function totalSupply() public view override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address o, address s) public view override returns (uint256) { return _allowances[o][s]; }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(_allowances[from][msg.sender] >= amount, "Allowance exceeded");
        _allowances[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0) && to != address(0), "Zero address error");

        // Owner is exempt from 2% wallet limit
        if (to != owner && from != owner) {
            require(_balances[to] + amount <= maxWallet, "Exceeds 2% Max Wallet");
        }

        uint256 burnAmt = amount / 100; // 1% Burn Tax
        uint256 sendAmt = amount - burnAmt;

        _balances[from] -= amount;
        _balances[to] += sendAmt;
        _totalSupply -= burnAmt;

        emit Transfer(from, to, sendAmt);
        emit Transfer(from, address(0), burnAmt);
    }
}