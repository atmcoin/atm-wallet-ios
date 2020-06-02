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

class WACMenuViewController: WACActivityViewController {

    @IBOutlet weak var labelMainTitle: UILabel!
    @IBOutlet weak var labelInstructions: UILabel!
    @IBOutlet weak var labelExistingCodes: UILabel!
    @IBOutlet weak var tableExistingCodes: UITableView!

    var cellHeights: [CGFloat] = []

    override func viewDidLoad() {
        super.tableView = self.tableExistingCodes
        super.viewDidLoad()
        view.backgroundColor = Theme.primaryBackground
        labelMainTitle.textColor = Theme.primaryText
        labelInstructions.textColor = Theme.primaryText
        labelExistingCodes.textColor = Theme.primaryText
    }

    @IBAction func showMap(_ sender: Any) {
        let vc = WACAtmLocationsViewController(nibName: "WACAtmLocationsView", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        if transactions.count == 0 {
            labelExistingCodes.text = "No existing Cash Codes found"
        } else {
            labelExistingCodes.text = "or check existing Cash Codes"
        }
    }

}
