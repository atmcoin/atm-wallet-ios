// 
//  WACSendVerificationCodeViewController.swift
//  breadwallet
//
//  Created by Giancarlo Pacheco on 5/12/20.
//  Copyright © 2020 Breadwinner AG. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WacSDK

class WACSendVerificationCodeViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var atmMachineTitleLabel: UILabel!
    @IBOutlet weak var amountToWithdrawTextView: UITextField!
    @IBOutlet weak var infoAboutMachineLabel: UILabel!
    @IBOutlet weak var phoneNumberTextView: UITextField!
    @IBOutlet weak var firstNameTextView: UITextField!
    @IBOutlet weak var lastNameTextView: UITextField!
    @IBOutlet weak var getAtmCodeButton: UIButton!
    
    private var client: WAC?
    public var atm: WacSDK.AtmMachine?
    private var listenForKeyboard = false
    private var keyboardShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client = WAC.init()
        self.getAtmCodeButton.isEnabled = false
        
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector:#selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func getverificationCodeAction(_ sender: Any) {
        do {
            try client?.sendVerificationCode(firstNameTextView.text!, self.lastNameTextView.text!, phoneNumber: self.phoneNumberTextView.text!, email: "", completion: { (response: WacSDK.SendVerificationCodeResponse) in
                
            })
        }
        catch {}
    }
    
    func roundViews() {
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
    }
    
    public func showView() {
        self.view.showAnimated()
    }
    
    public func setAtmInfo(_ atm: WacSDK.AtmMachine) {
        self.atmMachineTitleLabel.text = atm.addressDesc!
        self.infoAboutMachineLabel.text = "Min $\(atm.min!), Max $\(atm.max!). Multiple of $\(String(describing: atm.bills!)) bills"
        listenForKeyboard = true
    }

    @objc func adjustForKeyboard(notification: Notification) {
        if !listenForKeyboard {
            return
        }
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardSize = keyboardValue.cgRectValue.size
        var yOrigin: CGFloat = keyboardSize.height

        if notification.name == UIResponder.keyboardWillHideNotification {
            yOrigin = -yOrigin
            keyboardShown = false
        }
        else {
            if keyboardShown {return}
            keyboardShown = true
        }
        
        let userInfo = notification.userInfo
        let duration:TimeInterval = (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIView.KeyframeAnimationOptions = UIView.KeyframeAnimationOptions(rawValue: animationCurveRaw)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: animationCurve, animations: {
            var f = self.view.frame
            f.origin.y -= yOrigin
            self.view.frame = f
        }, completion: nil)
    }
    
    @IBAction func textDidChangeVerificationCode(_ sender: Any) {
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
