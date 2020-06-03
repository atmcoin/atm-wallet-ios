
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
