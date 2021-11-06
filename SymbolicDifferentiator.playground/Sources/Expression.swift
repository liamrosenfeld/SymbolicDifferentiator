import Foundation

public indirect enum Expr {
    case variable // could take name as associated type to support multiple vars
    case const(Decimal)
    case negate(Expr)
    case sum([Expr])
    case product([Expr])
    case power(Expr, Decimal)
}

extension Expr: Hashable { }
