public extension Expr {
    func flattened() -> Expr {
        switch self {
        case .sum(let innerExprs):
            let flattenedInner: [Expr] = innerExprs.flatMap { expr -> [Expr] in
                if case let .sum(innerExprs) = expr {
                    return innerExprs.map { $0.flattened() }
                } else {
                    return [expr.flattened()]
                }
            }
            let needAnother = flattenedInner.contains { if case .sum(_) = $0 { return true } else { return false } }
            return needAnother ? .sum(flattenedInner).flattened() : .sum(flattenedInner)
        case .product(let innerExprs):
            let flattenedInner: [Expr] = innerExprs.flatMap { expr -> [Expr] in
                if case let .product(innerExprs) = expr {
                    return innerExprs.map { $0.flattened() }
                } else {
                    return [expr.flattened()]
                }
            }
            let needAnother = flattenedInner.contains { if case .product(_) = $0 { return true } else { return false } }
            return needAnother ? .product(flattenedInner).flattened() : .product(flattenedInner)
        case .power(let expr, let exp):
            return .power(expr.flattened(), exp)
        default:
            return self
        }
    }
}
