//
//  WACListViewController.swift
//
//  Created by Giancarlo Pacheco on 5/14/20.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WacSDK

class WACListViewController: UIViewController {

    private var _atmList: [AtmMachine]?
    public var atmList: [AtmMachine]? {
        get {
            return _atmList
        }
        set {
            _atmList = newValue
            filteredList = newValue
            // refresh tableview
            self.tableView?.reloadData()
        }
    }
    
    private var filteredList: [AtmMachine]?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(containerViewTapped))
//        tableView.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.backgroundColor = .clear
        addConstraints()
//        self.tableView?.reloadData()
    }
    
    func addConstraints() {
        let parent = self.parent as! WACAtmLocationsViewController
        tableView.constrain([
            tableView.topAnchor.constraint(equalTo: parent.containerView.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0)
        ])

    }
    
    @objc public func containerViewTapped(_ sender: Any) {
        view.endEditing(true)
        let parent = self.parent as! WACAtmLocationsViewController
        parent.searchBar.resignFirstResponder()
    }
    
    func doSearch(search: String) {
        filteredList = atmList?.filter { (atm: AtmMachine) -> Bool in
            return (atm.addressDesc?.lowercased().contains(search.lowercased()))!
        }
        if (search.isEmpty) {
            filteredList = atmList
        }
        
        tableView?.reloadData()
    }
}

class WACListViewTableViewCell: UITableViewCell {
    
}

extension WACListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "tableViewReuseidentifier")
        let atm = self.filteredList![indexPath.row] as AtmMachine
        cell.textLabel!.text = atm.addressDesc
        if atm.redemption!.boolValue {
            cell.textLabel?.textColor = .black  // black text for atms supporting redemption
        } else {
            cell.textLabel?.textColor = .gray   // grey text for atms not supporting redemption
        }
        cell.detailTextLabel!.text = atm.city
        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let atm = self.filteredList![indexPath.row] as AtmMachine
        if atm.redemption!.boolValue {
            return indexPath
        } else {
            return nil  // returning nil indicates do not select
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let atm = self.filteredList![indexPath.row] as AtmMachine
        let parent = self.parent as! WACAtmLocationsViewController
        parent.sendVerificationVC?.setAtmInfo(atm)
        parent.sendVerificationVC?.showView()
        parent.searchBar.resignFirstResponder()

        parent.verifyCashCodeVC!.atm = atm
        
        containerViewTapped(tableView)
    }
}

extension WACListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.filteredList {
            return list.count
        }
        return 0
    }
}
