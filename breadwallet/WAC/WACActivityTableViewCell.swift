// 
//  WACActivityTableViewCell.swift
//
//  Created by Giancarlo Pacheco on 5/22/20.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class WACActivityTableViewCell: UITableViewCell {
    
    private var _transaction: WACTransaction!
    var transaction: WACTransaction! {
        set {
            _transaction = newValue
            populateView(from: _transaction)
        }
        get {
            return _transaction
        }
    }
    
    /// UIView is displayed when cell open
    @IBOutlet open var closedView: UIView!
    @IBOutlet open var closedViewTop: NSLayoutConstraint!
    @IBOutlet open var dateLabel: UILabel!
    @IBOutlet open var timeLabel: UILabel!
    @IBOutlet open var fundedLabel: UILabel!
    @IBOutlet open var rightView: UIView!
    @IBOutlet open var atmMachineNameLabel: UILabel!
    @IBOutlet open var atmMachineAddressLabel: UILabel!
    @IBOutlet open var amountTitleLabel: UILabel!
    @IBOutlet open var amountLabel: UILabel!
    @IBOutlet open var leftView: UIView!
    @IBOutlet open var colorView: UIView!
    
    
    /// UIView whitch display when cell close
    @IBOutlet open var openedView: UIView!
    @IBOutlet open var openedViewTop: NSLayoutConstraint!
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }
    
    @objc open func commonInit() {
        
        selectionStyle = .none
        
        closedView.layer.cornerRadius = 10
//        openedView.layer.cornerRadius = 10
        closedView.layer.masksToBounds = true
//        openedView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    private func populateView(from transaction: WACTransaction) {
        self.atmMachineNameLabel.text = _transaction.atm?.addressDesc
        self.atmMachineAddressLabel.text = ""
        self.amountLabel.text = "\(String(describing: _transaction.amountBTC)) BTC"
        self.fundedLabel.text = _transaction.fundedCode
//        self.leftView.backgroundColor = UIColor.fromHex(_transaction.color)
        self.colorView.backgroundColor = UIColor.fromHex(_transaction.color!)
        self.dateLabel.text = Date().dateString(from: _transaction.timestamp)
        self.timeLabel.text = Date().timeString(from: _transaction.timestamp)
    }
    
}
