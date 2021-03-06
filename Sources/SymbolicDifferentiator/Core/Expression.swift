import Foundation

public indirect enum Expr {
    case variable // could take name as associated type to support multiple vars
    case const(Decimal)
    case sum(Multiset<Expr>)
    case product(Multiset<Expr>)
    case power(base: Expr, exp: Expr)
    case fn(FuncDecl, Expr)
}

extension Expr: Hashable { }

public struct FuncDecl {
    let name: String
    let deriv: (Expr) -> Expr
    let eval: (Decimal) -> Decimal
}

extension FuncDecl: Hashable {
    public static func == (lhs: FuncDecl, rhs: FuncDecl) -> Bool {
        lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
