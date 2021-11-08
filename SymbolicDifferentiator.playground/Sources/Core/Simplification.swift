import Foundation

public extension Expr {
    func simplified() -> Expr {
        switch self {
        case .negate(let expr):
            let exprSimple = expr.simplified()
            // cancel nested negatives
            if case let .negate(inner) = exprSimple {
                return inner.simplified()
            } else if case let .const(val) = exprSimple {
                if val < 0 {
                    return .const(abs(val))
                }
            }
            return .negate(exprSimple)
        case .sum(let exprs):
            return simplifySum(exprs)
        case .product(let exprs):
            return simplifyProduct(exprs)
        case .power(let base, let exp):
            // 0 and 1 exponents
            if exp == 0 {
                return 1
            } else if exp == 1 {
                return base.simplified()
            }
            
            // nested powers
            let bSimple = base.simplified()
            if case let .power(innerBase, innerExp) = bSimple {
                return innerBase ^ (exp * innerExp)
            }
            
            // power of a constant
            if case let .const(val) = bSimple {
                return .const(val.pow(exp: exp))
            }
            
            return bSimple ^ exp
        case .fn(let fn, let expr):
            // simplify if expr is a constant that returns an integer
            if case let .const(val) = expr {
                let appl = fn.eval(val)
                if abs(appl.double.truncatingRemainder(dividingBy: 1)) < Double.ulpOfOne * 2 {
                    return .const(Decimal(appl.int))
                } else {
                    return self
                }
            } else {
                return self
            }
        default:
            return self
        }
    }
    
    private func simplifySum(_ exprs: [Expr]) -> Expr {
        // attributes compacted into
        var constSum: Decimal = 0
        var variableCoefficients: [Decimal: Decimal] = [:] // exponent: sum coefficient
        var everythingElse: [Expr] = []
        
        // break apart and sort
        for expr in exprs {
            let simple = expr.simplified()
            
            // nested sums should have already been lifted to top level
            switch simple {
            case .const(let const):
                constSum += const
            case .negate(let inner):
                if case let .const(const) = inner {
                    constSum -= const
                } else {
                    if let cancelIndex = everythingElse.firstIndex(of: inner) {
                        everythingElse.remove(at: cancelIndex)
                    }
                    everythingElse.append(simple)
                }
            case .product(let exprs):
                // find the coefficient (if it exists)
                let coefficient = exprs.firstConst() ?? 1
                
                // find the exponent of the variable (if it exist)
                // var with no exponents is exp == 1
                if let exponent = exprs.firstPowOfVar() {
                    // add it
                    if variableCoefficients[exponent] != nil {
                        variableCoefficients[exponent]! += coefficient
                    } else {
                        variableCoefficients[exponent] = coefficient
                    }
                } else {
                    // if there is no var, just add it to the everything else
                    everythingElse.append(simple)
                }
            default:
                everythingElse.append(simple)
            }
        }
        
        // reassemble
        var simplified: [Expr] = []
        if constSum != 0 {
            simplified.append(.const(constSum))
        }
        if variableCoefficients.count != 0 {
            for (exp, coeff) in variableCoefficients {
                if exp == 0 {
                    simplified.append(.const(coeff))
                } else if exp == 1 {
                    simplified.append(.const(coeff) * .variable)
                } else {
                    simplified.append(.const(coeff) * (.variable ^ exp))
                }
            }
        }
        simplified.append(contentsOf: everythingElse)
        
        // unwrap if count is one
        if simplified.count == 1 {
            return simplified[0]
        }
        
        return .sum(simplified)
    }
    
    private func simplifyProduct(_ exprs: [Expr]) -> Expr {
        // attributes compacted into
        var totalCoefficient: Decimal = 1
        var exprsAndExps: [Expr : Decimal] = [:]
        
        // break apart and sort
        // product should have already been flattened
        for expr in exprs {
            let simple = expr.simplified()
            switch simple {
            case .const(let const):
                if const == 0 {
                    return .const(0)
                }
                totalCoefficient *= const
            case .negate(let inner):
                totalCoefficient *= -1
                switch inner {
                case .const(let const):
                    totalCoefficient *= const
                case .power(let base, let exponent):
                    if case let .product(innerExprs) = base {
                        for innerExpr in innerExprs {
                            exprsAndExps[innerExpr, default: 0] += exponent
                        }
                    } else {
                        exprsAndExps[base, default: 0] += exponent
                    }
                default:
                    exprsAndExps[inner, default: 0] += 1
                }
            case .power(let base, let exponent):
                if case let .product(innerExprs) = base {
                    for innerExpr in innerExprs {
                        exprsAndExps[innerExpr, default: 0] += exponent
                    }
                } else {
                    exprsAndExps[base, default: 0] += exponent
                }
            default:
                exprsAndExps[expr, default: 0] += 1
            }
        }
        
        // reassemble
        // TODO: group terms of same power together?? -- maybe just a negative power
        var simplified: [Expr] = []
        if abs(totalCoefficient) != 1 {
            simplified.append(.const(abs(totalCoefficient)))
        }
        for (expr, exp) in exprsAndExps {
            if exp == 1 {
                simplified.append(expr)
            } else if exp == 0 {
                continue
            } else {
                simplified.append(.power(expr, exp))
            }
        }
        
        // unwrap if count is one
        if simplified.count == 1 {
            if totalCoefficient < 0 {
                return .negate(simplified[0])
            } else {
                return simplified[0]
            }
        }
        
        if totalCoefficient < 0 {
            return .negate(.product(simplified))
        } else {
            return .product(simplified)
        }
    }
}
