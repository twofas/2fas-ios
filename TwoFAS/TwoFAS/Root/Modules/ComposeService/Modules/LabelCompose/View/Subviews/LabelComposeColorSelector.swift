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

extension LabelComposeViewController {
    final class ColorSelector: UIView {
        private let stackView: UIStackView = {
            let sv = UIStackView()
            sv.axis = .horizontal
            sv.alignment = .center
            sv.distribution = .equalCentering
            return sv
        }()
        private let scrollView = UIScrollView()
        private var buttons: [ColorPickerButtonWithName] = []
        private var spacing: CGFloat = 0
        private var leading: NSLayoutConstraint?
        private var trailing: NSLayoutConstraint?
        
        var activeColorDidChange: ((TintColor) -> Void)?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func commonInit() {
            addSubview(scrollView, with: [
                scrollView.topAnchor.constraint(equalTo: topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                scrollView.heightAnchor.constraint(equalTo: heightAnchor)
            ])
            
            scrollView.addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            let leading = stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor)
            let trailing = stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor)
            NSLayoutConstraint.activate([
                leading, trailing,
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.Metrics.doubleMargin)
            ])
            self.leading = leading
            self.trailing = trailing
        }
        
        func setSpacing(_ spacing: CGFloat) {
            self.spacing = spacing
            leading?.constant = spacing
            trailing?.constant = -spacing
            stackView.spacing = spacing
        }
        
        func setColorButtons(_ buttons: [ColorPickerButtonWithName]) {
            self.buttons = buttons
            buttons.forEach { b in b.userAction = { [weak self] color in self?.setActiveColor(color) } }
            stackView.addArrangedSubviews(buttons)
        }
        
        func setInitialActiveColor(_ color: TintColor) {
            buttons.forEach { $0.setActive($0.color == color, animated: false) }
            scrollToActive()
        }
        
        func scrollToActive() {
            layoutIfNeeded()
            guard let button = buttons.first(where: { $0.isActive }) else { return }
            let buttonX = button.frame.origin.x + button.frame.size.width
            let scrollViewWidth = scrollView.frame.size.width
            guard buttonX > scrollViewWidth else { return }
            
            scrollView.contentOffset = CGPoint(x: buttonX - scrollViewWidth + 2 * spacing, y: 0)
        }
        
        var selectedColor: TintColor {
            buttons.first(where: { $0.isActive })?.color ?? .lightBlue
        }
        
        private func setActiveColor(_ color: TintColor) {
            buttons.forEach { $0.setActive($0.color == color, animated: true) }
            activeColorDidChange?(color)
        }
    }
}
