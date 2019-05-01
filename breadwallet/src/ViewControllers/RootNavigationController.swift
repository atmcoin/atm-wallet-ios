//
//  RootNavigationController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-12-05.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit
import BRCrypto

class RootNavigationController: UINavigationController {

    private let keyMaster: KeyMaster
    private var tempLoginView = LoginViewController(isPresentedForLock: false)
    private let loginTransitionDelegate = LoginTransitionDelegate()

    init(keyMaster: KeyMaster) {
        self.keyMaster = keyMaster
        super.init(nibName: nil, bundle: nil)
    }

    func promptForLogin(completion: @escaping (Account?) -> Void) {
        DispatchQueue.main.async { //TODO:CRYPTO TESTING
            completion(self.keyMaster.login(withPin: "111111"))
        }
    }

    func showLoginIfNeeded() {
        if !keyMaster.noWallet && Store.state.isLoginRequired {
            let loginView = LoginViewController(isPresentedForLock: false, keyMaster: keyMaster)
            loginView.transitioningDelegate = loginTransitionDelegate
            loginView.modalPresentationStyle = .overFullScreen
            loginView.modalPresentationCapturesStatusBarAppearance = true
            present(loginView, animated: false, completion: {
                self.tempLoginView.remove()
            })
        }
    }

    private func addTempLoginAndStartViews() {
        self.addChildViewController(tempLoginView, layout: {
            tempLoginView.view.constrain(toSuperviewEdges: nil)
        })
        guardProtected(queue: DispatchQueue.main) {
            if self.keyMaster.noWallet {
                self.tempLoginView.remove()
                let tempStartView = StartViewController(didTapCreate: {}, didTapRecover: {})
                self.addChildViewController(tempStartView, layout: {
                    tempStartView.view.constrain(toSuperviewEdges: nil)
                    tempStartView.view.isUserInteractionEnabled = false
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    tempStartView.remove()
                })
            }
        }
    }
    
    override func viewDidLoad() {
        setDarkStyle()
        
        view.backgroundColor = .navigationBackground
        
        // The temp views are not required when we're presenting the onboarding startup flow.
        if !Store.state.shouldShowOnboarding {
            addTempLoginAndStartViews()
        }
        
        self.delegate = self
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RootNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is HomeScreenViewController {
            UserDefaults.selectedCurrencyCode = nil
            navigationBar.tintColor = .navigationTint
        } else if let accountView = viewController as? AccountViewController {
            UserDefaults.selectedCurrencyCode = accountView.currency.code
            //TODO:CRYPTO p2p sync management
//            if accountView.currency is Bitcoin {
//                UserDefaults.mostRecentSelectedCurrencyCode = accountView.currency.code
//            }
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is AccountViewController {
            navigationBar.tintColor = .white
        }
    }
    
}
