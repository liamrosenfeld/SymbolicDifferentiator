import Foundation

public extension Expr {
    func toString() -> String {
        switch self {
        case .variable:
            return "x"
        case .const(let const):
            return constToString(const)
        case .negate(let expr):
            return "-\(expr.toString())"
        case .sum(let exprs):
            var string = "(\(exprs[0].toString())"
            for expr in exprs.dropFirst() {
                if case let .negate(inner) = expr {
                    string += " - \(inner.toString())"
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
                return "\(firstConst.toString())\(exprs[0].toString())"
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
            return "(\(base.toString()))^\(exp)"
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
        case .negate(let expr):
            return indent + jointSym + "NEG"
            + "\n" + expr.prettyTree(indent: newIndent, last: true)
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
            return indent + jointSym + "^\(exp)"
            + "\n" + base.prettyTree(indent: newIndent, last: true)
        case .fn(let fn, let expr):
            return indent + jointSym + fn.name
            + "\n" + expr.prettyTree(indent: newIndent, last: true)
        }
    }
}

fileprivate func constToString(_ const: Decimal) -> String {
    if const == pi {
        return "π"
    } else if const == e {
        return "e"
    } else {
        return "\(const)"
    }
}
