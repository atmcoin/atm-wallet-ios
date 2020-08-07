// 
//  WACSendVerificationCodeViewController.swift
//
//  Created by Giancarlo Pacheco on 5/12/20.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WacSDK

class WACSendVerificationCodeViewController: WACActionViewController {
    
    // IBOutlets
    @IBOutlet weak var atmMachineTitleLabel: UILabel!
    @IBOutlet weak var amountToWithdrawTextView: UITextField!
    @IBOutlet weak var infoAboutMachineLabel: UILabel!
    @IBOutlet weak var phoneNumberTextView: UITextField!
    @IBOutlet weak var firstNameTextView: UITextField!
    @IBOutlet weak var lastNameTextView: UITextField!
    @IBOutlet weak var getAtmCodeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getAtmCodeButton.isEnabled = false
    }
    
    @IBAction func getverificationCodeAction(_ sender: Any) {
        self.view.endEditing(true)
        do {
            try client?.sendVerificationCode(firstNameTextView.text!,
                                             self.lastNameTextView.text!,
                                             phoneNumber: self.phoneNumberTextView.text!,
                                             email: "",
                                             completion: { (response: WacSDK.SendVerificationCodeResponse) in
                self.view.hideAnimated()
                self.actionCallback?.withdraw(amount: self.amountToWithdrawTextView.text!)
                self.actionCallback?.actiondDidComplete(action: .sendVerificationCode)
                self.clearViews()
            })
        }
        catch {}
    }
    
    public func setAtmInfo(_ atm: WacSDK.AtmMachine) {
        self.atmMachineTitleLabel.text = atm.addressDesc!
        self.infoAboutMachineLabel.text = "Min $\(atm.min!), Max $\(atm.max!). Multiple of $\(String(describing: atm.bills!)) bills"
        self.listenForKeyboard = true
    }
    
    override public func clearViews() {
        super.clearViews()
        self.amountToWithdrawTextView.text = ""
        self.infoAboutMachineLabel.text = ""
        self.phoneNumberTextView.text = ""
        self.firstNameTextView.text = ""
        self.lastNameTextView.text = ""
    }
    
    @IBAction override func textDidChange(_ sender: Any) {
        let phone = self.phoneNumberTextView.text
        let amount = self.amountToWithdrawTextView.text
        if (phone != "" && amount != "") {
            self.getAtmCodeButton.isEnabled = true
        }
        else {
            self.getAtmCodeButton.isEnabled = false
        }
    }
}
