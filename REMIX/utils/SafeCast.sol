// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)
// 更新转为int
pragma solidity ^0.8.0;

library SafeCast {

    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toInt256(uint256 value) internal pure returns(int256){
        require(value < 2**255, "SafeCast: value doesn\'t fit in int256");
        return int256(value);
    }

    function toInt128(uint256 value) internal pure returns(int128){
        require(value < 2**127, "SafeCast: value doesn\'t fit in int128");
        return int128(int256(value));
    }

    function toInt64(uint256 value) internal pure returns(int64){
        require(value < 2**63, "SafeCast: value doesn\'t fit in int64");
        return int64(int256(value));
    }

    function toInt32(uint256 value) internal pure returns(int32){
        require(value < 2**31, "SafeCast: value doesn\'t fit in int32");
        return int32(int256(value));
    }
    function toInt16(uint256 value) internal pure returns(int16){
        require(value < 2**15, "SafeCast: value doesn\'t fit in int16");
        return int16(int256(value));
    }

    function toInt8(uint256 value) internal pure returns(int8){
        require(value < 2**7, "SafeCast: value doesn\'t fit in int8");
        return int8(int256(value));
    }
}