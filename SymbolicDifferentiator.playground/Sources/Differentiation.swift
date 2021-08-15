import Foundation

public extension Expr {
    func deriv() -> Expr {
        switch self {
        case .variable:
            return 1
        case .const(_):
            return 0
        case .negate(let expr):
            return .negate(expr.deriv())
        case .sum(let exprs):
            return .sum(exprs.map { $0.deriv() })
        case .product(let exprs):
            // A B C (...) -> A' B C (...) + A B' C (...) + A B C' (...) + (...)
            let products = (0..<exprs.count).map { index -> Expr in
                var newExprs = exprs
                newExprs[index] = newExprs[index].deriv()
                return .product(newExprs)
            }
            return .sum(products)
        case .quotient(let high, let low):
            return (low * high.deriv() - high * low.deriv()) / (low ^ 2)
        case .power(let base, let exp):
            return .const(exp) * (base ^ (exp - 1)) * base.deriv()
        }
    }
}
