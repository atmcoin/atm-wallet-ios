// 
//  WACAtmLocationsViewController.swift
//
//  Created by Giancarlo Pacheco on 5/14/20.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WacSDK

enum WACActionStrings: String {
    case list = "List"
    case map = "Map"
    case send = "Send"
    case details = "Details"
}

public enum WACAction {
    case sendVerificationCode
    case cashCodeVerification
    case pCodeVerification
}

protocol WACActionProtocol {
    func actiondDidComplete(action: WACAction?)
    func withdraw(amount: String)
    func withdrawal(requested cashCode: WacSDK.CashCode)
    func sendCashCode(_ cashCode: WacSDK.CashCode)
}

class WACAtmLocationsViewController: UIViewController {

    private var client: WAC?
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var containerView: UIView!
    private var rightBarbuttonItem: UIBarButtonItem?
    
    var sendVerificationVC: WACSendVerificationCodeViewController?
    var verifyCashCodeVC: WACVerifyCashCodeViewController?
    var pCodeVC: WACSendCoinViewController?
    
    var currentContainerViewVC: UIViewController?
    
    private lazy var mapVC: WACMapViewController = {
        var viewController = WACMapViewController()
        return viewController
    }()
    
    private lazy var listVC: WACListViewController = {
        var viewController = WACListViewController()
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initWAC()
        setupSearchBar()
        addToggleNavigationItem()
        add(asChildViewController: mapVC)
        
        self.title = "ATM Cash Locations"
        view.backgroundColor = Theme.primaryBackground
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addSendVerificationView()
        addVerifyCashCodeView()
        addPCodeView()
    }
    
    func initWAC() {
        client = WAC.init()
        let listener = self
        client?.createSession(listener)
    }
    
    @objc func toggleTapped() {
        if (rightBarbuttonItem?.title == WACActionStrings.list.rawValue) {
            // Show tableview
            rightBarbuttonItem?.title = WACActionStrings.map.rawValue
            remove(asChildViewController: mapVC)
            add(asChildViewController: listVC)
        }
        else {
            // Show Map
            rightBarbuttonItem?.title = WACActionStrings.list.rawValue
            remove(asChildViewController: listVC)
            add(asChildViewController: mapVC)
        }
    }
    
    func addToggleNavigationItem() {
        rightBarbuttonItem = UIBarButtonItem(title: WACActionStrings.list.rawValue, style: .plain, target: self, action: #selector(toggleTapped))
        self.navigationItem.rightBarButtonItem = rightBarbuttonItem
    }
    
    func setupSearchBar() {
        searchBar.backgroundColor = Theme.tertiaryBackground
        searchBar.layer.cornerRadius = 2.0
        searchBar.textField.textColor = .white
    }
    
    func doSearch(search: String) {
        self.mapVC.doSearch(search: search)
        self.listVC.doSearch(search: search)
    }
    
    func getAtmList() {
        client?.getAtmList(completion: { (response: WacSDK.AtmListResponse) in
            if let items = response.data?.items {
                self.mapVC.atmList = items
                self.listVC.atmList = items
            }
        })
    }
    
    func addSheetView(controller: WACActionViewController) {
        self.addChild(controller)
        self.view.addSubview(controller.view)
        controller.didMove(toParent: self)
        
        controller.client = client
        controller.actionCallback = self

        let height = controller.view.frame.height
        let width  = view.frame.width
        controller.view.frame = CGRect(x: 0, y: self.view.frame.size.height, width: width, height: height)
    }
    
    func addSendVerificationView() {
        sendVerificationVC = WACSendVerificationCodeViewController.init(nibName: "WACSendVerificationView", bundle: nil)
        addSheetView(controller: sendVerificationVC!)
    }
    
    func addVerifyCashCodeView() {
        verifyCashCodeVC = WACVerifyCashCodeViewController.init(nibName: "WACVerifyCashCodeView", bundle: nil)
        addSheetView(controller: verifyCashCodeVC!)
    }
    
    func addPCodeView() {
        pCodeVC = WACSendCoinViewController.init(nibName: "WACSendCoinView", bundle: nil)
        addSheetView(controller: pCodeVC!)
    }
}

extension WACAtmLocationsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        doSearch(search: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.listVC.doSearch(search: searchText)
    }
}

extension WACAtmLocationsViewController: SessionCallback {

    func onSessionCreated(_ sessionKey: String) {
        print(sessionKey)
        getAtmList()
    }

    func onError(_ errorMessage: String?) {
        showAlert(title: "Error", message: errorMessage!)
    }

}

extension WACAtmLocationsViewController: WACActionProtocol {
    func sendCashCode(_ cashCode: CashCode) {
        self.pCodeVC?.amount = cashCode.btcAmount
        self.pCodeVC?.pCode = cashCode.secureCode
        self.pCodeVC?.showView()
    }
    
    func withdrawal(requested cashCode: CashCode) {
        showAlert(title: "Withdrawal Requested", message: "Please send the amount of \(String(describing: cashCode.btcAmount!)) BTC to the ATM", buttonLabel: WACActionStrings.send.rawValue, cancelButtonLabel: WACActionStrings.details.rawValue, completion: { (action) in
            if (action.title == WACActionStrings.send.rawValue) {
                self.sendCashCode(cashCode)
            }
            else {
                print("Show Details view")
            }
        })
    }
    
    func withdraw(amount: String) {
        self.verifyCashCodeVC!.amount = amount
    }
    
    func actiondDidComplete(action: WACAction?) {
        switch action {
        case .sendVerificationCode:
            self.sendVerificationVC!.view.endEditing(true)
            self.sendVerificationVC!.hideView()
            self.verifyCashCodeVC!.showView()
            break
        case .cashCodeVerification:
            self.verifyCashCodeVC!.view.endEditing(true)
            self.verifyCashCodeVC!.hideView()
            break
        case .pCodeVerification:
            self.pCodeVC!.hideView()
            break
        default:
            break
        }
    }
    
    func add(asChildViewController viewController: UIViewController) {
        currentContainerViewVC = viewController
        addChild(viewController)
        containerView.addSubview(viewController.view)

        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
    func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}

extension UISearchBar {
    public var textField: UITextField {
        if #available(iOS 13.0, *) {
            return searchTextField
        }

        guard let firstSubview = subviews.first else {
            fatalError("Could not find text field")
        }

        for view in firstSubview.subviews {
            if let textView = view as? UITextField {
                return textView
            }
        }

       fatalError("Could not find text field")
    }
}
