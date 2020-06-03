
import Foundation

protocol Persistable {
    func setObject<WACTransaction>(_ object: WACTransaction, forKey: String?) throws where WACTransaction: Encodable
    func setObjects(_ objects: [WACTransaction], forKey: String?) throws
    func getMostRecentObject(for key: String?) throws -> WACTransaction?
    func getAllObjects(forKey: String?) throws -> [WACTransaction]
    func reset()
}

enum PersistableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}

extension UserDefaults: Persistable {
    
    enum Keys: String, CaseIterable {
        case Hello
    }
    
    func reset() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }
    
    func setObjects(_ objects: [WACTransaction], forKey: String?  = Keys.Hello.rawValue) throws {
        do {
            let data = try JSONEncoder().encode(objects)
            set(data, forKey: forKey!)
        }
        catch {
            throw PersistableError.unableToEncode
        }
    }
    
    func setObject<WACTransaction>(_ object: WACTransaction, forKey: String? = Keys.Hello.rawValue) throws where WACTransaction: Encodable {
        let encoder = JSONEncoder()
        do {
            var allObjects: [WACTransaction] = try getAllObjects(forKey: forKey) as! [WACTransaction]
            allObjects.append(object)
            let data = try encoder.encode(allObjects)
            set(data, forKey: forKey!)
        } catch {
            throw PersistableError.unableToEncode
        }
    }
    
    func getMostRecentObject(for key: String? = Keys.Hello.rawValue) throws -> WACTransaction? {
        do {
            let allObjects: [WACTransaction] = try getAllObjects(forKey: key!) as Any as! [WACTransaction]
            if allObjects.count == 0 { return nil }
            return allObjects.first! as WACTransaction
        }
        catch {
            throw PersistableError.unableToDecode
        }
    }
    
    func getAllObjects(forKey: String? = Keys.Hello.rawValue) throws -> [WACTransaction] {
        guard let data = value(forKey: forKey!) as? Data else { return [] }
        let decoder = JSONDecoder()
        do {
            let objects = try decoder.decode([WACTransaction].self, from: data)
            return objects
        } catch {
            throw PersistableError.unableToDecode
        }
    }
}
