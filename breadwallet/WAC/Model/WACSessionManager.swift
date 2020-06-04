
import Foundation
import WacSDK

class WACSessionManager {
    
    static let shared: WACSessionManager = {
        let instance = WACSessionManager()
        return instance
    }()
    
    public var client: WAC? = nil
    
    public func start() {
        client = WAC.init(url: C.cniWacUrl)
        let listener = WACSessionManager.shared
        WACSessionManager.shared.client!.createSession(listener) {
            
        }
    }
    
    public func cashCodeStatus(for code: String, completion: @escaping (() -> Void)) {
        client?.checkCashCodeStatus(code, completion: { (response: WacSDK.CashCodeStatusResponse) in
            completion()
        })
    }
}

extension WACSessionManager: SessionCallback {

    func onSessionCreated(_ sessionKey: String) {
        NotificationCenter.default.post(name: .WACSessionDidStart, object: nil)
    }

    func onError(_ errorMessage: WacError?) {
        NotificationCenter.default.post(name: .WACSessionDidFail, object: nil)
    }

}

extension Notification.Name {

    static let WACSessionDidStart = Notification.Name(rawValue: "WACSessionDidStart")
    static let WACSessionDidFail = Notification.Name(rawValue: "WACSessionDidFail")
}
