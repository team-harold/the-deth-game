pragma solidity 0.5.11;
import "./Interfaces/ERC1155.sol";
import "./Interfaces/ERC1155TokenReceiver.sol";
import "./Libraries/AddressUtils.sol";

contract PensionToken is ERC1155 {

    mapping(address => mapping(uint256 => uint256)) _balances;
    mapping(address => mapping(address => bool)) _approvals;

    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes calldata data) external {
        require(_balances[from][id] >= value, "INSUFICIENT_BALANCE");
        _transfer(from, to, id, value);
        emit TransferSingle(msg.sender, from, to, id, value);
        _checkReceiver(from, to, id, value, data);
    }

    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external {
        require(ids.length == values.length, "INCONSISTENT_ARRAY_LENGTHS");
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 value = values[i];
            require(_balances[from][id] >= value, "INSUFICIENT_BALANCE");
            _transfer(from, to, id, value);
        }
        emit TransferBatch(msg.sender, from, to, ids, values);
        _checkBatchReceiver(from, to, ids, values, data);
    }

    function balanceOf(address owner, uint256 id) public view returns (uint256) {
        return _balances[owner][id];
    }

    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids) external view returns (uint256[] memory) {
        require(
            owners.length == ids.length,
            "INCONSISTENT_ARRAY_LENGTHS"
        );
        uint256[] memory balances = new uint256[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            balances[i] = balanceOf(owners[i], ids[i]);
        }
        return balances;
    }

    function setApprovalForAll(address operator, bool approved) external {
        _approvals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return _approvals[owner][operator];
    }

    function _transfer(address from, address to, uint256 id, uint256 value) internal {
        _balances[from][id] -= value;
        _balances[to][id] += value;
    }

    // bytes4 private constant ERC1155_IS_RECEIVER = 0x4e2312e0;
    bytes4 private constant ERC1155_RECEIVED = 0xf23a6e61;
    bytes4 private constant ERC1155_BATCH_RECEIVED = 0xbc197c81;

    function _checkReceiver(address from, address to, uint256 id, uint256 value, bytes memory data) internal {
        if (AddressUtils.isContract(to)) {
            require(ERC1155TokenReceiver(to).onERC1155Received(msg.sender, from, id, value, data) == ERC1155_RECEIVED, "TRANSFER_REJECTED"); // TODO return error if thrown
        }
    }

    function _checkBatchReceiver(address from, address to, uint256[] memory ids, uint256[] memory values, bytes memory data) internal {
        if (AddressUtils.isContract(to)) {
            require(ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, from, ids, values, data) == ERC1155_BATCH_RECEIVED, "TRANSFER_REJECTED"); // TODO return error if thrown
        }
    }

    // /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    address _minter;

    uint256 constant total = 10000;
    mapping(uint256 => uint256) _supplies;

    constructor(address minter) public {
        _minter = minter;
    }

    function mint(address to, uint256 id) external {
        _supplies[id] += total;
        _balances[to][id] += total;
        emit TransferSingle(msg.sender, address(0), to, id, total); 
        // emit event URI ?
    }

    function exists(uint256 id) external returns (bool) { // For OpenSea
        return _supplies[id] > 0; // Can we consider a token existing after all has been burnt ?
    }

    function supplyOf(uint256 id) external returns (uint256) {
        return _supplies[id];
    }

    // No need
    // function burn(uint256 id, uint356 value) external {
    //     require(_balances[msg.sender][id] >= value, "INSUFICIENT_BALANCE");
    //     _balances[msg.sender][id] -= value;
    //     emit TransferSingle(msg.sender, msg.sender, address(0), id, value);
    // }
}
