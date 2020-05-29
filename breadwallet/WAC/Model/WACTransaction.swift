
import Foundation
import WacSDK

enum WACTransactionStatus: String, Codable {
    case VerifyPending // Nice to have. Needs user input after getting SMS
    case SendPending // Waiting to be send. Note: Could be send from other wallet
    case Awaiting // Sent.
    case FundedPending // Transaction confirmed but user has not withdrawn
    case FundedClaimed // User already withdrew
}

public struct WACTransaction: CustomStringConvertible, Codable {
    var timestamp: Double
    var status: WACTransactionStatus
    var atm: AtmMachine?
    var code: CashCode?
    var color: String?
    
    public var description: String {
        return "\(timestamp) = \(status.rawValue)"
    }
}
