
import Foundation
import WacSDK

public enum WACTransactionStatus: String, Codable {
    case VerifyPending = "Waiting for user to enter SMS code" // Nice to have.
    case SendPending = "Waiting for transaction to be sent" // Note: Could be send from other wallet. After X time, this transaction may be cancelled it not sent
    case Awaiting = "Transaction Sent"
    case FundedNotConfirmed = "Transaction Processing"
    case Funded = "Transaction Funded" // It could take some time to be confirmed
    case Withdrawn = "Transaction Withdrawn"
    case Cancelled = "Transaction Cancelled"
    
    static func transactionStatus(from status: CodeStatus) -> WACTransactionStatus {
        switch status {
        case .AWAITING:
            return .Awaiting
        case .FUNDED_NOT_CONFIRMED:
            return .FundedNotConfirmed
        case .FUNDED:
            return .Funded
        case .USED:
            return .Withdrawn
        case .CANCELLED:
            return .Cancelled
        }
    }
}

public struct WACTransaction: CustomStringConvertible, Codable {
    var timestamp: Double
    var status: WACTransactionStatus
    var atm: AtmMachine?
    var code: CashCode?
    var color: String {
        get {
            return color(for: status)
        }
    }
    
    init(status: WACTransactionStatus, atm: AtmMachine? = nil, code: CashCode? = nil) {
        self.timestamp = Date().timeIntervalSince1970
        self.status = status
        self.atm = atm
        self.code = code
    }
    
    public var description: String {
        return "\(timestamp) = \(status.rawValue)"
    }
    
    private func color(for status:WACTransactionStatus) -> String {
        switch status {
        case .VerifyPending:
            return "123456"
        case .SendPending:
            return "f29500"
        case .Awaiting:
            return "67C6BB"
        case .FundedNotConfirmed:
            return "ff5193"
        case .Funded:
            return "ff5193"
        case .Withdrawn:
            return "ff5193"
        case .Cancelled:
            return "5e6fa5"
        }
    }
}

class WACTransactionManager {
    
    static let shared = WACTransactionManager()
    
    public var current: WACTransaction?
    
    func store(_ transaction: WACTransaction) {
        do {
            current = transaction
            try UserDefaults.standard.setObject(transaction)
        }
        catch {}
    }
    
    func getTransactions() -> [WACTransaction] {
        do {
            return try UserDefaults.standard.getAllObjects()
        }
        catch {}
        return []
    }
    
    func getTransaction(forCode: String) -> WACTransaction? {
        do {
            let allObjects = try UserDefaults.standard.getAllObjects()
            for transaction in allObjects {
                if (transaction.code?.secureCode == forCode) {
                    return transaction
                }
            }
        }
        catch {}
        return nil
    }
    
    func getTransaction(forAddress: String) -> WACTransaction? {
        do {
            let allObjects = try UserDefaults.standard.getAllObjects()
            for transaction in allObjects {
                if (transaction.code?.address == forAddress) {
                    return transaction
                }
            }
        }
        catch {}
        return nil
    }
    
    func removeTransaction(forCode: String) {
        do {
            var allObjects = try UserDefaults.standard.getAllObjects()
            allObjects = allObjects.filter { $0.code?.secureCode != forCode }
            try UserDefaults.standard.setObjects(allObjects)
        }
        catch {}
    }
    
    func updateTransaction(_ object: WACTransaction) {
        do {
            var allObjects = try UserDefaults.standard.getAllObjects()
            if let idx = allObjects.firstIndex(where: { $0.code?.secureCode == object.code?.secureCode }) {
                allObjects[idx] = object
                try UserDefaults.standard.setObjects(allObjects)
            }
            
        }
        catch{}
    }
    
    func updateTransaction(status: WACTransactionStatus, forCode: String) {
        if var transaction = getTransaction(forCode: forCode) {
            transaction.status = status
            updateTransaction(transaction)
        }
    }
    
    func updateTransaction(status: WACTransactionStatus, forAddress: String) {
        if var transaction = getTransaction(forAddress: forAddress) {
            transaction.status = status
            updateTransaction(transaction)
        }
    }
}
