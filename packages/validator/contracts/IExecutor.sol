//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/contracts/utils/introspection/IERC165.sol";

/**
 * @dev Interface for a Shibboleth executor. Implementing an executor allows projects to leave the overhead of verifying
 *      shibboleth claims to the `ValidatorRegistry`. Simply register a new issuer with the registry and provide your
 *      executor address, and any claims made will result in calls to `executeClaim` on your executor. Executors
 *      only need to check that the caller is the address of the `ValidatorRegistry` and check any replay protection
 *      or validity conditions in `claimData`.
 */
interface IExecutor is IERC165 {
    /**
     * @dev Executes a claim that has been verified by the `ValidatorRegistry`. Implementers must check that this function
     *      was called by a registry they recognise, and that any conditions in claimData such as replay protection are met
     *      before acting on the request.
     * @param issuer The account that issued the claim.
     * @param claimant The account that is entitled to make the claim.
     * @param beneficiary The account that the claim should benefit.
     * @param claimData Claim data provided by the issuer.
     * @param executorData Contextual information stored on the ValidatorRegistry for this issuer.
     */
    function executeClaim(address issuer, address claimant, address beneficiary, bytes calldata claimData, bytes calldata executorData) external;

    /**
     * @dev Returns metadata explaining a claim.
     * @param issuer The address of the issuer.
     * @param claimData Claim data provided by the issuer.
     * @param executorData Contextual information stored on the ValidatorRegistry for this issuer.
     * @return A URL that resolves to JSON metadata as described in the spec.
     *         Callers must support at least 'data' and 'https' schemes.
     */
    function metadata(address issuer, bytes calldata claimData, bytes calldata executorData) external view returns(string memory);
}