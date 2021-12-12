import Foundation

extension Array where Element == Expr {
    func firstConst() -> Decimal? {
        for expr in self {
            if case let .const(val) = expr {
                return val
            }
        }
        return nil
    }
    
    func firstConstIndex() -> Int? {
        return self.firstIndex { expr in
            if case .const(_) = expr {
                return true
            } else {
                return false
            }
        }
    }
    
    func firstConstWithIndex() -> (Int, Decimal)? {
        for (index, expr) in self.enumerated() {
            if case let .const(val) = expr {
                return (index, val)
            }
        }
        return nil
    }
    
    func firstPowOfVar() -> Expr? {
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
