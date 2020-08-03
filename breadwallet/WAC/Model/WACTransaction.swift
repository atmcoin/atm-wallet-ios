
import Foundation
import WacSDK

public enum WACTransactionStatus: String, Codable {
    case VerifyPending = "New" // Nice to have.
    case SendPending = "Pending" // Note: Could be send from other wallet. After X time, this transaction may be cancelled if not sent
    case Awaiting = "Transaction Sent"
    case FundedNotConfirmed = "Unconfirmed"
    case Funded = "Funded" // It could take some time to be confirmed
    case Withdrawn = "Used"
    case Cancelled = "Expired"

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

public struct WACTransaction: CustomStringConvertible, Codable, Equatable {
    
    var timestamp: Double
    var status: WACTransactionStatus
    var atm: AtmMachine?
    var code: CashCode?
    var pCode: String?
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
        self.pCode = nil
    }
    
    public var description: String {
        return "\(timestamp) = \(status.rawValue)"
    }

    private func color(for status: WACTransactionStatus) -> String {
        switch status {
        case .VerifyPending: // new statuses are bitcoin with 25 percent alpha
            return "f2a90040"
        case .SendPending: // new statuses are bitcoin with 25 percent alpha
            return "f2a90040"
        case .Awaiting:
            return "67C6BB"
        case .FundedNotConfirmed:
            return "ff519380"
        case .Funded:
            return "85bb65"  // light green money color
        case .Withdrawn:
            return "ff5193"
        case .Cancelled:
            return "5e6fa5"
        }
    }
    
    public static func == (lhs: WACTransaction, rhs: WACTransaction) -> Bool {
        return lhs.timestamp == rhs.timestamp
    }
}
