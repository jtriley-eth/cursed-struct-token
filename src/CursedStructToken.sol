// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

// -------------------------------------------------------------------------------------------------
// STRUCT DEFINITION

// wArNiNg: nAmInG fUnCtIoN tYpE pArAmEtErS iS dEpReCaTeD.
struct CursedStruct {
    function() pure returns (string memory) name;
    function() pure returns (string memory) symbol;
    function() pure returns (uint8) decimals;
    function(
        uint256 // slot
    ) view returns (uint256) totalSupply;
    function(
        mapping(address => uint256) storage, // balances,
        address // account
    ) view returns (uint256) balanceOf;
    function(
        mapping(address => mapping(address => uint256)) storage, // allowances,
        address, // owner,
        address // spender
    ) view returns (uint256) allowance;
    function(
        mapping(address => uint256) storage, // balances,
        address, // sender,
        address, // receiver,
        uint256 // amount
    ) returns (bool) transfer;
    function(
        mapping(address => uint256) storage, // balances,
        mapping(address => mapping(address => uint256)) storage, // allowances,
        address, // caller,
        address, // sender,
        address, // receiver,
        uint256 // amount
    ) returns (bool) transferFrom;
    function(
        mapping(address => mapping(address => uint256)) storage, // allowances,
        address, // caller,
        address, // spender,
        uint256 // amount
    ) returns (bool) approve;
}

// -------------------------------------------------------------------------------------------------
// FUNCTION DEFINITIONS

function _name() pure returns (string memory) {
    return "Cursed Struct Token";
}

function _symbol() pure returns (string memory) {
    return "CST";
}

function _decimals() pure returns (uint8) {
    return 18;
}

function _totalSupply(uint256 slot) view returns (uint256) {
    uint256 supply;
    assembly {
        supply := sload(slot)
    }
    return supply;
}

function _balanceOf(
    mapping(address => uint256) storage balances,
    address account
) view returns (uint256) {
    return balances[account];
}

function _allowance(
    mapping(address => mapping(address => uint256)) storage allowances,
    address owner,
    address spender
) view returns (uint256) {
    return allowances[owner][spender];
}

function _transfer(
    mapping(address => uint256) storage balances,
    address sender,
    address receiver,
    uint256 amount
) returns (bool) {
    balances[sender] -= amount;
    balances[receiver] += amount;
    return true;
}

function _transferFrom(
    mapping(address => uint256) storage balances,
    mapping(address => mapping(address => uint256)) storage allowances,
    address caller,
    address sender,
    address receiver,
    uint256 amount
) returns (bool) {
    uint256 allowed = allowances[caller][sender];
    if (allowed != type(uint256).max)
        allowances[caller][sender] = allowed - amount;
    balances[sender] -= amount;
    balances[receiver] += amount;
    return true;
}

function _approve(
    mapping(address => mapping(address => uint256)) storage allowances,
    address caller,
    address spender,
    uint256 amount
) returns (bool) {
    allowances[caller][spender] = amount;
    return true;
}

// -------------------------------------------------------------------------------------------------
// CONTRACT DEFINITION

contract CursedStructToken {
    /// @notice Logged on transfer.
    /// @param sender Sending address.
    /// @param receiver Receiving address.
    /// @param amount Amount transferred.
    event Transfer(
        address indexed sender,
        address indexed receiver,
        uint256 amount
    );

    /// @notice Logged on approval.
    /// @param owner Approving address.
    /// @param spender Approved address.
    /// @param amount Amount spender can transfer on behalf of owner.
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    uint256 _totalSupplyAmount;

    mapping(address => uint256) _balances;

    mapping(address => mapping(address => uint256)) _allowances;

    /// @notice Returns name.
    /// @return Name.
    function name() public pure returns (string memory) {
        return _getCursedStruct().name();
    }

    /// @notice Returns symbol.
    /// @return Symbol.
    function symbol() public pure returns (string memory) {
        return _getCursedStruct().symbol();
    }

    /// @notice Returns decimals.
    /// @return Decimals.
    function decimals() public pure returns (uint8) {
        return _getCursedStruct().decimals();
    }

    /// @notice Returns total supply.
    /// @return Supply.
    function totalSupply() public view returns (uint256) {
        return _getCursedStruct().totalSupply(0);
    }

    /// @notice Returns balance of an account.
    /// @param account Account address whose balance is queried.
    /// @return Balance of account.
    function balanceOf(address account) public view returns (uint256) {
        return _getCursedStruct().balanceOf(_balances, account);
    }

    /// @notice Returns allowance a spender has to transfer on behalf of an owner.
    /// @param owner Owner address.
    /// @param spender Spender address.
    /// @return Amount spender may transfer on behalf of the owner.
    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _getCursedStruct().allowance(_allowances, owner, spender);
    }

    /// @notice Transfers an amount of tokens from the caller to the receiver.
    /// @dev Logs Transfer. Reverts on sender balance underflow AND receiver balance overflow.
    /// @param receiver Receiving address.
    /// @param amount Amount to transfer.
    /// @return success True if successful transfer.
    function transfer(address receiver, uint256 amount)
        public
        returns (bool success)
    {
        success = _getCursedStruct().transfer(
            _balances,
            msg.sender,
            receiver,
            amount
        );
        emit Transfer(msg.sender, receiver, amount);
    }

    /// @notice Transfers an amount of tokens from the sender to the receiver. Can be called by any
    /// other address.
    /// @dev Logs Transfer. Reverts on sender balance underflow, receiver balance overflow, AND
    /// sender's allowance for caller underflow.
    /// @param sender Sending address.
    /// @param receiver Receiving address.
    /// @param amount Amount to transfer.
    /// @return success True if successful transfer.
    function transferFrom(
        address sender,
        address receiver,
        uint256 amount
    ) public returns (bool success) {
        success = _getCursedStruct().transferFrom(
            _balances,
            _allowances,
            msg.sender,
            sender,
            receiver,
            amount
        );
        emit Transfer(sender, receiver, amount);
    }

    /// @notice Caller approves spender to transfer up to an amount on their behalf.
    /// @dev Logs Approval.
    /// @param spender Address to which the caller is delegating an allowance.
    /// @param amount Amount the spender is allowed to transfer on the caller's behalf.
    /// @return success True if successful approval.
    function approve(address spender, uint256 amount)
        public
        returns (bool success)
    {
        success = _getCursedStruct().approve(
            _allowances,
            msg.sender,
            spender,
            amount
        );
        emit Approval(msg.sender, spender, amount);
    }

    /// @notice Mint an amount of tokens to a receiver.
    /// @dev Reverts on receiver balance overflow OR total supply overflow.
    /// @param receiver Receiver address.
    /// @param amount Amount to mint.
    function mint(address receiver, uint256 amount) public {
        _balances[receiver] += amount;
        _totalSupplyAmount += amount;
    }

    // Constructs the cursed struct.
    function _getCursedStruct() internal pure returns (CursedStruct memory cs) {
        cs.name = _name;
        cs.symbol = _symbol;
        cs.decimals = _decimals;
        cs.totalSupply = _totalSupply;
        cs.balanceOf = _balanceOf;
        cs.allowance = _allowance;
        cs.transfer = _transfer;
        cs.transferFrom = _transferFrom;
        cs.approve = _approve;
    }
}
