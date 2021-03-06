pragma solidity ^0.4.23;

contract MultiSigWallet {
    address private _owner;
    mapping(address => uint8) private _owners;

    mapping (uint => Transaction) private _transactions;
    uint[] private _pendingTransactions;

    // auto incrememnting transaction ID
    uint private _transactionIndex;

    // @dev MIN_SIGNATURES: we need x amount of signatures to sign a multisig transaction
    // i.e M-of-N is currently defined as 2-of-N Signatures Required.
    uint constant MIN_SIGNATURES = 2;

    struct Transaction {
        address source;
        address destination;
        uint value;
        uint signatureCount;
        mapping (address => uint8) signatures; // need to keep record of who signed
    }

    modifier isOwner() {
        require(msg.sender == _owner);
        _;
    }

    modifier validOwner() {
        require(msg.sender == _owner || _owners[msg.sender] == 1);
        _;
    }

    /// @dev logged events
    event DepositFunds(address source, uint amount);
    // @dev full sequence of the transaction event logged
    event TransactionCreated(address source, address destination, uint value, uint transactionID);
    event TransactionCompleted(address source, address destination, uint value, uint transactionID);
    event TransactionSigned(address by, uint transactionID); //keeps track of who is signing the transactions

    /// @dev Contract constructor sets initial owners
    constructor() public {
        _owner = msg.sender;
    }

    /// @dev add new owner to have access, enables the ability to create more than one owner to manage the wallet
    function addOwner(address newOwner) isOwner public {
        _owners[newOwner] = 1;
    }

    /// @dev remove owner
    function removeOwner(address existingOwner) isOwner public { //remove suspicious owners
        _owners[existingOwner] = 0;
    }

    /// @dev Fallback function, which accepts ether when sent to contract
    function () public payable {
        emit DepositFunds(msg.sender, msg.value);
    }

    // @ dev Transfer ether to owner
    function withdraw(uint amount) public {
        // YOUR CODE HERE
    }

    /// @dev Send ether to specific a transaction.
    /// @param destination - Transaction target address.
    /// @param value - Transaction ether value.
    /// Start by creating your transaction. Since we defined it as a struct,
    /// we need to define it in a memory context. Update the member attributes.
    ///
    /// NOTE: Keep transactionID updated
    function transferTo(address destination, uint value) validOwner public {
        require(address(this).balance >= value);
        
        // will always be unique, until max uint
        uint transactionID = _transactionIndex++;

        // TODO: Create the transaction
        // YOUR CODE HERE 

        // TODO: Add transaction to the data structures
        // YOUR CODE HERE

        // log that the transaction was created to a specific address
        emit TransactionCreated(msg.sender, destination, value, transactionID);
    }

    /// @return Returns pending transcations
    function getPendingTransactions() view validOwner public returns (uint[]) {
        return _pendingTransactions;
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionID Transaction ID.
    /// Sign and Execute transaction.
    function signTransaction(uint transactionID) validOwner public {
        // Use Transaction Structure. Above in TransferTo function, because
        // we created the structure, we had to specify the keyword memory.
        // Now, we are pulling in the structure from a storage mechanism
        // Basically, 'storage' will stop the EVM from duplicating the actual
        // object, and instead will reference it directly.

        // Create variable transaction using storage (which creates a reference point)
        Transaction storage transaction = _transactions[transactionID];

        // Transaction must exist, note: can't do require(transaction).
        require(0x0 != transaction.source);

        // Creator cannot sign the transaction
        // YOUR CODE HERE

        // Cannot sign a transaction more than once
        // YOUR CODE HERE

        // Assign the transaction = 1, so that when the function is called again it will fail
        // YOUR CODE HERE

        // Increment signatureCount
        // YOUR CODE HERE

        // log transaction
        emit TransactionSigned(msg.sender, transactionID);

        // Check to see if transaction has enough signatures so that it can actually be completed
        // if true, make the transaction
        // YOUR CODE HERE
        if () { // Step 0. Add conditional
            // Step 1. Ensure there are enough funds
            // Step 2. Send the ETH

            // log that the transaction was complete
            emit TransactionCompleted(transaction.source, transaction.destination, transaction.value, transactionID);
            // Step 3. Delete the Transaction
        }
    }

    /// @dev Remove transaction from the pending
    function deleteTransaction(uint transactionId) validOwner public {
        uint8 replace = 0;
        for(uint i = 0; i < _pendingTransactions.length; i++) {
            if (replace == 1) {
                _pendingTransactions[i-1] = _pendingTransactions[i];
            } else if (transactionId == _pendingTransactions[i]) {
                replace = 1;
            }
        }
        delete _pendingTransactions[_pendingTransactions.length - 1];
        _pendingTransactions.length--;
        delete _transactions[transactionId];
    }

    /// @return Returns balance
    function walletBalance() view public returns (uint) {
        return address(this).balance;
    }
}