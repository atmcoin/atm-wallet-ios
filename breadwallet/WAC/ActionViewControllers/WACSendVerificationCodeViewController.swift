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
    @IBOutlet weak var amountToWithdrawErrorMessage: UILabel!
    @IBOutlet weak var infoAboutMachineLabel: UILabel!
    @IBOutlet weak var phoneNumberTextView: UITextField!
    @IBOutlet weak var firstNameTextView: UITextField!
    @IBOutlet weak var lastNameTextView: UITextField!
    @IBOutlet weak var getAtmCodeButton: UIButton!

    var messageText: String = ""

    static let defaultMinAmountLimit: Int = 20
    static let defaultMaxAmountLimit: Int = 300
    static let defaultAllowedBills: Int = 20
    
    var minAmountLimit: Int = defaultMinAmountLimit
    var maxAmountLimit: Int = defaultMaxAmountLimit
    var allowedBills: Int = defaultAllowedBills

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAtmCodeButton.isEnabled = false
    }
    
    @IBAction func getverificationCodeAction(_ sender: Any) {
        self.view.endEditing(true)
        do {
            try client?.sendVerificationCode(firstNameTextView.text!, self.lastNameTextView.text!, phoneNumber: self.phoneNumberTextView.text!, email: "", completion: { (response: WacSDK.SendVerificationCodeResponse) in
                self.view.hideAnimated()
                self.actionCallback?.withdraw(amount: self.amountToWithdrawTextView.text!)
                self.actionCallback?.actiondDidComplete(action: .sendVerificationCode)
                self.clearViews()
            })
        }
        catch {}
    }

    public func validatePhoneNumber(phoneView: UITextField) -> Bool {
        let phone:String? = phoneView.text!
        if phone.isNilOrEmpty {
            addMessage(fieldName: "Phone", message: "is required")
            return false
        }

        let validLength = phone!.lengthOfBytes(using: String.Encoding.utf8) == 10
        if !validLength {
            addMessage(fieldName: "Phone", message: "should be 10 digits long")
        }

        let validCharacters = phone!.isNumeric()
        if !validLength {
            addMessage(fieldName: "Phone", message: "should be numbers only")
        }

        return validLength && validCharacters
    }

    public func validateAmount(amountView: UITextField) -> Bool {
        let amount = Int(amountView.text!)
        if amount == nil {
            addMessage(fieldName:"Amount", message: "numeric")
            return false
        }

        let validRange = amount! >= minAmountLimit && amount! <= maxAmountLimit
        if !validRange {
            addMessage(fieldName: "Amount", message: "between \(minAmountLimit) and \(maxAmountLimit)")
        }

        let validMultiple = isMultipleOf(field: amountView.text, multipleOf: allowedBills)
        if !validMultiple {
            addMessage(fieldName:"Amount", message: "multiple of \(allowedBills)")
        }

        return validRange && validMultiple
    }

    private func isMultipleOf(field: String?, multipleOf: Int ) -> Bool {
        // TODO: hard coded to 20 dollar bills, parse the atm

        if field.isNilOrEmpty {
            return false
        }

        let fieldInt:Int? = Int(field!)
        if fieldInt == nil {
            return false
        }

        return fieldInt! % 20 == 0
    }

    private func addMessage(fieldName:String, message: String) {
        var existingFieldName: String = ""
        if messageText.isEmpty {
            messageText.append("\(fieldName) must be ")
            existingFieldName = fieldName
        } else if fieldName == existingFieldName {
            messageText.append("; ")
        } else {
            messageText.append("; \(fieldName) must be ")
            existingFieldName = fieldName
        }
        messageText.append(message)
    }

    public func setAtmInfo(_ atm: WacSDK.AtmMachine) {
        self.setEditLimits(atm: atm)
        self.atmMachineTitleLabel.text = atm.addressDesc!
        self.infoAboutMachineLabel.text = "Min $\(minAmountLimit), Max $\(maxAmountLimit). Multiple of $\(allowedBills) bills"
        self.listenForKeyboard = true
    }

    private func setEditLimits(atm: WacSDK.AtmMachine) {
        var atmMinimum: Int?
        if atm.min.isNilOrEmpty {
            atmMinimum = WACSendVerificationCodeViewController.defaultMinAmountLimit
        } else {
            let atmMinimumDouble:Double? = Double(atm.min!)
            if atmMinimumDouble != nil {
                atmMinimum = Int(atmMinimumDouble!)
            }
            if atmMinimum == nil { atmMinimum = WACSendVerificationCodeViewController.defaultMinAmountLimit }
        }
        self.minAmountLimit = atmMinimum!

        var atmMaximum: Int?
        if atm.max.isNilOrEmpty {
            atmMaximum = WACSendVerificationCodeViewController.defaultMaxAmountLimit
        } else {
            let atmMaximumDouble:Double? = Double(atm.max!)
            if atmMaximumDouble != nil {
                atmMaximum = Int(atmMaximumDouble!)
            }
            if atmMaximum == nil { atmMaximum = WACSendVerificationCodeViewController.defaultMaxAmountLimit }
        }
        self.maxAmountLimit = atmMaximum!

        var atmBills: Int?
        if atm.bills.isNilOrEmpty {
            atmBills = WACSendVerificationCodeViewController.defaultAllowedBills
        } else {
            let atmBillsDouble:Double? = Double(atm.bills!)
            if atmBillsDouble != nil {
                atmBills = Int(atmBillsDouble!)
            }
            if atmBills == nil { atmBills = WACSendVerificationCodeViewController.defaultAllowedBills }
        }
        self.allowedBills = atmBills!
    }

    override public func clearViews() {
        super.clearViews()
        self.amountToWithdrawTextView.text = ""
        self.amountToWithdrawErrorMessage.text = ""
        self.infoAboutMachineLabel.text = ""
        self.phoneNumberTextView.text = ""
        self.firstNameTextView.text = ""
        self.lastNameTextView.text = ""
    }
    
    @IBAction override func textDidChange(_ sender: Any) {
        messageText = ""
        let amountValid = validateAmount(amountView: self.amountToWithdrawTextView)
        let phoneValid = validatePhoneNumber(phoneView: self.phoneNumberTextView)
        if phoneValid && amountValid {
            self.getAtmCodeButton.isEnabled = true
            self.amountToWithdrawErrorMessage.text = ""
        } else {
            self.getAtmCodeButton.isEnabled = false
            self.amountToWithdrawErrorMessage.text = messageText
        }
    }
}
