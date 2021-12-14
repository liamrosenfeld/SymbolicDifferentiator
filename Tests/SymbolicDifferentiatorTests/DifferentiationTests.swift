//
//  DifferentiationTests.swift
//  
//
//  Created by Liam Rosenfeld on 12/12/21.
//

import XCTest
@testable import SymbolicDifferentiator

final class DifferentiationTests: XCTestCase {
    func testSum() {
        let input: Expr = x + 2 + x
        let output: Expr = 1 + 0 + 1
        XCTAssertEqual(input.flattened().deriv().flattened(), output.flattened())
    }
    
    func testProduct() {
        let input1: Expr = (2 * x) * (3 * x)
        let input2: Expr = (2 * x) * (3 * x) * (4 * x)
        let input3: Expr = sin(x) * cos(x)
        
        let output1: Expr = 12 * x
        let output2: Expr = 72 * (x ^ 2)
        let output3: Expr = (cos(x) ^ 2) - (sin(x) ^ 2)
        
        XCTAssertEqual(input1.deriv().flattened().simplified(), output1)
        XCTAssertEqual(input2.deriv().flattened().simplified(), output2)
        XCTAssertEqual(input3.deriv().flattened().simplified(), output3)
    }
    
    func testPower() {
        let input1: Expr = x ^ 2
        let input2: Expr = 2 ^ x
        let input3: Expr = x ^ x
        let input4: Expr = x ^ sin(x)
        
        let output1: Expr = 2 * x
        let output2: Expr = (2^x) * ln(2)
        let output3: Expr = (x^x) * ln(x) + (x^x)
        let output4: Expr = (sin(x) * (x^(-1 + sin(x)))) + (ln(x) * cos(x) * (x^sin(x)))
        
        XCTAssertEqual(input1.deriv().flattened().simplified(), output1)
        XCTAssertEqual(input2.deriv().flattened().simplified(), output2)
        XCTAssertEqual(input3.deriv().flattened().simplified(), output3)
        XCTAssertEqual(input4.deriv().flattened().simplified(), output4.flattened().simplified())
    }
}

