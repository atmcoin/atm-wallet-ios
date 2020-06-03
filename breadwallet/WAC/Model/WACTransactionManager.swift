
import Foundation
import WacSDK

class WACTransactionManager {
    
    static let shared: WACTransactionManager = {
        let instance = WACTransactionManager()
        instance.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (timer) in
            for var t in instance.getTransactions() {
                if (t.status == .Awaiting ||
                    t.status == .Funded ||
                    t.status == .FundedNotConfirmed) {
                    WACSessionManager.shared.client?.checkCashCodeStatus((t.code?.secureCode)!, completion: { (response: WacSDK.CashCodeStatusResponse) in
                        let cashCode = (response.data?.items.first)! as CashStatus
                        let codeStatus = cashCode.getCodeStatus()!
                        let transactionStatus = WACTransactionStatus.transactionStatus(from: codeStatus)
                        instance.updateTransaction(status: transactionStatus, forAddress: cashCode.address!)
                        NotificationCenter.default.post(name: .WACTransactionDidUpdate, object: t)
                    })
                }
            }
        })
        return instance
    }()
    
    private var timer: Timer?
    
    private init() {}
    
    func store(_ transaction: WACTransaction) {
        do {
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


extension Notification.Name {

    static let WACTransactionDidUpdate = Notification.Name(rawValue: "WACTransactionDidUpdate")
}
