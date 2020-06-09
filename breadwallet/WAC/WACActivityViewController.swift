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

class WACActivityViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    var transactions: [WACTransaction] {
        get {
            let trans = WACTransactionManager.shared.getTransactions()
            return trans
        }
    }
    @IBOutlet open var tableView: UITableView!
    @IBOutlet open var navigationBar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationBar();
        
        NotificationCenter.default.addObserver(self, selector: #selector(transactionDidUpdate), name: .WACTransactionDidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(transactionDidUpdate), name: .WACTransactionDidRemove, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO table view needs refreshing after any presentation controller dismisses
        tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupNavigationBar() {
        navigationBar.layer.cornerRadius = 8
        navigationBar.clipsToBounds = true
        navigationBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    // MARK: Helpers
    private func setup() {
        self.view.backgroundColor = Theme.tertiaryBackground
        let cellNib = UINib(nibName: "WACActivityTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: kReusableIdentifier)
        tableView.backgroundColor = Theme.tertiaryBackground
        tableView.estimatedRowHeight = 199
        tableView.rowHeight = UITableView.automaticDimension
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var frame = self.tableView.frame
        frame.size = CGSize(width: frame.width, height: self.view.frame.height - self.tableView.frame.origin.y)
        self.tableView.frame = frame
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
    
    @objc func transactionDidUpdate(_ notification: Notification) {
        self.tableView.reloadData()
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
        return WACActivityTableViewCell.heightForTableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = transactions[indexPath.row]

        let withdrawalStatusVC = WACWithdrawalStatusViewController.init(nibName: "WACWithdrawalStatusView", bundle: nil)
        withdrawalStatusVC.transaction = transaction
        self.present(withdrawalStatusVC, animated: true, completion: nil)
    }
}
