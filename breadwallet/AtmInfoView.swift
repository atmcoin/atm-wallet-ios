// 
//  AtmInfoView.swift
//  breadwallet
//
//  Created by Giancarlo Pacheco on 5/12/20.
//  Copyright © 2020 Breadwinner AG. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WacSDK

protocol AtmInfoViewDelegate: class {
    func detailsRequestedForAtm(atm: WacSDK.AtmMachine)
}

class AtmInfoView: UIView {
    
    @IBOutlet weak var atmIdLabel: UILabel!
    
    private var atm: WacSDK.AtmMachine!
    weak var delegate: AtmInfoViewDelegate?
    
    
    func configureWithAtm(atm: WacSDK.AtmMachine) {
        self.atm = atm
        
        atmIdLabel.text = atm.addressDesc
//        TODO: add labels to show info
    }
    
    // MARK: - Hit test. We need to override this to detect hits in our custom callout.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Check if it hit our annotation detail view components.
        
        return self
    }
}
