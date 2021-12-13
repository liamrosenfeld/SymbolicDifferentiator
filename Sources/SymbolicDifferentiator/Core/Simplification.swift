import Foundation

public extension Expr {
    func simplified() -> Expr {
        switch self {
        case .sum(let exprs):
            return simplifySum(exprs)
        case .product(let exprs):
            return simplifyProduct(exprs)
        case .power(let base, let exp):
            return simplifyPower(base, exp)
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
    
    private func simplifySum(_ exprs: Multiset<Expr>) -> Expr {
        // attributes compacted into
        var constSum: Decimal = 0
        var exprsAndCoefficients: [Expr : Decimal] = [:]
        
        // break apart and sort
        for (expr, count) in exprs {
            let simple = expr.simplified()
            
            // nested sums should have already been lifted to top level
            switch simple {
            case .const(let const):
                constSum += const
            case .product(var inners):
                let coefficient: Decimal = {
                    if let coeff = inners.removeFirstConst() {
                        return coeff
                    } else {
                        return 1
                    }
                }()
                let simplified = inners.simplifyAll()
                exprsAndCoefficients[.product(simplified), default: 0] += coefficient * Decimal(count)
            default:
                exprsAndCoefficients[simple, default: 0] += Decimal(count)
            }
        }
        
        // reassemble
        var reduced: [Expr] = []
        if constSum != 0 {
            reduced.append(.const(constSum))
        }
        for (expr, coeff) in exprsAndCoefficients {
            reduced.append(.product([.const(coeff), expr]).simplified())
        }
        
        // unwrap if count is one
        if reduced.count == 1 {
            return reduced[0].simplified()
        }
        
        // flatten and repeat until done
        let simplified = reduced.map { $0.simplified() }
        var expr: Expr = .sum(Multiset(simplified))
        var flattened = expr.flattened()
        while expr != flattened {
            expr = flattened.simplified()
            flattened = expr.flattened()
        }
        
        return expr
    }
    
    private func simplifyProduct(_ exprs: Multiset<Expr>) -> Expr {
        // attributes compacted into
        var totalCoefficient: Decimal = 1
        var exprsAndExps: [Expr : Multiset<Expr>] = [:]
        
        // break apart and sort
        // product should have already been flattened
        for (expr, count) in exprs {
            let simple = expr.simplified()
            switch simple {
            case .const(let const):
                if const == 0 {
                    return .const(0)
                }
                totalCoefficient *= const
            case .power(let base, let exponent):
                if case let .product(innerExprs) = base {
                    for (innerExpr, innerCount) in innerExprs {
                        exprsAndExps[innerExpr, default: []].add(.const(Decimal(innerCount * count)))
                    }
                } else {
                    exprsAndExps[base, default: []].add(.product([exponent, .const(Decimal(count))]).flattened().simplified())
                }
            default:
                exprsAndExps[simple, default: []].add(.const(Decimal(count)))
            }
        }
        
        // reassemble
        // TODO: group terms of same power together?? -- maybe just a negative power
        var reduced: Multiset<Expr> = []
        if totalCoefficient != 1 {
            reduced.add(.const(totalCoefficient))
        }
        for (expr, exp) in exprsAndExps {
            let simpExp: Expr = .sum(exp).flattened().simplified()
            if case let .const(val) = simpExp {
                if val == 0 {
                    continue
                } else if val == 1 {
                    reduced.add(expr)
                } else {
                    reduced.add(.power(base: expr, exp: simpExp))
                }
            } else {
                reduced.add(.power(base: expr, exp: simpExp))
            }
        }
        
        // unwrap if count is one
        if reduced.count == 1 {
            return reduced.asArray[0].simplified()
        }
        
        // flatten and repeat until done
        var expr: Expr = .product(reduced.simplifyAll())
        var flattened = expr.flattened()
        while expr != flattened {
            expr = flattened.simplified()
            flattened = expr.flattened()
        }
        
        return expr
    }
    
    private func simplifyPower(_ base: Expr, _ exp: Expr) -> Expr {
        // 0 and 1 exponents
        let eSimple = exp.simplified()
        if case let .const(eVal) = eSimple {
            if eVal == 0 {
                return 1
            } else if eVal == 1 {
                return base.simplified()
            }
        }
        
        // nested powers
        let bSimple = base.simplified()
        if case let .power(innerBase, innerExp) = bSimple {
            return innerBase.simplified() ^ (eSimple * innerExp).simplified()
        }
        
        // constant & constant
        if case let .const(bVal) = bSimple {
            if case let .const(eVal) = eSimple {
                return .const(bVal.pow(exp: eVal))
            } else if case var .product(inners) = eSimple {
                if let const = inners.removeFirstConst() {
                    return .power(base: .const(bVal.pow(exp: const)), exp: .product(inners).simplified())
                }
            }
        }
        
        return bSimple ^ eSimple
    }
}
