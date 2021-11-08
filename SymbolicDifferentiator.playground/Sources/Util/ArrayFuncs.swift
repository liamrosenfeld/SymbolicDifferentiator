import Foundation

extension Array where Element == Expr {
    func firstConst() -> Decimal? {
        for expr in self {
            if case let .const(val) = expr {
                return val
            } else if case let .negate(inner) = expr {
                if case let .const(innerVal) = inner {
                    return -1 * innerVal
                }
            }
        }
        return nil
    }
    
    func firstConstIndex() -> Int? {
        return self.firstIndex { expr in
            if case .const(_) = expr {
                return true
            } else if case let .negate(inner) = expr {
                if case .const(_) = inner {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
    }
    
    func firstPowOfVar() -> Decimal? {
        for expr in self {
            if case .variable = expr {
                return 1
            } else if case let .power(base, exp) = expr {
                if case .variable = base {
                    return exp
                }
            }
        }
        return nil
    }
}
