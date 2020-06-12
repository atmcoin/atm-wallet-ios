// 
//  AtmInfoView.swift
//
//  Created by Giancarlo Pacheco on 5/12/20.
//

import UIKit
import WacSDK

protocol AtmInfoViewDelegate: class {
    func detailsRequestedForAtm(atm: WacSDK.AtmMachine)
}

class AtmInfoView: UIView {
    
    @IBOutlet weak var atmIdLabel: UILabel!
    @IBOutlet weak var atmPurchaseOnlyLabel: UILabel!
    
    private var atm: WacSDK.AtmMachine!
    weak var delegate: AtmInfoViewDelegate?
    
    
    func configureWithAtm(atm: WacSDK.AtmMachine) {
        self.atm = atm
        
        self.atmPurchaseOnlyLabel.isHidden = atm.redemption!.boolValue
        atmIdLabel.text = getDetails(atm:atm)
    }

    private func getDetails(atm : AtmMachine) -> String {

        //        TODO: show additional data possibly labelled

        if atm.addressDesc.isNilOrEmpty {
            return ""
        } else if atm.city.isNilOrEmpty {
            return atm.addressDesc!
        } else if atm.addressDesc!.contains(atm.city!) {
            return atm.addressDesc!
        } else {
            return atm.addressDesc! + " " + atm.city!
        }
    }
    
    // MARK: - Hit test. We need to override this to detect hits in our custom callout.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Check if it hit our annotation detail view components.
        if (self.bounds.contains(point) && atm.redemption!.boolValue) {
            return self
        }
        return nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.detailsRequestedForAtm(atm: self.atm)
    }
}
