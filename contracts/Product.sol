// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ProductIdentification {
    
    // --- 1. STATE VARIABLES & PACKING ---
    address public owner;
    uint256 public productCount;

    // ENGINEERING INSIGHT: Struct Packing (Gas Optimization)
    // Ethereum storage slots are 32 bytes (256 bits).
    // An address is 20 bytes. A bool is 1 byte.
    // By placing them next to each other, Solidity packs them into ONE slot (21 bytes).
    // If we put a 'string' between them, they would take TWO slots (costing 20,000 extra gas).
    struct Product {
        uint256 id;
        string name;
        string description;
        string manufactDate;
        address currentOwner; // 20 bytes
        bool isSold;          // 1 byte  (Total 21 bytes < 32 bytes -> Fits in 1 slot!)
        address[] history;    // Dynamic array to trace provenance
    }

    // --- 2. MAPPING VS ARRAY ---
    // Why Mapping? Arrays require looping to find an item (Cost: O(n)).
    // Mappings use Hashing (Keccak256) to find data instantly (Cost: O(1)).
    // We use the ID (uint256) as the key to fetch the Product struct.
    mapping(uint256 => Product) public products;

    // --- 3. EVENTS (The "Console.log" of Blockchain) ---
    // Events allow our frontend (React/Next.js) to "listen" for changes cheaply.
    // Storing this data in the contract storage is very expensive.
    event ProductCreated(uint256 indexed id, string name, address indexed manufacturer);
    event ProductTransferred(uint256 indexed id, address indexed from, address indexed to);

    // --- 4. CUSTOM ERRORS (Gas Saver) ---
    // Strings like "Only owner can add" take up storage. Custom errors are cheaper.
    error Unauthorized();
    error ProductNotFound();

    constructor() {
        owner = msg.sender; 
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    // --- LOGIC ---

    function addProduct(
        string memory _name, 
        string memory _description, 
        string memory _date
    ) public onlyOwner {
        // Increment first (IDs start at 1)
        productCount++;
        
        // POINTER STORAGE: We use 'storage' to reference the mapping directly.
        Product storage newProduct = products[productCount];
        
        newProduct.id = productCount;
        newProduct.name = _name;
        newProduct.description = _description;
        newProduct.manufactDate = _date;
        newProduct.currentOwner = msg.sender;
        newProduct.isSold = false;
        newProduct.history.push(msg.sender); // Genesis owner

        emit ProductCreated(productCount, _name, msg.sender);
    }

    function transferOwnership(uint256 _productId, address _newOwner) public {
        Product storage p = products[_productId];

        // Validation
        if (p.id == 0) revert ProductNotFound();
        if (p.currentOwner != msg.sender) revert Unauthorized();
        
        // State Update
        address oldOwner = p.currentOwner;
        p.currentOwner = _newOwner;
        p.history.push(_newOwner); // Traceability Chain
        p.isSold = true;

        emit ProductTransferred(_productId, oldOwner, _newOwner);
    }

    // Helper to read the history (Arrays inside structs are tricky to read automatically)
    function getProductHistory(uint256 _productId) public view returns (address[] memory) {
        return products[_productId].history;
    }
}
