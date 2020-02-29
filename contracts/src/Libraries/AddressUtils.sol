pragma solidity ^0.5.2;

library AddressUtils {

    function isContract(address addr) internal view returns (bool) {
        bytes32 codehash;
        assembly { codehash := extcodehash(addr) }
        return (codehash != 0x0 && codehash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);
    }
}
