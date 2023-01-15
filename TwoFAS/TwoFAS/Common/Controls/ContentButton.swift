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

final class ContentButton: UIButton {
    enum ActiveElement {
        case background
        case border(width: CGFloat?)
        case noBackground
    }
    
    private let backgroundRoleAlphaWithoutText: CGFloat = 0.5
    private let backgroundRoleAlphaWithText: CGFloat = 0.3
    
    private var activeElement: ActiveElement = .noBackground
    private var activeColor = Theme.Colors.Controls.active
    private var normalColor = Theme.Colors.Controls.empty
    private var inactiveColor = Theme.Colors.Controls.inactive
    
    private var title: String?
    
    private var backgroundView: UIView!
    
    init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.clear
        
        backgroundView = .init()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backgroundView)
        backgroundView.pinToParent()
        backgroundView.isUserInteractionEnabled = false
        sendSubviewToBack(backgroundView)
        
        titleLabel?.font = Theme.Fonts.Controls.title
        
        addTarget(self, action: #selector(downAction), for: .touchDown)
        addTarget(self, action: #selector(downAction), for: .touchDragInside)
        addTarget(self, action: #selector(downAction), for: .touchDragEnter)
        addTarget(self, action: #selector(upAction), for: .touchUpInside)
        addTarget(self, action: #selector(upAction), for: .touchUpOutside)
        addTarget(self, action: #selector(upAction), for: .touchDragOutside)
        addTarget(self, action: #selector(upAction), for: .touchCancel)
        
        pointerStyleProvider = { [weak self] button, effect, _ in
            let targetedPreview = UITargetedPreview(view: button)
            let effect: UIPointerEffect
            
            switch self?.activeElement {
                
            case .background: effect = .lift(targetedPreview)
            case .noBackground: effect = .highlight(targetedPreview)
            case .border: effect = .lift(targetedPreview)
            case .none: effect = .lift(targetedPreview)
            }
            
            return UIPointerStyle(effect: effect)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Theme.Metrics.buttonHeight)
    }
    
    func setActiveElement(
        _ activeElement: ActiveElement,
        withNormalColor normalColor: UIColor,
        activeColor: UIColor,
        inactiveColor: UIColor = Theme.Colors.Controls.inactive
    ) {
        
        self.activeElement = activeElement
        
        self.normalColor = normalColor
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        applyColorToActiveElement(normalColor)
        
        switch activeElement {
        case .background:
            backgroundView.applyRoundedCorners(withBackgroundColor: normalColor)
            backgroundView.alpha = 1
            
        case .border(let width):
            backgroundView.applyRoundedBorder(withBorderColor: normalColor, width: width)
            backgroundView.alpha = 1
            
        case .noBackground:
            backgroundView.alpha = 0
        }
    }
    
    func setTitleColor(normal: UIColor, active: UIColor, disabled: UIColor = Theme.Colors.Text.inactive) {
        setTitleColor(normal, for: .normal)
        setTitleColor(active, for: .selected)
        setTitleColor(active, for: .highlighted)
        setTitleColor(active, for: .focused)
        setTitleColor(disabled, for: .disabled)
    }
    
    func setTitle(_ title: String?) {
        setTitle(title, for: .normal)
        self.title = title
    }
    
    func enable() {
        animate(with: normalColor)
        isEnabled = true
    }
    
    func disable() {
        animate(with: inactiveColor)
        isEnabled = false
    }
    
    func makeAsBackgroundElement() {
        isEnabled = false
        isUserInteractionEnabled = false
        
        switch activeElement {
        case .background, .border:
            animate(with: activeColor)
            setTitle(nil, for: .normal)
        case .noBackground:
            alpha = backgroundRoleAlphaWithText
        }
    }
    
    func makeAsNormalElement() {
        isEnabled = true
        isUserInteractionEnabled = true
        alpha = 1
        
        switch activeElement {
        case .background, .border:
            animate(with: normalColor)
            setTitle(title, for: .normal)
        case .noBackground:
            return
        }
    }
    
    private func applyColorToActiveElement(_ color: UIColor) {
        switch activeElement {
        case .background:
            backgroundView.backgroundColor = color
            
        case .border:
            backgroundView.layer.borderColor = color.cgColor
            
        case .noBackground:
            return
        }
    }
    
    @objc
    private func downAction() {
        animate(with: activeColor)
    }
    
    @objc
    private func upAction() {
        animate(with: normalColor)
    }
    
    private func animate(with color: UIColor) {
        quickAnim { [weak self] in
            self?.applyColorToActiveElement(color)
        }
    }
}
