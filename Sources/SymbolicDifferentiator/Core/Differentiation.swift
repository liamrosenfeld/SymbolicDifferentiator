import Foundation

public extension Expr {
    func deriv() -> Expr {
        switch self {
        case .variable:
            return 1
        case .const(_):
            return 0
        case .sum(let exprs):
            return .sum(exprs.reduce(into: Multiset<Expr>()) { (multiset, elem) in
                    let (expr, count) = elem
                    multiset.add(expr.deriv(), amount: count)
                }
            )
        case .product(let exprs):
            // A B C (...) -> A' B C (...) + A B' C (...) + A B C' (...) + (...)
            let exprsArr = exprs.asArray
            let products = (0..<exprs.count).map { index -> Expr in
                var newExprs = exprsArr
                newExprs[Int(index)] = newExprs[Int(index)].deriv()
                return .product(Multiset(newExprs))
            }
            return .sum(Multiset(products))
        case .power(let base, let exp):
            // Generalized Power Rule:
            // f^g -> (g * f^(g-1) * f') + (f^g * ln(f) * g')
            // when f or g is a constant, half will vanish
            // which turns it into the two commonly taught power rules
            if case let .const(n) = exp {
                return .const(n) * (base ^ .const(n - 1)) * base.deriv()
            } else if case .const(_) = base {
                return (base ^ exp) * ln(base)
            } else {
                return .sum([
                    .product([exp, (base ^ (exp - 1)), base.deriv()]),
                    .product([(base ^ exp), ln(base), exp.deriv()])
                ])
            }
        case .fn(let fn, let expr):
            return fn.deriv(expr) * expr.deriv()
        }
    }
}
