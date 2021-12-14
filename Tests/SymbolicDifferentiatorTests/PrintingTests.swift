//
//  PrintingTests.swift
//
//
//  Created by Liam Rosenfeld on 12/12/21.
//

import XCTest
@testable import SymbolicDifferentiator

final class PrintingTests: XCTestCase {
    func testSum() {
        let input1: Expr = 1 + x
        let input2: Expr = 1 + (2 + 3)
        let input3: Expr = 1 + 2 + 3
        
        let output1 = Set(["(1 + x)", "(x + 1)"])
        let output2 = Set([
            "(1 + (2 + 3))",
            "((2 + 3) + 1)",
            "(1 + (3 + 2))",
            "((3 + 2) + 1)"
        ])
        let output3 = Set([
            "(1 + 2 + 3)",
            "(2 + 3 + 1)",
            "(3 + 2 + 1)",
            "(1 + 3 + 2)",
            "(2 + 1 + 3)",
            "(3 + 1 + 2)"
        ])
        
        XCTAssertTrue(output1.contains(input1.toString()))
        XCTAssertTrue(output2.contains(input2.toString()))
        XCTAssertTrue(output3.contains(input3.flattened().toString()))
    }
    
    func testProduct() {
        let input1: Expr = 2 * x
        let input2: Expr = 2 * (x * sin(x))
        let input3: Expr = x * ln(x) * sin(x)
        
        let output1 = "2x"
        let output2 = Set(["2(x * sin(x))", "2(sin(x) * x)"])
        let output3 = Set([
            "(x * ln(x) * sin(x))",
            "(ln(x) * sin(x) * x)",
            "(sin(x) * ln(x) * x)",
            "(ln(x) * x * sin(x))",
            "(x * sin(x) * ln(x))",
            "(sin(x) * x * ln(x))",
        ])
        
        XCTAssertEqual(input1.toString(), output1)
        XCTAssertTrue(output2.contains(input2.toString()))
        XCTAssertTrue(output3.contains(input3.flattened().toString()))
    }
    
    func testPower() {
        let input1: Expr = 2 ^ x
        let input2: Expr = x ^ (x * sin(x))
        
        let output1 = "2^x"
        let output2 = Set(["x^(x * sin(x))", "x^(sin(x) * x)"])
        
        XCTAssertEqual(input1.toString(), output1)
        XCTAssertTrue(output2.contains(input2.toString()))
    }
    
    func testNegative() {
        let input1 = 1 - x
        let input2 = -x
        let input3 = -x * (1 - x)
        
        let output1 = "(1 - x)"
        let output2 = "-x"
        let output3 = Set(["(-x * (1 - x))", "((1 - x) * -x)"])
        
        XCTAssertEqual(input1.toString(), output1)
        XCTAssertEqual(input2.toString(), output2)
        XCTAssertTrue(output3.contains(input3.toString()))
    }
}
