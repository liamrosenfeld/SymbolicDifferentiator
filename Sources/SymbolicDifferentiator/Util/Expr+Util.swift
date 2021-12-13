//
//  Expr+Util.swift
//  
//
//  Created by Liam Rosenfeld on 12/13/21.
//

import Foundation

extension Expr {
    func isNegative() -> Bool {
        if case let .product(inner) = self {
            for expr in inner.asArray {
                if case let .const(val) = expr, val < 0 {
                    return true
                }
            }
        }
        return false
    }
    
    func absValAndIsNeg() -> (Expr, Bool) {
        if case var .product(inner) = self {
            // can ignore count because this should only be run on a simplified expression
            for (expr, _) in inner {
                if case let .const(val) = expr, val < 0 {
                    inner.remove(expr)
                    inner.add(.const(abs(val)))
                    return (.product(inner), true)
                }
            }
            return (self, false)
        } else {
            return (self, false)
        }
    }
}


extension Multiset where T == Expr {
    @inline(__always) func simplifyAll() -> Self {
        self.reduce(into: Self()) { partialResult, elem in
            partialResult.add(elem.elem, amount: elem.count)
        }
    }
    
    mutating func removeFirstConst() -> Decimal? {
        for (expr, count) in self {
            if case .const(let val) = expr {
                removeAll(expr)
                return val * Decimal(count)
            }
        }
        return nil
    }
    
    mutating func removeFirstNegative() -> Bool{
        // can ignore count because this should only be run on a simplified expression
        for (expr, _) in self {
            if case let .const(val) = expr, val < 0 {
                self.remove(expr)
                if val != -1 || self.count == 0 {
                    self.add(.const(abs(val)))
                }
                return true
            }
        }
        return false
    }
}

extension Array where Element == Expr {
    mutating func removeFirstConst() -> Decimal? {
        for (idx, expr) in self.enumerated() {
            if case let .const(val) = expr {
                self.remove(at: idx)
                return val
            }
        }
        return nil
    }
    
    mutating func removeFirstPositiveOrFirst() -> Expr {
        for (idx, expr) in self.enumerated() {
            if !expr.isNegative() {
                return self.remove(at: idx)
            }
        }
        return self.removeFirst()
    }
}
