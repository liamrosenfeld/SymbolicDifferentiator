import Foundation

public extension Expr {
    //TODO: - order of operations
    static prefix func -(expr: Expr)    -> Expr { .negate(expr) }
    static func +(lhs: Expr, rhs: Expr) -> Expr { .sum([lhs, rhs]) }
    static func -(lhs: Expr, rhs: Expr) -> Expr { .sum([lhs, .negate(rhs)]) }
    static func *(lhs: Expr, rhs: Expr) -> Expr { .product([lhs, rhs]) }
    static func /(lhs: Expr, rhs: Expr) -> Expr { .product([lhs, .power(rhs, -1)]) }
    static func ^(lhs: Expr, rhs: Decimal) -> Expr { .power(lhs, rhs) }
}

extension Expr: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    public init(integerLiteral: Int64) {
        self = .const(Decimal(integerLiteral))
    }
    
    public init(floatLiteral: Double) {
        self = .const(Decimal(floatLiteral))
    }
}
