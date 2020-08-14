// 
//  WACVerifyCashCodeViewController.swift
//
//  Created by Giancarlo Pacheco on 5/13/20.
//  Copyright © 2020 Breadwinner AG. All rights reserved.
//

import UIKit
import WacSDK

class WACVerifyCashCodeViewController: WACActionViewController {
    
    @IBOutlet weak var atmMachineTitleLabel: UILabel!
    @IBOutlet weak var tokenTextView: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    public var amount: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.confirmButton.isEnabled = false
    }
    
    @IBAction func sendCashCode(_ sender: Any) {
        self.view.endEditing(true)
        client?.createCashCode((atm?.atmId)!, amount!, tokenTextView.text!, completion: { (response: CashCodeResponse) in
            if response.result == "error" {
                let message = response.error?.message
                self.showAlert(title: "Error", message: message!)
            }
            self.view.hideAnimated()
            self.actionCallback?.withdrawal(requested: (response.data?.items?[0])!)
            self.actionCallback?.actiondDidComplete(action: .cashCodeVerification)
            self.clearViews()
        })
    }
    
    override public func clearViews() {
        super.clearViews()
        self.tokenTextView.text = ""
    }
    
    override func showView() {
        super.showView()
        self.listenForKeyboard = true
    }
    
    @IBAction override func textDidChange(_ sender: Any) {
        let code = self.tokenTextView.text
        if code != "" {
            self.confirmButton.isEnabled = true
        } else {
            self.confirmButton.isEnabled = false
        }
    }
}
