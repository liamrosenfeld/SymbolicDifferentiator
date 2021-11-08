import Foundation

// MARK: - Constants
public let x: Expr = .variable
public let pi: Decimal = Decimal.pi
public let e: Decimal = 2.7182818284590452353602874713526624977572

// MARK: - Functions
public func sin(_ expr: Expr) -> Expr {
    let fn = FuncDecl(
        name: "sin",
        deriv: { expr in
            cos(expr)
        },
        eval: { val in
            Decimal(sin(val.double))
        }
    )
    return .fn(fn, expr)
}

public func cos(_ expr: Expr) -> Expr {
    let fn = FuncDecl(
        name: "cos",
        deriv: { expr in
            .negate(sin(expr))
        },
        eval: { val in
            Decimal(cos(val.double))
        }
    )
    return .fn(fn, expr)
}

public func log(_ base: Decimal, _ expr: Expr) -> Expr {
    if base == e {
        return ln(expr)
    }
    let fn = FuncDecl(
        name: "log_\(base)",
        deriv: { expr in
            (expr * ln(.const(base))) ^ -1
        },
        eval: { val in
            Decimal(log(val.double) / log(base.double))
        }
    )
    return .fn(fn, expr)
}

public func ln(_ expr: Expr) -> Expr {
    let fn = FuncDecl(
        name: "ln",
        deriv: { expr in
            expr ^ -1
        },
        eval: { val in
            Decimal(log(val.double) / log(e.double))
        }
    )
    return .fn(fn, expr)
}
