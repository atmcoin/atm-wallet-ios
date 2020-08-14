import Foundation
import WacSDK

class WACTransactionManager {
    
    static let shared: WACTransactionManager = {
        let instance = WACTransactionManager()
        return instance
    }()
    
    private var timer: Timer?
    
    private init() {}
    
    func store(_ transaction: WACTransaction) {
        do {
            try UserDefaults.standard.setObject(transaction)
        } catch {
        }
    }
    
    func getTransactions() -> [WACTransaction] {
        do {
            return try UserDefaults.standard.getAllObjects()
        } catch {
        }
        return []
    }
    
    func getTransaction(forCode: String) -> WACTransaction? {
        do {
            let allObjects = try UserDefaults.standard.getAllObjects()
            for transaction in allObjects {
                if transaction.code?.secureCode == forCode {
                    return transaction
                }
            }
        } catch {
        }
        return nil
    }
    
    func getTransaction(forTimestamp: Double) -> WACTransaction? {
        do {
            let allObjects = try UserDefaults.standard.getAllObjects()
            for transaction in allObjects {
                if transaction.timestamp == forTimestamp {
                    return transaction
                }
            }
        } catch {
        }
        return nil
    }
    
    func getTransaction(forAddress: String) -> WACTransaction? {
        do {
            let allObjects = try UserDefaults.standard.getAllObjects()
            for transaction in allObjects {
                if transaction.code?.address == forAddress {
                    return transaction
                }
            }
        } catch {
        }
        return nil
    }
    
    func removeTransaction(forCode: String) {
        do {
            var allObjects = try UserDefaults.standard.getAllObjects()
            allObjects = allObjects.filter { $0.code?.secureCode != forCode }
            try UserDefaults.standard.setObjects(allObjects)
        } catch {
        }
    }
    
    func removeTransaction(forTimestamp: Double) {
        do {
            var allObjects = try UserDefaults.standard.getAllObjects()
            allObjects = allObjects.filter { $0.timestamp !=  forTimestamp}
            try UserDefaults.standard.setObjects(allObjects)
            NotificationCenter.default.post(name: .WACTransactionDidRemove, object: nil)
        } catch {
        }
    }
    
    func updateTransaction(_ object: WACTransaction) {
        do {
            var allObjects = try UserDefaults.standard.getAllObjects()
            if let idx = allObjects.firstIndex(where: { $0.code?.address == object.code?.address }) {
                allObjects[idx] = object
                try UserDefaults.standard.setObjects(allObjects)
                NotificationCenter.default.post(name: .WACTransactionDidUpdate, object: object)
            }
        } catch {
        }
    }
    
    func updateTransaction(status: WACTransactionStatus, withTimestamp: Double) {
        if var transaction = getTransaction(forTimestamp: withTimestamp) {
            transaction.status = status
            updateTransaction(transaction)
        }
    }
    
    func updateTransaction(status: WACTransactionStatus, forCode: String) {
        if var transaction = getTransaction(forCode: forCode) {
            transaction.status = status
            updateTransaction(transaction)
        }
    }
    
    func updateTransaction(status: WACTransactionStatus, address: String, code: String? = nil, pCode: String? = nil) {
        if var transaction = getTransaction(forAddress: address) {
            transaction.status = status
            if let code = code, !code.isEmpty {
                transaction.code?.secureCode = code
            }
            if let pcode = pCode, !pcode.isEmpty {
                transaction.pCode = pCode
            }
            updateTransaction(transaction)
        }
    }
    
    private func poll(_ transaction: WACTransaction, instance: WACTransactionManager) {
        guard let code = transaction.code?.secureCode, !code.isEmpty else { return }
        
        WACSessionManager.shared.client?.checkCashCodeStatus(code, completion: { (response: WacSDK.CashCodeStatusResponse) in
            let cashCode = (response.data?.items.first)! as CashStatus
            let codeStatus = cashCode.getCodeStatus()!
            let transactionStatus = WACTransactionStatus.transactionStatus(from: codeStatus)
            let pCode = transactionStatus == .Funded ? cashCode.code : nil
            instance.updateTransaction(status: transactionStatus, address: cashCode.address!, pCode: pCode)
            
            NotificationCenter.default.post(name: .WACTransactionDidUpdate, object: transaction)
        })
    }
    
    public class func poll(_ instance: WACTransactionManager) {
        for t in instance.getTransactions() {
            switch t.status {
            case .VerifyPending, .SendPending:
                instance.cancel(t)
            case .Awaiting, .FundedNotConfirmed, .Funded:
                instance.poll(t, instance: instance)
            case  .Withdrawn, .Cancelled:
                print("Don't change")
            }
        }
    }
    
    private func remove(_ transaction: WACTransaction) {
        if Date().timeIntervalSince1970 - transaction.timestamp >= 15*60 {
            removeTransaction(forTimestamp: transaction.timestamp)
        }
    }
    
    private func cancel(_ transaction: WACTransaction) {
        if Date().timeIntervalSince1970 - transaction.timestamp >= 15*60 {
            updateTransaction(status: .Cancelled, withTimestamp: transaction.timestamp)
        }
    }
    
    private func pollTransactionUpdates(for instance: WACTransactionManager) {
        instance.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (_) in
            WACTransactionManager.poll(instance)
        })
    }
}

extension Notification.Name {

    static let WACTransactionDidUpdate = Notification.Name(rawValue: "WACTransactionDidUpdate")
    static let WACTransactionDidRemove = Notification.Name(rawValue: "WACTransactionDidRemove")
}
