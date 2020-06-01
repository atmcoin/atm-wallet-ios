// 
//  WACActionViewController.swift
//
//  Created by Giancarlo Pacheco on 5/13/20.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WacSDK

class WACActionViewController: UIViewController {
    
    public var atm: WacSDK.AtmMachine?
    
    public var listenForKeyboard = false
    public var keyboardShown = false
    public var actionCallback: WACActionProtocol?
    
    var closeButton: UIButton!
    var infoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundViews()
        addCloseButton()
        addInfoButton()
    }
    
    func roundViews() {
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
    }
    
    public func showView() {
        self.view.showAnimated()
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector:#selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc public func hideView() {
        self.view.hideAnimated()
        self.view.endEditing(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    public func clearViews() {
    }
    
    public func addCloseButton() {
        closeButton = UIButton.icon(image: #imageLiteral(resourceName: "Close"), accessibilityLabel: "Close")
        self.view.addSubview(closeButton)
        closeButton.constrain([
            closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            closeButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            closeButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        closeButton.addTarget(self, action: #selector(hideView), for: .touchUpInside)
    }
    
    public func addInfoButton() {
        infoButton = UIButton.icon(image:#imageLiteral(resourceName: "Faq"), accessibilityLabel: "Info")
        self.view.addSubview(infoButton)
        infoButton.constrain([
            infoButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            infoButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            infoButton.heightAnchor.constraint(equalToConstant: 40),
            infoButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        closeButton.addTarget(self, action: #selector(hideView), for: .touchUpInside)
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
    
    func textDidChange(_ sender: Any) {
        
    }
}

extension UIViewController {
    
    func showAlert(title: String, message: String, buttonLabel: String = S.Button.ok, cancelButtonLabel: String = S.Button.cancel, completion: @escaping (UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonLabel, style: .default) { (action) in
            completion(action)
        })
//        alertController.addAction(UIAlertAction(title: cancelButtonLabel, style: .cancel) { (action) in
//            completion(action)
//        })
        present(alertController, animated: true, completion: nil)
    }
}
