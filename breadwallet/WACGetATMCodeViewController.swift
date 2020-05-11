//
//  WACGetATMCodeViewController.swift
//  test3
//
//  Created by Gardner von Holt on 4/28/20.
//  Copyright © 2020 Gardner von Holt. All rights reserved.
//

import UIKit
import WacSDK

class WACGetATMCodeViewController: UIViewController {

    var client: WAC?
    var clientSessionKey: String?

    private let headingLabel = UILabel()

    private let amountTextField: UITextField = UITextField()
    private let firstNameTextField: UITextField = UITextField()
    private let lastNameTextField: UITextField = UITextField()
    private let phoneTextField: UITextField = UITextField()
    private let atmIdTextField: UILabel = UILabel()

    private let nextButton = BRDButton(title: S.Button.close, type: .primary)

 //   var sessionKey: String

    override func viewDidLoad() {
        super.viewDidLoad()
        initWAC()
        addSubviews()
        setupATMQuery()
        addConstraints()
        initLabels()
        setInitialData()
    }
    
    func initWAC() {
        client = WAC.init()
        let listener = self
        client?.login(listener)
    }

    func addSubviews() {
    }

    func setupATMQuery() {
    }

    func addConstraints() {
    }

    func initLabels() {
        headingLabel.textColor = Theme.primaryText
        headingLabel.font = Theme.h2Title
        headingLabel.text = S.ATMCode.title
        headingLabel.textAlignment = .center
        headingLabel.numberOfLines = 1
        headingLabel.adjustsFontSizeToFitWidth = true
    }

    func setInitialData() {
        nextButton.tap = strongify(self) { myself in
            myself.getATMCode()
            myself.dismiss(animated: true, completion: nil)
        }
    }

    func getATMCode() {
        initWAC()

        client?.createCode(atmIdTextField.text!, amountTextField.text!, codeTextField.text!,
           completion: { (response: CashCodeResponse) in
            if response.result == "ok" {
                let pCodeTextField = response.data?.items?[0].secureCode!

                client?.sendVerificationCode(firstNameTextField.text!, self.lastNameTextField.text!, phoneNumber: self.telephoneTextField.text!,
                                             email: self.emailTextField.text!, completion: { (response: SendCodeResponse) in
                                                if response.result == "error" {
                                                    let message = response.error?.message
                                                    self.showAlert("Error", message: message!)
                                                }
                })
            } else {
                self.showAlert("Error", message: (response.error?.message)!)
            }
        })
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WACGetATMCodeViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        doSearch(search: textField.text!)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        doSearch(search: textField.text!)
        return true
    }
}
}

extension WACGetATMCodeViewController: LoginProtocol {

    func onLogin(_ sessionKey: String) {
        print(sessionKey)
        clientSessionKey = sessionKey
    }

    func onError(_ errorMessage: String?) {
        showAlert("Error", message: errorMessage!)
    }

}
