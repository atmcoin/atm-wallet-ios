// 
//  WACActivityViewController.swift
//
//  Created by Giancarlo Pacheco on 5/22/20.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WacSDK

let kReusableIdentifier = "kTableViewCellReuseIdentifier"

class WACActivityViewController: UIViewController {
    
    private var client: WAC?
    var cellHeights: [CGFloat] = []
    var transactions: [WACTransaction] = []
    @IBOutlet open var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
//        initWAC()
    }
    
    func initWAC() {

        client = WAC.init(url: C.cniWacUrl)
        let listener = self
        client?.createSession(listener)
    }
    
    func getAtmList() {
//        client?.getAtmList(completion: { (response: WacSDK.AtmListResponse) in
//            if let items = response.data?.items {
//                var count = 0
//                var amount = 0.000123
//                var time: Double = Date().timeIntervalSince1970
//                for atm in items {
//                    let t = WACTransaction.init(timestamp: time, status: count < 3 ? .Awaiting : count < 5 ? .FundedPending : .FundedClaimed, atm: atm, fundedCode: count < 3 ? "" : count < 5 ? "98765-6789" : count%50 == 0 ? "CANCELLED" : "", amountUSD: 100, amountBTC: amount, address: "khfadbfkasbfkabskfab", color: count < 3 ? "f29500" : count < 5 ? "67C6BB" : count%50 == 0 ? "ff5193" : "5e6fa5")
//                    self.transactions.append(t)
//                    self.cellHeights.append(199)
//                    count += 1
//                    amount += 0.000001
//                    time -= 100000
//                }
//                self.tableView.reloadData()
//            }
//        })
    }
    
    // MARK: Helpers
    private func setup() {
        self.view.backgroundColor = Theme.tertiaryBackground
        let cellNib = UINib(nibName: "WACActivityTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: kReusableIdentifier)
        tableView.backgroundColor = Theme.tertiaryBackground
        tableView.estimatedRowHeight = 179
        tableView.rowHeight = UITableView.automaticDimension
//        tableView.backgroundColor = UIColor.clear
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        }
    }
    
    @objc func refreshHandler() {
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: { [weak self] in
            if #available(iOS 10.0, *) {
                self?.tableView.refreshControl?.endRefreshing()
            }
            self?.tableView.reloadData()
        })
    }
}

extension WACActivityViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: kReusableIdentifier, for: indexPath) as! WACActivityTableViewCell
        cell.transaction = self.transactions[indexPath.row]
        return cell
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let _ = tableView.cellForRow(at: indexPath)

        let duration = 0.5
        cellHeights[indexPath.row] = 489

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
}

extension WACActivityViewController: SessionCallback {

    func onSessionCreated(_ sessionKey: String) {
        print(sessionKey)
        getAtmList()
    }

    func onError(_ errorMessage: String?) {
        showAlert(title: "Error", message: errorMessage!)
    }

}
