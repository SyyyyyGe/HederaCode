// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/ERC165.sol";

contract ERC165SupportedInterface is ERC165{

    function supportsInterface(bytes4 _interfaceID)
    public 
    pure
    virtual 
    override 
    returns (bool) {
        return _interfaceID == type(ERC165).interfaceId;
    }
}
