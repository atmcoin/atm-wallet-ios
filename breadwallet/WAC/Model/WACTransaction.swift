
import Foundation
import WacSDK

enum WACTransactionStatus: String, Codable {
    case VerifyPending
    case SendPending
    case Awaiting
    case FundedPending
    case FundedClaimed
}

public struct WACTransaction: CustomStringConvertible, Codable {
    var timestamp: Double
    var status: WACTransactionStatus
    var atm: AtmMachine?
    var fundedCode: String?
    var amountUSD: Double?
    var amountBTC: Double?
    var address: String?
    var color: String?
    
    public var description: String {
        return "\(timestamp) = \(status.rawValue)"
    }
}
