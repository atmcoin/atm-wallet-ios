
import Foundation

protocol Persistable {
    func setObject<WACTransaction>(_ object: WACTransaction, forKey: String) throws where WACTransaction: Encodable
    func getAllObjects(forKey: String) throws -> [WACTransaction]
}

enum PersistableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}
