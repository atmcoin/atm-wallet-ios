//
//  WACSearchViewController.swift
//  test3
//
//  Created by Gardner von Holt on 4/24/20.
//  Copyright © 2020 Gardner von Holt. All rights reserved.
//

import UIKit
import WacSDK

class WACSearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableSearchResults: UITableView!

    var client: WAC?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableSearchResults.delegate = self        // Do any additional setup after loading the view.
        tableSearchResults.dataSource = self
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func initWAC() {
        client = WAC.init()
        let listener = self
        client?.login(listener)
    }

    @IBAction func search(_ sender: Any) {
        tableSearchResults.reloadData()
        tableSearchResults.setNeedsDisplay()
    }
}

extension WACSearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell()
        cell.textLabel!.text = "First Third Bank, Fort Myers, FL"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "getATMCode", sender: self)
    }
}

extension WACSearchViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

extension WACVerifyConfirmationCodeViewController: LoginProtocol {

    func onLogin(_ sessionKey: String) {
        print(sessionKey)
        clientSessionKey = sessionKey
    }

    func onError(_ errorMessage: String?) {
        showAlert("Error", message: errorMessage!)
    }

}
