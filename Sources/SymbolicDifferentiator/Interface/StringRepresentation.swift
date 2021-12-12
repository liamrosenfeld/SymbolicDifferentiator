import Foundation

public extension Expr {
    func toString() -> String {
        switch self {
        case .variable:
            return "x"
        case .const(let const):
            return constToString(const)
        case .sum(var exprs):
            var string = "(\(exprs.removeFirst().toString())"
            for expr in exprs {
                if case let .const(val) = expr {
                    let sign = val < 0 ? "-" : "+"
                    string += " \(sign) \(constToString(abs(val)))"
                } else if case var .product(inner) = expr {
                    let sign: String = {
                        guard let (index, const) = inner.firstConstWithIndex() else {
                            return "+"
                        }
                        if const < 0 {
                            if const == -1 {
                                inner.remove(at: index)
                            } else {
                                inner[index] = .const(abs(const))
                            }
                            return "-"
                        } else {
                            return "+"
                        }
                    }()
                    if inner.count == 1 {
                        string += " \(sign) \(inner[0].toString())"
                    } else {
                        string += " \(sign) \(Expr.product(inner).toString())"
                    }
                } else {
                    string += " + \(expr.toString())"
                }
            }
            string += ")"
            return string
        case .product(var exprs):
            // if constant and expression,
            // pull out a constant and display it as a coefficient
            if exprs.count == 2,
               let firstConstIndex = exprs.firstConstIndex()
            {
                let firstConst = exprs.remove(at: firstConstIndex)
                if (firstConst == -1) {
                    return "-\(exprs[0].toString())"
                } else {
                    return "\(firstConst.toString())\(exprs[0].toString())"
                }
            }
            // display it normally
            else {
                var string = "(\(exprs[0].toString())"
                for expr in exprs.dropFirst() {
                    string += " * \(expr.toString())"
                }
                string += ")"
                return string
            }
        case .power(let base, let exp):
            return "\(base.toString())^\(exp.toString())"
        case .fn(let fn, let expr):
            return "\(fn.name)(\(expr.toString()))"
        }
    }
    
    func prettyTree(indent: String = "", last: Bool = true) -> String {
        let newIndent = indent + (last ? "   " : "│  ")
        let jointSym = last ? "└─ " : "├─ "
        
        switch self {
        case .variable:
            return indent + jointSym + "x"
        case .const(let const):
            return indent + jointSym + constToString(const)
        case .sum(let exprs):
            var returnString = indent + jointSym + "+"
            for (index, expr) in exprs.enumerated() {
                returnString += "\n" + expr.prettyTree(indent: newIndent, last: index == exprs.count - 1)
            }
            return returnString
            
        case .product(let exprs):
            var returnString = indent + jointSym + "*"
            for (index, expr) in exprs.enumerated() {
                returnString += "\n" + expr.prettyTree(indent: newIndent, last: index == exprs.count - 1)
            }
            return returnString
        case .power(let base, let exp):
            return indent + jointSym + "^"
            + "\n" + base.prettyTree(indent: newIndent, last: true)
            + "\n" + exp.prettyTree(indent: newIndent, last: true)
        case .fn(let fn, let expr):
            return indent + jointSym + fn.name
            + "\n" + expr.prettyTree(indent: newIndent, last: true)
        }
    }
}

extension Expr: CustomDebugStringConvertible {
    public var debugDescription: String {
        self.toString()
    }
}

fileprivate func constToString(_ const: Decimal) -> String {
    let absVal = abs(const)
    if absVal == pi {
        let sign = const < 0 ? "-" : ""
        return "\(sign)π"
    } else if absVal == e {
        let sign = const < 0 ? "-" : ""
        return "\(sign)e"
    } else {
        return "\(const)"
    }
}
