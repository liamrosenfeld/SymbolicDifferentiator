//
//  SimplificationTests.swift
//
//
//  Created by Liam Rosenfeld on 12/12/21.
//

import XCTest
@testable import SymbolicDifferentiator

final class SimplificationTests: XCTestCase {
    func testFlattening() {
        let input1: Expr = 1 + x + 1 + x
        let input2: Expr = 1 * x * 1 * x
        let input3: Expr = (1 + 2 + 3) * 4 * 5
        
        let output1: Expr = .sum([1, x, 1, x])
        let output2: Expr = .product([1, x, 1, x])
        let output3: Expr = .product([.sum([1, 2, 3]), 4, 5])
        
        XCTAssertEqual(input1.flattened(), output1)
        XCTAssertEqual(input2.flattened(), output2)
        XCTAssertEqual(input3.flattened(), output3)
    }
    
    func testSum() {
        let input1: Expr = 1 + x + 3
        let input2: Expr = (3 * (x + 1)) + (3 * (x + 1)) + 5 + 7
        let input3: Expr = x + x + x
        let input4: Expr = (2 * x) + (4 * x) + (8 * x)
        
        let output1: Expr = x + 4
        let output2: Expr = (12 + 6 * (x + 1))
        let output3: Expr = 3 * x
        let output4: Expr = 14 * x
        
        XCTAssertEqual(input1.flattened().simplified(), output1)
        XCTAssertEqual(input2.flattened().simplified(), output2)
        XCTAssertEqual(input3.flattened().simplified(), output3)
        XCTAssertEqual(input4.flattened().simplified(), output4)
    }
    
    func testProduct() {
        let input1: Expr = 2 * x * 4
        let input2: Expr = x * x * x
        
        let output1: Expr = x * 8
        let output2: Expr = x ^ 3
        
        XCTAssertEqual(input1.flattened().simplified(), output1)
        XCTAssertEqual(input2.flattened().simplified(), output2)
    }
    
    func testPower() {
        let input1: Expr = 2 ^ 2
        let input2: Expr = 3 ^ (2 * x)
        let input3: Expr = x ^ (x + 1)
        let input4: Expr = x * (x ^ x)
        let input5: Expr = x * (x ^ (sin(x) - 1))
        
        let output1: Expr = 4
        let output2: Expr = 9 ^ x
        let output3: Expr = x ^ (1 + x)
        let output4: Expr = x ^ (1 + x)
        let output5: Expr = x ^ sin(x)
        
        XCTAssertEqual(input1.flattened().simplified(), output1)
        XCTAssertEqual(input2.flattened().simplified(), output2)
        XCTAssertEqual(input3.flattened().simplified(), output3)
        XCTAssertEqual(input4.flattened().simplified(), output4)
        XCTAssertEqual(input5.flattened().simplified(), output5)
    }
    
    func testNested() {
        let input: Expr = (((3 * x) + (2 * x)) * (4 * x)) / x
        let output: Expr = 20 * x
        
        XCTAssertEqual(input.flattened().simplified(), output)
    }
}
