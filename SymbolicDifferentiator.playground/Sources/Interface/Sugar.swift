import Foundation

postfix operator ′

public extension Expr {
    //FIXME: - ^ has addition precedence
    static prefix func -(expr: Expr)    -> Expr { .product([-1, expr]) }
    static func +(lhs: Expr, rhs: Expr) -> Expr { .sum([lhs, rhs]) }
    static func -(lhs: Expr, rhs: Expr) -> Expr { .sum([lhs, .product([-1, rhs])]) }
    static func *(lhs: Expr, rhs: Expr) -> Expr { .product([lhs, rhs]) }
    static func /(lhs: Expr, rhs: Expr) -> Expr { .product([lhs, .power(rhs, -1)]) }
    static func ^(lhs: Expr, rhs: Decimal) -> Expr { .power(lhs, rhs) }
    
    static postfix func ′(expr: Expr) -> Expr {
        expr.deriv().flattened().simplified()
    }
    
    func callAsFunction(_ val: Decimal) -> Decimal {
        self.evaluate(at: val)
    }
    
}

extension Expr: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    public init(integerLiteral: Int64) {
        self = .const(Decimal(integerLiteral))
    }
    
    public init(floatLiteral: Double) {
        self = .const(Decimal(floatLiteral))
    }
}
