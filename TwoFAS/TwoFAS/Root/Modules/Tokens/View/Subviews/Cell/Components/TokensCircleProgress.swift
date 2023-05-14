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
        label.font = UIFontMetrics(forTextStyle: .caption2)
            .scaledFont(for: UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular))
        label.allowsDefaultTighteningForTruncation = true
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.7
        label.textAlignment = .center
        label.isAccessibilityElement = true
        label.accessibilityLabel = T.Voiceover.secondsLeftCounterTitle
        label.accessibilityTraits = .updatesFrequently
        return label
    }()
    private var marked = false
    
    init() {
        super.init(frame: CGRect.zero)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        circle.lineWidth = 1
        setCircleColor(marked: false, animated: false)
        addSubview(circle)
        circle.pinToParent()
        
        addSubview(valueLabel)
        valueLabel.pinToParent(with: .init(top: 0, left: 4, bottom: 0, right: 4))
        
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
    }
    
    private func setCircleColor(marked: Bool, animated: Bool) {
        
        let color = marked ? Theme.Colors.Line.theme : Theme.Colors.Line.primaryLine
        circle.setLineColor(color, animated: animated)
    }
}

