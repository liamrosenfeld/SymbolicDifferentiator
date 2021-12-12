import Foundation

public extension Expr {
    func evaluate(at val: Decimal) -> Decimal {
        switch self {
        case .variable:
            return val
        case .const(let const):
            return const
        case .sum(let inners):
            return inners.reduce(0) { $0 + $1.evaluate(at: val) }
        case .product(let inners):
            return inners.reduce(1) { $0 * $1.evaluate(at: val) }
        case .power(let base, let exp):
            return base.evaluate(at: val).pow(exp: exp.evaluate(at: val))
        case .fn(let fn, let expr):
            return fn.eval(expr.evaluate(at: val))
        }
    }
}
