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
import Common

enum LoadingContentButtonState {
    case inactive
    case active
}

final class LoadingContentButton: UIView {
    var titleColor = Theme.Colors.Text.light
    var disabledTitleColor = Theme.Colors.Text.onBackground
    var highlightedTitleColor = Theme.Colors.Text.light
    var highlightedColor = Theme.Colors.Controls.highlighed
    var normalColor = Theme.Colors.Controls.active
    var inactiveColor = Theme.Colors.Controls.inactive
    
    enum Style {
        case background
        case border(width: CGFloat?)
        case noBackground
    }
    
    var action: Callback?
    
    private let buttonWidth = Theme.Metrics.componentWidth
    
    private var button: ContentButton!
    
    private var currentState: LoadingContentButtonState = .active
    private var title: String = ""
    private var style: Style = .background
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    init(style: Style, title: String) {
        super.init(frame: CGRect.zero)
        
        self.style = style
        self.title = title
        
        commonInit()
    }
    
    private func commonInit() {
        button = ContentButton()
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: buttonWidth)
        widthConstraint.priority = .defaultLow - 1
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthConstraint
        ])
        
        button.titleLabel?.allowsDefaultTighteningForTruncation = true
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.minimumScaleFactor = 0.6
        button.titleLabel?.textAlignment = .center
        
        updateStyle()
    }
    
    func configure(_ font: UIFont) {
        button?.titleLabel?.font = font
    }
    
    func configure(style: Style, title: String) {
        self.style = style
        self.title = title
        
        updateStyle()
    }
    
    func update(title: String) {
        self.title = title
        button.setTitle(title)
    }
    
    func updateStyle() {
        button.setActiveElement(
            style.map(),
            withNormalColor: normalColor,
            activeColor: highlightedColor,
            inactiveColor: inactiveColor
        )
        button.setTitleColor(normal: titleColor, active: highlightedTitleColor, disabled: disabledTitleColor)
        button.setTitle(title)
    }
    
    func setState(_ state: LoadingContentButtonState) {
        guard currentState != state else { return }
        
        currentState = state
        
        switch state {
        case .inactive:
            button.makeAsNormalElement()
            button.disable()
        case .active:
            button.makeAsNormalElement()
            button.enable()
        }
    }
    
    @objc
    private func buttonTapped() {
        guard currentState == .active else { return }
        
        action?()
    }
}

private extension LoadingContentButton.Style {
    func map() -> ContentButton.ActiveElement {
        switch self {
        case .background:
            return .background
        case .border(let width):
            return .border(width: width)
        case .noBackground:
            return .noBackground
        }
    }
}
