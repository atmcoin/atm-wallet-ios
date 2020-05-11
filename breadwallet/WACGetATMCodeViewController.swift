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
    private let telephoneTextField: UITextField = UITextField()
    private let emailTextField: UITextField = UITextField()
    private let codeTextField: UITextField = UITextField()

    private let atmIdTextField: UILabel = UILabel()

    private let sendCoinButton = BRDButton(title: S.Button.close, type: .primary)

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
        client?.createSession(listener)
    }

    func addSubviews() {
    }

    func setupATMQuery() {
        sendCoinButton.tap = strongify(self) { myself in
            myself.sendCoin()
            myself.dismiss(animated: true, completion: nil)
        }
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

    }

    func sendCoint() {
        client?.createCashCode(atmIdTextField.text!, amountTextField.text!, codeTextField.text!,
           completion: { (response: CashCodeResponse) in
            if response.result == "ok" {
                let codeTextField = response.data?.items?[0].secureCode!
            } else {
                self.showAlert(title: "Error", message: (response.error?.message)!)
            }
        })
    }

    func sendCoin() {
        // code to transfer to send coin feature goes here
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

extension WACGetATMCodeViewController: SessionCallback {

    func onSessionCreated(_ sessionKey: String) {
        print(sessionKey)
        clientSessionKey = sessionKey
    }

    func onError(_ errorMessage: String?) {
        showAlert(title: "Error", message: errorMessage!)
    }

}
