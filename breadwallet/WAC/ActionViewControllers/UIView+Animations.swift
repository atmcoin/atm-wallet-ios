// 
//  UIView+Animations.swift
//
//  Created by Giancarlo Pacheco on 5/13/20.
//

import UIKit

extension UIView {
    func showAnimated() {
        self.frame.origin.y = (self.superview?.frame.size.height)!
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn],
                       animations: {
                        self.frame.origin.y = (self.superview?.frame.size.height)! - self.bounds.height
                        self.layoutIfNeeded()
        }, completion: nil)
        self.isHidden = false
    }
    
    func hideAnimated() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear],
                       animations: {
                        self.frame.origin.y = (self.superview?.frame.size.height)!//self.bounds.height
                        self.layoutIfNeeded()
                        
        },  completion: {(_ completed: Bool) -> Void in
            self.isHidden = true
        })
    }
    
    func close(to yCoordinate: CGFloat) {
        UIView.animate(withDuration: 0.3, animations: {
            let frame = self.frame
            self.frame = CGRect(x: 0, y: yCoordinate, width: frame.width, height: frame.height)
        })
    }
}

