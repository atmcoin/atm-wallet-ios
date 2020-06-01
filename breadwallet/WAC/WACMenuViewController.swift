// 
//  WACMenuViewController.swift
//  breadwallet
//
//  Created by Gardner von Holt on 5/29/20.
//  Copyright © 2020 Breadwinner AG. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WacSDK

class WACMenuViewController: UIViewController {

    @IBOutlet weak var labelMainTitle: UILabel!
    @IBOutlet weak var labelInstructions: UILabel!
    @IBOutlet weak var labelExistingCodes: UILabel!
    @IBOutlet weak var tableExistingCodes: UITableView!

    var transactions: [WACTransaction] = []
    var cellHeights: [CGFloat] = []
    private var client: WAC?


    override func viewDidLoad() {
        super.viewDidLoad()
        initWAC()
        setup()
        view.backgroundColor = Theme.primaryBackground
        labelMainTitle.textColor = Theme.primaryText
        labelInstructions.textColor = Theme.primaryText
        labelExistingCodes.textColor = Theme.primaryText
    }

    @IBAction func showMap(_ sender: Any) {
        let vc = WACAtmLocationsViewController(nibName: "WACAtmLocationsView", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func showSearch(_ sender: Any) {
        let vc = WACListViewController(nibName: "WACAtmLocationsView", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        transactions = []
        if transactions.count == 0 {
            labelExistingCodes.text = "No existing Cash Codes found"
        } else {
            labelExistingCodes.text = "or check existing Cash Codes"
        }
    }

    func initWAC() {
        client = WAC.init(url: C.cniWacUrl)
        let listener = self
        client?.createSession(listener)
    }

    private func setup() {
        self.view.backgroundColor = Theme.tertiaryBackground
        let cellNib = UINib(nibName: "WACActivityTableViewCell", bundle: nil)
        tableExistingCodes.register(cellNib, forCellReuseIdentifier: kReusableIdentifier)
        tableExistingCodes.backgroundColor = Theme.tertiaryBackground
        tableExistingCodes.estimatedRowHeight = 179
        tableExistingCodes.rowHeight = UITableView.automaticDimension
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

extension WACMenuViewController : UITableViewDelegate {

}

extension WACMenuViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowCount = transactions.count
        return rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < 1 ||  indexPath.row > transactions.count {
            let tableViewCell = UITableViewCell()
            return tableViewCell
        } else {
            let transaction = transactions[indexPath.row - 1]
            let cell = self.tableExistingCodes.dequeueReusableCell(withIdentifier: kReusableIdentifier, for: indexPath) as! WACActivityTableViewCell
            cell.transaction = transaction
            return cell
        }
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }

    
}

extension WACMenuViewController: SessionCallback {

    func onSessionCreated(_ sessionKey: String) {
        print(sessionKey)
    }

    func onError(_ errorMessage: String?) {
        showAlert(title: "Error", message: errorMessage!)
    }

}
