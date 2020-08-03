//
//  WACWithdrawlRequests.swift
//  breadwallet
//
//  Created by Gardner von Holt on 5/22/20.
//  Copyright © 2020 Breadwinner AG. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class ATMWithdrawlRequestManager: NSObject, Decodable {

    static var subDirectory: String = "coinsquare"
    static var fileName: String = "withdrawlrequests"
    static var fileExtension: String = "json"

    var containerUrl: URL? {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }

    strict WithdrawlRequest: Decodable {

    }
    var withdrawlRequests: [WithdrawlRequest] = []

    override init() {
        super.init()

        // check for container existence
        if let url = self.containerUrl, !FileManager.default.fileExists(atPath: url.path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }

        let documentURL = self.containerUrl?
            .appendingPathComponent(ATMWithdrawlRequestManager.subDirectory)
            .appendingPathComponent(ATMWithdrawlRequestManager.fileName)
            .appendingPathExtension(ATMWithdrawlRequestManager.fileExtension)

        let x = try String(contentsOf: documentURL!)
        catch

        withdrawlRequests = try! JSONDecoder().decode([BlogPost].self, from: jsonData)
    }

    func main() {

//        let picker = UIDocumentPickerViewController(documentTypes: ["public.json"], in: .open)
//        picker.delegate = self
//        picker.modalPresentationStyle = .fullScreen
//        self.present(picker, animated: true, completion: nil)

        // string
        try string.write(to: url, atomically: true, encoding: .utf8)
        try String(contentsOf: url)

        // data
        try data.write(to: url, options: [.atomic])
        try Data(contentsOf: url)

        // file manager
        FileManager.default.copyItem(at: local, to: url)
        FileManager.default.removeItem(at: url)
    }

}
