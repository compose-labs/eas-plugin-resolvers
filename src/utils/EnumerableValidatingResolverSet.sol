// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IValidatingResolver} from "../interfaces/IValidatingResolver.sol";

/// @title EnumerableValidatingResolverSet
/// @notice Library for managing a set of IValidatingResolver contracts
/// @dev Utilizes OpenZeppelin's EnumerableSet library with custom type casting for IValidatingResolver
library EnumerableValidatingResolverSet {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct Set {
        EnumerableSet.Bytes32Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(
        Set storage set,
        IValidatingResolver value
    ) internal returns (bool) {
        return set._inner.add(bytes32(uint256(uint160(address(value)))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(
        Set storage set,
        IValidatingResolver value
    ) internal returns (bool) {
        return set._inner.remove(bytes32(uint256(uint160(address(value)))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(
        Set storage set,
        IValidatingResolver value
    ) internal view returns (bool) {
        return set._inner.contains(bytes32(uint256(uint160(address(value)))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Set storage set) internal view returns (uint256) {
        return set._inner.length();
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(
        Set storage set,
        uint256 index
    ) internal view returns (IValidatingResolver) {
        return
            IValidatingResolver(
                address(uint160(uint256(set._inner.at(index))))
            );
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(
        Set storage set
    ) internal view returns (IValidatingResolver[] memory) {
        bytes32[] memory store = set._inner.values();
        IValidatingResolver[] memory result = new IValidatingResolver[](
            store.length
        );

        for (uint256 i = 0; i < store.length; i++) {
            result[i] = IValidatingResolver(
                address(uint160(uint256(store[i])))
            );
        }

        return result;
    }
}
