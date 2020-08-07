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
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var infoAboutMachineLabel: UILabel!
    @IBOutlet weak var phoneNumberTextView: UITextField!
    @IBOutlet weak var firstNameTextView: UITextField!
    @IBOutlet weak var lastNameTextView: UITextField!
    @IBOutlet weak var getAtmCodeButton: UIButton!

    var validFields: Bool = false
    var messageText: String = ""

    static let defaultMinAmountLimit: Int = 20
    static let defaultMaxAmountLimit: Int = 300
    static let defaultAllowedBills: Int = 20
    
    var minAmountLimit: Int = defaultMinAmountLimit
    var maxAmountLimit: Int = defaultMaxAmountLimit
    var allowedBills: Int = defaultAllowedBills

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAtmCodeButton.isEnabled = true
    }

    override func viewDidAppear(_ animated: Bool) {
        amountToWithdrawTextView.delegate = self
        phoneNumberTextView.delegate = self
    }
    
    @IBAction func getverificationCodeAction(_ sender: Any) {
        validateFields()
        if !validFields { return }
        WACSessionManager.shared.client!.sendVerificationCode(first: firstNameTextView.text!,
                                                              surname: self.lastNameTextView.text!,
                                                              phoneNumber: self.phoneNumberTextView.text!,
                                                              email: "",
                            completion: { (response: WacSDK.SendVerificationCodeResponse) in
            self.actionCallback?.withdraw(amount: self.amountToWithdrawTextView.text!)
            self.actionCallback?.actiondDidComplete(action: .sendVerificationCode)
            self.clearViews()
        })
    }

    private func addMessage(fieldName: String, message: String) {
        var existingFieldName: String = ""
        if messageText.isEmpty {
            messageText.append("\(fieldName) ")
            existingFieldName = fieldName
        } else if fieldName == existingFieldName {
            messageText.append("; ")
        } else {
            messageText.append("\n \(fieldName) ")
            existingFieldName = fieldName
        }
        messageText.append(message)
    }

    public func setAtmInfo(_ atm: WacSDK.AtmMachine) {
//        let transaction = WACTransaction(status: .VerifyPending,
//                                         atm: atm)
//        WACTransactionManager.shared.store(transaction)
        
        self.setEditLimits(atm: atm)
        self.atmMachineTitleLabel.text = atm.addressDesc!
        self.atmMachineTitleLabel.setNeedsDisplay()
        self.infoAboutMachineLabel.text = "Min $\(minAmountLimit), Max $\(maxAmountLimit). Multiple of $\(allowedBills)"
        self.infoAboutMachineLabel.setNeedsDisplay()
        self.listenForKeyboard = true
    }

    override public func clearViews() {
        super.clearViews()
        self.amountToWithdrawTextView.text = ""
        self.errorMessage.text = ""
        self.infoAboutMachineLabel.text = ""
        self.phoneNumberTextView.text = ""
        self.firstNameTextView.text = ""
        self.lastNameTextView.text = ""
        self.view.setNeedsDisplay()
    }

    @IBAction func textFieldEditingDidChange(_ sender: Any) {
        if errorMessage.text != "" {
            errorMessage.text = ""
            errorMessage.setNeedsDisplay()
        }
    }
}

extension WACSendVerificationCodeViewController: UITextFieldDelegate {

    private func textFieldSholdEndEditing(_ sender: Any) {
        validateFields()
    }

}

// MARK: validation
extension WACSendVerificationCodeViewController {
    private func validateFields() {
        messageText = ""
        let amountValid = validateAmount(amountView: self.amountToWithdrawTextView)
        let phoneValid = validatePhoneNumber(phoneView: self.phoneNumberTextView)
        let nameValid = validateNames(firstNameView: self.firstNameTextView, lastNameView: self.lastNameTextView)
        if phoneValid && amountValid {
            self.validFields = true
            self.errorMessage.text = ""
        } else {
            self.validFields = false
            self.errorMessage.text = messageText
        }
        errorMessage.setNeedsDisplay()
    }
    
    public func validatePhoneNumber(phoneView: UITextField) -> Bool {
        let phone: String? = phoneView.text!
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
        if amountView.text.isNilOrEmpty {
            addMessage(fieldName: "Amount", message: "is required")
            return false
        }

        let amount: Int? = Int(amountView.text!)
        if amount == nil {
            addMessage(fieldName:"Amount", message: "should be numeric")
            return false
        }

        let validRange = amount! >= minAmountLimit && amount! <= maxAmountLimit
        if !validRange {
            addMessage(fieldName: "Amount", message: "should be between \(minAmountLimit) and \(maxAmountLimit)")
        }

        let validMultiple = isMultipleOf(amount: amount!, multipleOf: allowedBills)
        if !validMultiple {
            addMessage(fieldName:"Amount", message: "should be a multiple of \(allowedBills) bills")
        }

        return validRange && validMultiple
    }

    private func validateNames(firstNameView: UITextField, lastNameView: UITextField) -> Bool {
        var firstNameValid:Bool = true
        var lastNameValid:Bool = true
        if firstNameTextView.text.isNilOrEmpty {
            addMessage(fieldName:"First Name", message: "should be entered")
            firstNameValid = false
        }
        if lastNameView.text.isNilOrEmpty {
            addMessage(fieldName:"Last Name", message: "should be entered")
            lastNameValid = false
        }
        return firstNameValid && lastNameValid
    }

    private func isMultipleOf(amount: Int, multipleOf: Int ) -> Bool {
        // TODO: support multiple bills
        return amount % multipleOf == 0
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

}
