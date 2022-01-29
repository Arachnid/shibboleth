//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../BaseValidator.sol";
import "@openzeppelin/contracts/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/contracts/utils/Strings.sol";

/**
 * @dev A Validator mixin that sends ERC721 tokens from an allowance. Counter is used to determine token id starting from 1. 
 */
abstract contract ERC721TransferExecutor is BaseValidator {
    using Strings for uint256;
    uint256 public lastClaimedTokenId;

    function tokenInfo(bytes calldata data) public virtual view returns(address token, address sender);

    function claim(address beneficiary, bytes calldata data, bytes calldata authsig, bytes calldata claimsig) public override virtual returns(address issuer, address claimant) {
        (issuer, claimant) = super.claim(beneficiary, data, authsig, claimsig);
        (address token, address sender) = tokenInfo(data);
        lastClaimedTokenId += 1;
        IERC721(token).safeTransferFrom(sender, beneficiary, lastClaimedTokenId);
    }

    function metadata(address issuer, address claimant, bytes calldata claimData) public override virtual view returns(string memory) {
        string memory ret = super.metadata(issuer, claimant, claimData);
        if(bytes(ret).length > 0) {
            return ret;
        }
        
        (address token, address sender) = tokenInfo(claimData);
        bool approved = IERC721(token).isApprovedForAll(sender, address(this));
        string memory symbol = IERC721Metadata(token).symbol();
        if(!approved) {
            return string(abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode("{\"valid\":false,\"error\":\"Token not approved.\"}")
            ));
        }

        uint tokenId = lastClaimedTokenId + 1;
        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(abi.encodePacked(
                "{\"valid\":true,\"data\":{\"title\": \"$",
                symbol,
                " token transfer\", \"tokentype\":721,\"token\":\"",
                uint256(uint160(token)).toHexString(20),
                "\",\"tokenids\":[\"",
                tokenId.toString(),
                "\"]}}"
            ))
        ));
    }
}
