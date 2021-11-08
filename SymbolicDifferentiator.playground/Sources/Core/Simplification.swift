import Foundation

public extension Expr {
    func simplified() -> Expr {
        switch self {
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
                var appl = fn.eval(val)
                if abs(appl.double.truncatingRemainder(dividingBy: 1)) < Double.ulpOfOne * 2 {
                    appl.round()
                    return .const(appl)
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
        var exprsAndCoefficients: [Expr : Decimal] = [:]
        
        // break apart and sort
        for expr in exprs {
            let simple = expr.simplified()
            
            // nested sums should have already been lifted to top level
            switch simple {
            case .const(let const):
                constSum += const
            case .product(var inners):
                let coefficient: Decimal = {
                    if let (index, coeff) = inners.firstConstWithIndex() {
                        inners.remove(at: index)
                        return coeff
                    } else {
                        return 1
                    }
                }()
                let simplified = inners.map { $0.simplified() }
                exprsAndCoefficients[.product(simplified), default: 0] += coefficient
            default:
                exprsAndCoefficients[simple, default: 0] += 1
            }
        }
        
        // reassemble
        var simplified: [Expr] = []
        if constSum != 0 {
            simplified.append(.const(constSum))
        }
        for (expr, coeff) in exprsAndCoefficients {
            simplified.append(.product([.const(coeff), expr]).simplified())
        }
        
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
            case .power(let base, let exponent):
                if case let .product(innerExprs) = base {
                    for innerExpr in innerExprs {
                        exprsAndExps[innerExpr, default: 0] += exponent
                    }
                } else {
                    exprsAndExps[base, default: 0] += exponent
                }
            default:
                exprsAndExps[simple, default: 0] += 1
            }
        }
        
        // reassemble
        // TODO: group terms of same power together?? -- maybe just a negative power
        var simplified: [Expr] = []
        if totalCoefficient != 1 {
            simplified.append(.const(totalCoefficient))
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
            return simplified[0]
        }
        
        return .product(simplified)
    }
}
