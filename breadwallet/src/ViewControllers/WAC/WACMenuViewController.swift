//
//  WACMenuViewController.swift
//  
//
//  Created by Gardner von Holt on 5/5/20.
//

import UIKit

class WACMenuViewController: UIViewController {
    private let message = UILabel.wrapping(font: .customBody(size: 16.0), color: .white)
    private let mapButton = BRDButton(title: S.Button.map, type: .primary)
    private let searchButton = BRDButton(title: S.Button.search, type: .primary)

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        addConstraints()
        setInitialData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func addSubviews() {
        view.addSubview(message)
        view.addSubview(mapButton)
        view.addSubview(searchButton)
    }

    func addConstraints() {
/*
        header.constrainTopCorners(sidePadding: 0, topPadding: 0)
        header.constrain([
            header.constraint(.height, constant: E.isIPhoneX ? 250.0 : 220.0) ])
        illustration.constrain([
            illustration.constraint(.width, constant: 64.0),
            illustration.constraint(.height, constant: 84.0),
            illustration.constraint(.centerX, toView: header, constant: 0.0),
            illustration.constraint(.centerY, toView: header, constant: E.isIPhoneX ? 4.0 : -C.padding[1]) ])
        leftCaption.constrain([
            leftCaption.topAnchor.constraint(equalTo: illustration.bottomAnchor, constant: C.padding[1]),
            leftCaption.trailingAnchor.constraint(equalTo: header.centerXAnchor, constant: -C.padding[2]),
            leftCaption.widthAnchor.constraint(equalToConstant: 80.0)])
        rightCaption.constrain([
            rightCaption.topAnchor.constraint(equalTo: illustration.bottomAnchor, constant: C.padding[1]),
            rightCaption.leadingAnchor.constraint(equalTo: header.centerXAnchor, constant: C.padding[2]),
            rightCaption.widthAnchor.constraint(equalToConstant: 80.0)])
*/
        message.constrainTopCorners(sidePadding: 0, topPadding: 0)
        message.constrain([
            message.constraint(.height, constant: E.isIPhoneX ? 100.0 : 120.0) ])
        message.constrain([
            message.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[1]),
            message.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[1]) ])
        searchButton.constrain([
            searchButton.topAnchor.constraint(equalTo: message.bottomAnchor, constant: C.padding[4]),
//            searchButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -C.padding[16]),
            searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[1]),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[1]),
            searchButton.constraint(.height, constant: C.Sizes.buttonHeight) ])
        mapButton.constrain([
            mapButton.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: C.padding[4]),
//            mapButton.bottomAnchor.constraint(equalTo: searchButton.topAnchor, constant: -C.padding[8]),
            mapButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[1]),
            mapButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[1]),
            mapButton.constraint(.height, constant: C.Sizes.buttonHeight) ])
    }

    func setInitialData() {
        view.backgroundColor = .darkBackground
//        illustration.contentMode = .scaleAspectFill
        message.text = "ATM Map Text"
//        leftCaption.text = S.Import.leftCaption
//        leftCaption.textAlignment = .center
//        rightCaption.text = S.Import.rightCaption
//        rightCaption.textAlignment = .center
//        warning.text = S.Import.importWarning

        // Set up the tap handler for the "Scan Private Key" button.
        mapButton.tap = strongify(self) { myself in
            let map = WACMapViewController()
            myself.parent?.present(map, animated: true, completion: nil)
        }
        // Set up the tap handler for the "Scan Private Key" button.
        searchButton.tap = strongify(self) { myself in
            let search = WACSearchViewController()
            myself.parent?.present(search, animated: true, completion: nil)
        }
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
