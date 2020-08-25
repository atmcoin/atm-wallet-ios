//
//  Created by Giancarlo Pacheco on 5/18/20.
//

import UIKit

class WACTextField: UITextField {
    private var ratio: Float = 70
    public var floatingLabelReductionRatio: Float {
        set {
            ratio = newValue
            floatingLabelFont = defaultLabelFont()
            floatingLabel.font = floatingLabelFont
        }
        get {
            return ratio
        }
    }
    
    private var errorRatio: Float = 60
    public var errorLabelReductionRatio: Float {
        set {
            errorRatio = newValue
            errorLabelFont = defaultErrorLabelFont()
            errorLabel.font = errorLabelFont
        }
        get {
            return errorRatio
        }
    }
    
    private var flFont: UIFont?
    public var floatingLabelFont: UIFont? {
        set {
            flFont = newValue
            floatingLabel.font = (floatingLabelFont != nil) ? floatingLabelFont : defaultLabelFont()
            self.invalidateIntrinsicContentSize()
        }
        get {
            return flFont
        }
    }
    private var elFont: UIFont?
    public var errorLabelFont: UIFont? {
        set {
            elFont = newValue
            errorLabel.font = (errorLabelFont != nil) ? errorLabelFont : defaultLabelFont()
            self.invalidateIntrinsicContentSize()
        }
        get {
            return elFont
        }
    }
    
    public var floatingLabelTextColor: UIColor {
        set {
            self.floatingLabel.textColor = newValue
        }
        get {
            self.floatingLabel.textColor
        }
    }
    
    private var floatingLabelShowAnimationDuration = 0.3
    private var floatingLabelHideAnimationDuration = 0.2
    private var floatingLabelXPadding: CGFloat = 0
    private var floatingLabelYPadding: CGFloat {
        return (-floatingLabel.bounds.height / 2) - 5
    }
    public var floatingLabel: UILabel = UILabel()
    public var errorLabel: UILabel = UILabel()
    
    private var errorLabelYPadding: CGFloat {
        return (errorLabel.bounds.height / 2) + 5
    }
    
    public var errorText: String?
    public var isValid: Bool {
        return errorText.isNilOrEmpty
    }
    
    public var floatingLabelActiveTextColor: UIColor?

    required override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        floatingLabel = UILabel()
        floatingLabel.alpha = 0.0
        self.addSubview(floatingLabel)
        
        // some basic default fonts/colors
        floatingLabelFont = defaultLabelFont()
        floatingLabel.font = floatingLabelFont
        floatingLabelTextColor = UIColor.gray
        setFloatingLabelText(self.placeholder!)
        floatingLabelActiveTextColor = .blue
        
        errorLabel = UILabel()
        errorLabel.alpha = 0.0
        self.addSubview(errorLabel)
        
        errorLabelFont = defaultErrorLabelFont()
        errorLabel.font = errorLabelFont
        errorLabel.textColor = .red
    }

    private func defaultLabelFont() -> UIFont {
        var textFieldFont: UIFont?
        
        if textFieldFont == nil && self.attributedPlaceholder != nil && self.attributedPlaceholder!.length > 0 {
            textFieldFont = self.attributedPlaceholder!.attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil) as? UIFont
        }
        if textFieldFont == nil && self.attributedText != nil && self.attributedText!.length > 0 {
            textFieldFont = self.attributedText?.attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil) as? UIFont
        }
        if textFieldFont == nil {
            textFieldFont = self.font
        }
        
        let value = roundf(Float(textFieldFont!.pointSize) * Float((floatingLabelReductionRatio/100)))
        return textFieldFont!.withSize(CGFloat(value))
    }
    
    private func defaultErrorLabelFont() -> UIFont {
        var textFieldFont: UIFont?
        
        if textFieldFont == nil && self.attributedPlaceholder != nil && self.attributedPlaceholder!.length > 0 {
            textFieldFont = self.attributedPlaceholder!.attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil) as? UIFont
        }
        if textFieldFont == nil && self.attributedText != nil && self.attributedText!.length > 0 {
            textFieldFont = self.attributedText?.attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil) as? UIFont
        }
        if textFieldFont == nil {
            textFieldFont = self.font
        }
        
        let value = roundf(Float(textFieldFont!.pointSize) * Float((errorLabelReductionRatio/100)))
        return textFieldFont!.withSize(CGFloat(value))
    }

    private func updateDefaultFloatingLabelFont() {
        let derivedFont = defaultLabelFont()
        floatingLabelFont = derivedFont
    }

    private func labelActiveColor() -> UIColor {
        if let color = floatingLabelActiveTextColor {
            return color
        } else if self.responds(to: #selector(getter: self.tintColor)) {
            return self.tintColor
        }
        return UIColor.blue
    }

    private func showFloatingLabel(_ animated: Bool) {
        let showBlock:() -> Void = { () in
            self.floatingLabel.alpha = 1.0
            self.floatingLabel.frame = CGRect.init(x: self.floatingLabel.frame.origin.x,
                                                   y: self.floatingLabelYPadding,
                                                   width: self.floatingLabel.frame.size.width,
                                                   height: self.floatingLabel.frame.size.height)
        }

        if animated {
            UIView.animate(withDuration: floatingLabelShowAnimationDuration,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: showBlock,
                           completion: nil)
        } else {
            showBlock()
        }
    }

    private func hideFloatingLabel(_ animated: Bool) {
        let hideBlock:() -> Void = { () in
            if self.text!.count == 0 {
                self.floatingLabel.alpha = 0.0
            }
        }
        
        if animated {
            UIView.animate(withDuration: floatingLabelHideAnimationDuration,
                           delay: 0,
                           options: .curveEaseIn,
                           animations: hideBlock,
                           completion: { complete in
                            if !complete { return }
                            self.floatingLabel.frame = CGRect.init(x: self.floatingLabel.frame.origin.x,
                                                                   y: self.floatingLabel.font.lineHeight,
                                                                   width: self.floatingLabel.frame.size.width,
                                                                   height: self.floatingLabel.frame.size.height)
            })
        } else {
            hideBlock()
        }
    }
    
    private func showErrorLabel(_ animated: Bool) {
        let showBlock:() -> Void = { () in
            self.errorLabel.alpha = 1.0
        }

        if animated {
            UIView.animate(withDuration: floatingLabelShowAnimationDuration,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: showBlock,
                           completion: nil)
        } else {
            showBlock()
        }
    }

    private func hideErrorLabel(_ animated: Bool) {
        let hideBlock:() -> Void = { () in
            if self.text!.count == 0 {
                self.errorLabel.alpha = 0.0
            }
        }
        
        if animated {
            UIView.animate(withDuration: floatingLabelHideAnimationDuration,
                           delay: 0,
                           options: .curveEaseIn,
                           animations: hideBlock,
                           completion: { complete in
                            if !complete { return }
            })
        } else {
            hideBlock()
        }
    }

    private func setFloatingLabelText(_ text: String?) {
        floatingLabel.text = text
        setNeedsLayout()
    }

    // PRAGMA: UITextField

    override var font: UIFont? {
        set {
            super.font = newValue
            updateDefaultFloatingLabelFont()
        }
        get {
            super.font
        }
    }

    override var attributedText: NSAttributedString? {
        set {
            super.attributedText = newValue
            updateDefaultFloatingLabelFont()
        }
        get {
            return super.attributedText
        }
    }

    override var placeholder: String? {
        set {
            super.placeholder = newValue
            setFloatingLabelText(newValue)
        }
        get {
            super.placeholder
        }
    }

    override var attributedPlaceholder: NSAttributedString? {
        set {
            super.attributedPlaceholder = newValue
            setFloatingLabelText(attributedPlaceholder?.string)
            updateDefaultFloatingLabelFont()
        }
        get {
            return super.attributedPlaceholder
        }
    }
    
    // Change color
    override func resignFirstResponder() -> Bool {
        floatingLabelTextColor = .black
        return super.resignFirstResponder()
    }

    // Set the X Origin
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        if self.text!.count > 0 {
            floatingLabelXPadding = rect.origin.x
            floatingLabel.layoutIfNeeded()
        }
        rect.origin.y -= 5
        return rect.integral
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        rect.origin.y -= 5
        return rect.integral
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let floatingLabelSize = floatingLabel.sizeThatFits(floatingLabel.superview!.bounds.size)
        
        floatingLabel.frame = CGRect.init(x: floatingLabelXPadding,
                                          y: floatingLabel.frame.origin.y,
                                          width: floatingLabelSize.width,
                                          height: floatingLabelSize.height)
        
        let firstResponder = self.isFirstResponder
        guard let text = self.text else { return }
        
        if firstResponder && text.count > 0 {
            floatingLabelTextColor = labelActiveColor()
        }
        if text.count == 0 {
            hideFloatingLabel(firstResponder)
        } else {
            showFloatingLabel(firstResponder)
        }
        
        guard let errText = self.errorText else { return }
        errorLabel.text = errorText
        let errorLabelLabelSize = errorLabel.sizeThatFits(floatingLabel.superview!.bounds.size)
        
        errorLabel.frame = CGRect.init(x: floatingLabelXPadding,
                                       y: errorLabel.superview!.frame.height - errorLabelLabelSize.height,
                                       width: errorLabelLabelSize.width,
                                       height: errorLabelLabelSize.height)
        
        if errText.count == 0 {
            hideErrorLabel(firstResponder)
        } else {
            showErrorLabel(firstResponder)
        }
    }
}
