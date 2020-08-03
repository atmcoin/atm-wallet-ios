// 
//  AtmAnnotationView.swift
//
//  Created by Giancarlo Pacheco on 5/12/20.
//

import MapKit

private let kAtmAnimationTime = 0.300

class AtmAnnotationView: MKAnnotationView {
    
    weak var atmMarkerAnnotationViewDelegate: AtmInfoViewDelegate?
    weak var customCalloutView: AtmInfoView?
    override var annotation: MKAnnotation? {
        willSet { customCalloutView?.removeFromSuperview() }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canShowCallout = false // This is important: Don't show default callout.
    }
    
    // MARK: - callout showing and hiding
    // Important: the selected state of the annotation view controls when the
    // view must be shown or not. We should show it when selected and hide it
    // when de-selected.
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.customCalloutView?.removeFromSuperview() // remove old custom callout (if any)
            
            if let newCustomCalloutView = loadAtmInfoView() {
                // fix location from top-left to its right place.
                newCustomCalloutView.frame.origin.x -= newCustomCalloutView.frame.width / 2.0 - (self.frame.width / 2.0)
                newCustomCalloutView.frame.origin.y -= newCustomCalloutView.frame.height
                newCustomCalloutView.layer.cornerRadius = 5
                
                // set custom callout view
                self.addSubview(newCustomCalloutView)
                self.customCalloutView = newCustomCalloutView
                
                // animate presentation
                if animated {
                    self.customCalloutView!.alpha = 0.0
                    UIView.animate(withDuration: kAtmAnimationTime, animations: {
                        self.customCalloutView!.alpha = 1.0
                    })
                }
            }
        } else {
            if customCalloutView != nil {
                if animated { // fade out animation, then remove it.
                    UIView.animate(withDuration: kAtmAnimationTime, animations: {
                        self.customCalloutView!.alpha = 0.0
                    }, completion: { ( _ /*success*/ ) in
                        self.customCalloutView?.removeFromSuperview()
                    })
                } else { self.customCalloutView!.removeFromSuperview() } // just remove it.
            }
        }
    }
    
    func loadAtmInfoView() -> AtmInfoView? {
        if let views = Bundle.main.loadNibNamed("AtmInfoView", owner: self, options: nil) as? [AtmInfoView], !views.isEmpty {
            let atmInfoView = views.first!
            atmInfoView.delegate = self.atmMarkerAnnotationViewDelegate
            if let atmAnnotation = annotation as? AtmAnnotation {
                let atm = atmAnnotation.atm
                atmInfoView.configureWithAtm(atm: atm)
            }
            return atmInfoView
        }
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.customCalloutView?.removeFromSuperview()
    }
    
    // MARK: - Detecting and reaction to taps on custom callout.
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if super passed hit test, return the result
        if let parentHitView = super.hitTest(point, with: event) {
            return parentHitView

        } else { // test in our custom callout.
            if customCalloutView != nil {
                return customCalloutView!.hitTest(convert(point, to: customCalloutView!), with: event)
            } else {
                return nil
            }
        }
    }
}
