//
//  Created by Giancarlo Pacheco on 5/12/20.
//

import UIKit
import WacSDK

class WACSendVerificationCodeViewController: WACActionViewController {
    
    // IBOutlets
    @IBOutlet weak var atmMachineTitleLabel: UILabel!
    @IBOutlet weak var amountToWithdrawTextField: WACTextField!
    @IBOutlet weak var infoAboutMachineLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: WACTextField!
    @IBOutlet weak var firstNameTextField: WACTextField!
    @IBOutlet weak var lastNameTextField: WACTextField!
    @IBOutlet weak var getAtmCodeButton: UIButton!

    var validFields: Bool {
        return amountToWithdrawTextField.isValid && phoneNumberTextField.isValid && firstNameTextField.isValid && lastNameTextField.isValid
    }

    static let defaultMinAmountLimit = 20
    static let defaultMaxAmountLimit = 300
    static let defaultAllowedBills = 20
    
    var minAmountLimit = defaultMinAmountLimit
    var maxAmountLimit = defaultMaxAmountLimit
    var allowedBills = defaultAllowedBills

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAtmCodeButton.isEnabled = false
    }
    
    @IBAction func getVerificationCodeAction(_ sender: Any) {
        let firstName = firstNameTextField.text!
        let lastName = self.lastNameTextField.text!
        let phoneNumber = self.phoneNumberTextField.text!
        WACSessionManager.shared.client!.sendVerificationCode(first: firstName,
                                                              surname: lastName,
                                                              phoneNumber: phoneNumber,
                                                              email: "",
                            completion: { _ in
            self.actionCallback?.withdraw(amount: self.amountToWithdrawTextField.text!)
            self.actionCallback?.actiondDidComplete(action: .sendVerificationCode)
            self.clearViews()
        })
        
        let user = WACUser(firstName: firstName, lastName: lastName, phone: phoneNumber)
        do {
            try UserDefaults.standard.setUser(user)
        } catch {}
    }
    
    private func populateUserInfo() {
        do {
            let storedUser: WACUser? = try UserDefaults.standard.getUser()
            if let user = storedUser {
                firstNameTextField.text = user.firstName
                lastNameTextField.text = user.lastName
                phoneNumberTextField.text = user.phoneNumber
            }
        } catch {}
    }

    public func setAtmInfo(_ atm: WacSDK.AtmMachine) {
//        let transaction = WACTransaction(status: .VerifyPending,
//                                         atm: atm)
//        WACTransactionManager.shared.store(transaction)
        
        var value = (atm.min! as NSString).integerValue
        minAmountLimit = value > 0 ? value : WACSendVerificationCodeViewController.defaultMinAmountLimit
        value = (atm.max! as NSString).integerValue
        maxAmountLimit = value > 0 ? value : WACSendVerificationCodeViewController.defaultMaxAmountLimit
        value = (atm.bills! as NSString).integerValue
        allowedBills = value > 0 ? value : WACSendVerificationCodeViewController.defaultAllowedBills
        
        self.atmMachineTitleLabel.text = atm.addressDesc!
        self.atmMachineTitleLabel.setNeedsDisplay()
        self.infoAboutMachineLabel.text = "Min $\(String(describing: minAmountLimit)), Max $\(String(describing: maxAmountLimit)). Multiple of $\(String(describing: allowedBills))"
        self.infoAboutMachineLabel.setNeedsDisplay()
        self.listenForKeyboard = true
        
        populateUserInfo()
    }

    override public func clearViews() {
        super.clearViews()
        self.amountToWithdrawTextField.text = ""
        self.infoAboutMachineLabel.text = ""
        self.phoneNumberTextField.text = ""
        self.firstNameTextField.text = ""
        self.lastNameTextField.text = ""
        self.view.setNeedsDisplay()
    }

    @IBAction func textFieldEditingDidChange(_ textField: UITextField) {
        let text = textField.text!
        switch textField {
        case amountToWithdrawTextField:
            if let errorMessage = text.validateAmount(lowerBound: minAmountLimit, upperBound: maxAmountLimit, allowedBills: allowedBills) {
                amountToWithdrawTextField.errorText = errorMessage
            }
        case phoneNumberTextField:
            if let errorMessage = text.validatePhoneNumber() {
                phoneNumberTextField.errorText = errorMessage
            }
        case firstNameTextField:
            if let errorMessage = text.validateName() {
                firstNameTextField.errorText = errorMessage
            }
        case lastNameTextField:
            if let errorMessage = text.validateName() {
                lastNameTextField.errorText = errorMessage
            }
        default: break
        }
        
        if validFields {
            getAtmCodeButton.isEnabled = true
        } else {
            getAtmCodeButton.isEnabled = false
        }
    }
}
