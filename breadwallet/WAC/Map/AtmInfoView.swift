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
    
    private var atm: WacSDK.AtmMachine!
    weak var delegate: AtmInfoViewDelegate?
    
    
    func configureWithAtm(atm: WacSDK.AtmMachine) {
        self.atm = atm
        
        atmIdLabel.text = atm.addressDesc
//        TODO: add labels to show info. Not sure what info to display
    }
    
    // MARK: - Hit test. We need to override this to detect hits in our custom callout.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Check if it hit our annotation detail view components.
        return self
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("callout touches ended")
        // TODO: navigate to request code view
        delegate?.detailsRequestedForAtm(atm: self.atm)
    }
}
