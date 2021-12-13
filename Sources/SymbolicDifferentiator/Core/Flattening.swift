public extension Expr {
    func flattened() -> Expr {
        switch self {
        case .sum(let innerExprs):
            var flattenedInner: Multiset<Expr> = []
            for (expr, count) in innerExprs {
                if case let .sum(innerExprs) = expr {
                    for (innerExpr, innerCount) in innerExprs {
                        flattenedInner.add(innerExpr.flattened(), amount: innerCount)
                    }
                } else {
                    flattenedInner.add(expr.flattened(), amount: count)
                }
            }
            let needAnother = flattenedInner.contains { (elem, _) in
                if case .sum(_) = elem { return true } else { return false }
            }
            return needAnother ? .sum(flattenedInner).flattened() : .sum(flattenedInner)
        case .product(let innerExprs):
            var flattenedInner: Multiset<Expr> = []
            for (expr, count) in innerExprs {
                if case let .product(innerExprs) = expr {
                    for (innerExpr, innerCount) in innerExprs {
                        flattenedInner.add(innerExpr.flattened(), amount: innerCount)
                    }
                } else {
                    flattenedInner.add(expr.flattened(), amount: count)
                }
            }
            let needAnother = flattenedInner.contains { (elem, _) in
                if case .product(_) = elem { return true } else { return false }
            }
            return needAnother ? .product(flattenedInner).flattened() : .product(flattenedInner)
        case .power(let expr, let exp):
            return .power(base: expr.flattened(), exp: exp.flattened())
        default:
            return self
        }
    }
}
