
import Foundation

extension UserDefaults: Persistable {
    
    enum Keys: String, CaseIterable {
        case Hello
    }
    
    func reset() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }
    
    func setObject<WACTransaction>(_ object: WACTransaction, forKey: String) throws where WACTransaction: Encodable {
        let encoder = JSONEncoder()
        do {
            var allObjects: [WACTransaction] = try getAllObjects(forKey: forKey) as Any as! [WACTransaction]
                allObjects.append(object)
            let data = try encoder.encode(allObjects)
            set(data, forKey: forKey)
        } catch {
            throw PersistableError.unableToEncode
        }
    }
    
    func getAllObjects(forKey: String) throws -> [WACTransaction] {
        guard let data = value(forKey: forKey) as? Data else { return [] }
        let decoder = JSONDecoder()
        do {
            let objects = try decoder.decode([WACTransaction].self, from: data)
            return objects
        } catch {
            throw PersistableError.unableToDecode
        }
    }
}
