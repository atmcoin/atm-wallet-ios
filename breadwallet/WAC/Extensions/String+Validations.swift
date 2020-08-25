import Foundation

extension String {
    
    public func validatePhoneNumber() -> String? {
        if self.isEmpty {
            return "Phone is required"
        }
        
        if self.count != 10 {
            return "Phone should be 10 digits long"
        }

        if !self.isNumeric() {
            return "Phone should be numbers only"
        }
        return ""
    }

    public func validateAmount(lowerBound minAmountLimit: Int, upperBound maxAmountLimit: Int, allowedBills: Int) -> String? {
        if self.isEmpty {
            return "Amount is required"
        }

        let amount: Int? = Int(self)
        if amount == nil {
            return "Amount should be numeric"
        }

        let validRange = amount! >= minAmountLimit && amount! <= maxAmountLimit
        if !validRange {
            return "Amount should be between \(String(describing: minAmountLimit)) and \(String(describing: maxAmountLimit))"
        }

        let validMultiple = isMultipleOf(amount: amount!, multipleOf: allowedBills)
        if !validMultiple {
            return "Amount should be a multiple of \(String(describing: allowedBills)) bills"
        }
        return ""
    }

    public func validateName() -> String? {
        if !self.isEmpty {
            return ""
        }
        return "This field is required"
    }

    private func isMultipleOf(amount: Int, multipleOf: Int ) -> Bool {
        return amount % multipleOf == 0
    }
    
    public func isNumeric() -> Bool {
        guard self.count > 0 else { return false }
        return rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
