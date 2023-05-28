//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>
//

import UIKit

final class TokensCircleProgress: UIView {
    private let circle = CircularShape()
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.isAccessibilityElement = true
        label.accessibilityLabel = T.Voiceover.secondsLeftCounterTitle
        label.accessibilityTraits = .updatesFrequently
        label.setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh + 1, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh + 2, for: .horizontal)
        return label
    }()
    private let sizeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.isAccessibilityElement = false
        label.accessibilityTraits = .updatesFrequently
        label.setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh + 1, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh + 2, for: .horizontal)
        label.text = "00"
        label.isHidden = true
        return label
    }()
    private var marked = false
    
    private var cLeading: NSLayoutConstraint?
    private var cTrailing: NSLayoutConstraint?
    private var cTop: NSLayoutConstraint?
    private var cBottom: NSLayoutConstraint?
    
    private let standardLineWidth = 1.0
    private let standardMargin = 8.0
    
    private var kind: TokensCellKind = .normal
    
    init() {
        super.init(frame: CGRect.zero)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        setCircleColor(marked: false, animated: false)
        addSubview(circle)
        circle.translatesAutoresizingMaskIntoConstraints = false
        
        cLeading = circle.leadingAnchor.constraint(equalTo: leadingAnchor)
        cTrailing = circle.trailingAnchor.constraint(equalTo: trailingAnchor)
        cTop = circle.topAnchor.constraint(equalTo: topAnchor)
        cBottom = circle.bottomAnchor.constraint(equalTo: bottomAnchor)

        [cLeading, cTrailing, cTop, cBottom].forEach { $0?.isActive = true }
        
        let edgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        
        addSubview(sizeLabel)
        sizeLabel.pinToParent(with: edgeInsets)
        
        addSubview(valueLabel)
        valueLabel.pinToParent(with: edgeInsets)
                
        backgroundColor = UIColor.clear
        
        isAccessibilityElement = false
        accessibilityElements = [valueLabel]
    }
    
    func setPeriod(_ period: Int) {
        circle.setPeriod(period)
    }
    
    func setProgress(_ progress: Int, animated: Bool) {
        let secondsLeft = "\(progress - 1)"
        
        valueLabel.text = secondsLeft
        valueLabel.accessibilityValue = secondsLeft
        
        circle.setValue(progress, animated: animated)
    }
    
    func mark() {
        guard !marked else { return }
        
        setCircleColor(marked: true, animated: true)
        UIView.animate(withDuration: Theme.Animations.Timing.show) { [weak self] in
            
            self?.valueLabel.textColor = Theme.Colors.Text.theme
        }
        
        marked = true
    }
    
    func unmark() {
        guard marked else { return }
        
        setCircleColor(marked: false, animated: true)
        UIView.animate(withDuration: Theme.Animations.Timing.show) { [weak self] in
            
            self?.valueLabel.textColor = Theme.Colors.Text.main
        }
        
        marked = false
    }
    
    func setClearBackground() {
        circle.setClearBackground()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            setCircleColor(marked: marked, animated: false)
        }
        
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            setLineWidth()
            setMargins()
        }
    }
    
    func setKind(_ kind: TokensCellKind) {
        self.kind = kind
        switch kind {
        case .compact:
            let font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
            valueLabel.font = font
            sizeLabel.font = font
        case .normal:
            let font = UIFontMetrics(forTextStyle: .caption2)
                .scaledFont(for: UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular))
            valueLabel.font = font
            sizeLabel.font = font
        default:
            break
        }
        setLineWidth()
        setMargins()
    }
    
    private func setCircleColor(marked: Bool, animated: Bool) {
        let color = marked ? Theme.Colors.Line.theme : Theme.Colors.Line.primaryLine
        circle.setLineColor(color, animated: animated)
    }
    
    private func setLineWidth() {
        if kind == .normal {
            circle.lineWidth = traitCollection.preferredContentSizeCategory.lineWidth
            return
        }
        circle.lineWidth = standardLineWidth
    }
    
    private func setMargins() {
        let value: CGFloat = {
            if kind == .normal {
                return -traitCollection.preferredContentSizeCategory.margin
            }
            return standardMargin
        }()
        cLeading?.constant = value
        cTrailing?.constant = -value
        cTop?.constant = value
        cBottom?.constant = -value
    }
}

private extension UIContentSizeCategory {
    var lineWidth: CGFloat {
        switch self {
        case UIContentSizeCategory.accessibilityExtraExtraExtraLarge: return 4.0
        case UIContentSizeCategory.accessibilityExtraExtraLarge: return 3.75
        case UIContentSizeCategory.accessibilityExtraLarge: return 3.5
        case UIContentSizeCategory.accessibilityLarge: return 3
        case UIContentSizeCategory.accessibilityMedium: return 2.5
        case UIContentSizeCategory.extraExtraExtraLarge: return 2
        case UIContentSizeCategory.extraExtraLarge: return 1.5
        case UIContentSizeCategory.extraLarge: return 1.25
        case UIContentSizeCategory.large: return 1.0
        case UIContentSizeCategory.medium: return 1.0
        case UIContentSizeCategory.small: return 1.0
        case UIContentSizeCategory.extraSmall: return 1.0
        default: return 1.0
        }
    }
    
    var margin: CGFloat {
        switch self {
        case UIContentSizeCategory.accessibilityExtraExtraExtraLarge: return 12
        case UIContentSizeCategory.accessibilityExtraExtraLarge: return 11.5
        case UIContentSizeCategory.accessibilityExtraLarge: return 11
        case UIContentSizeCategory.accessibilityLarge: return 10.5
        case UIContentSizeCategory.accessibilityMedium: return 10
        case UIContentSizeCategory.extraExtraExtraLarge: return 9.5
        case UIContentSizeCategory.extraExtraLarge: return 9
        case UIContentSizeCategory.extraLarge: return 8.5
        case UIContentSizeCategory.large: return 8.0
        case UIContentSizeCategory.medium: return 8.0
        case UIContentSizeCategory.small: return 8.0
        case UIContentSizeCategory.extraSmall: return 8.0
        default: return 8.0
        }
    }
}
