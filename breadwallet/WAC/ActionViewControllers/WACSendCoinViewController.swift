// 
//  WACSendCoinViewController.swift
//
//  Created by Giancarlo Pacheco on 5/13/20.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WacSDK

class WACSendCoinViewController: WACActionViewController {
    
    private var _pCode: String?
    public var pCode: String? {
        get {
            return _pCode
        }
        set {
            _pCode = newValue
            self.pCodeTextField.text = newValue
        }
    }
    private var _amount: String?
    public var amount: String? {
        get {
            return _amount
        }
        set {
            _amount = newValue
            self.amountTextField.text = newValue
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pCodeTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func checkCodeStatus(_ sender: Any) {
        client?.checkCashCodeStatus(pCode!, completion: { (response: WacSDK.CashCodeStatusResponse) in
            if (response.result == "error") {
                let message = response.error?.message
                self.showAlert(title: "Error", message: message!)
            }
            else {
                self.showAlert(title: "Result", message: response.result)
            }
            self.actionCallback?.actiondDidComplete(action: .pCodeVerification)
            self.clearViews()
        })
    }
    
    func sendCoin(amount: String, address: String) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let applicationController = delegate.applicationController
        let modalPresenter = applicationController.modalPresenter
        
        let currencyId = Currencies.btc.uid
        modalPresenter!.presentModal(for: currencyId, amount: amount, address: address)
    }
    
    override func clearViews() {
        self.pCodeTextField.text = ""
        self.amountTextField.text = ""
    }
}
