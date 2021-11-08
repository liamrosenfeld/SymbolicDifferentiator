import Foundation

extension Decimal {
    func pow(exp: Decimal) -> Decimal {
        Decimal(Darwin.pow(self.double, exp.double))
    }
    
    var double: Double {
        Double(truncating: self as NSDecimalNumber)
    }
    
    var int: Int {
        (self as NSDecimalNumber).intValue
    }
}
