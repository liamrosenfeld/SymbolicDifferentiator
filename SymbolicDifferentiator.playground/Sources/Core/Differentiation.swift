import Foundation

public extension Expr {
    func deriv() -> Expr {
        switch self {
        case .variable:
            return 1
        case .const(_):
            return 0
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
        case .power(let base, let exp):
            return .const(exp) * (base ^ (exp - 1)) * base.deriv()
        case .fn(let fn, let expr):
            return fn.deriv(expr) * expr.deriv()
        }
    }
}
