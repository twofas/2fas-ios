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

extension TokensSectionHeader {
    final class CollapseButton: UIView {
        enum State {
            case collapsed
            case expaned
            case invisible
        }
        
        private var state: State = .invisible
        
        private let collapse: UIImageView = {
            let config = UIImage.SymbolConfiguration(textStyle: .body)
            let img = UIImageView(image: UIImage(systemName: "chevron.up", withConfiguration: config))
            img.tintColor = Theme.Colors.inactiveInverted
            img.adjustsImageSizeForAccessibilityContentSizeCategory = true
            img.contentMode = .center
            return img
        }()
        private let expand: UIImageView = {
            let config = UIImage.SymbolConfiguration(textStyle: .body)
            let img = UIImageView(image: UIImage(systemName: "chevron.down", withConfiguration: config))
            img.tintColor = Theme.Colors.inactiveInverted
            img.adjustsImageSizeForAccessibilityContentSizeCategory = true
            img.contentMode = .center
            return img
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func commonInit() {
            addSubview(collapse)
            collapse.pinToParent()
            
            addSubview(expand)
            expand.pinToParent()
            
            setState(.invisible)
        }
        
        func setState(_ state: State) {
            switch state {
            case .collapsed:
                expand.isHidden = false
                collapse.isHidden = true
            case .expaned:
                expand.isHidden = true
                collapse.isHidden = false
            case .invisible:
                expand.isHidden = true
                collapse.isHidden = true
            }
            
            self.state = state
        }
        
        var isActive: Bool {
            state != .invisible
        }
    }
    
    final class UpDown: UIView {
        var moveUp: Callback?
        var moveDown: Callback?
        
        private var state: TokensSection.Position = .notUsed
        
        private let down: UIButton = {
            let b = UIButton()
            let config = UIImage.SymbolConfiguration(textStyle: .body)
            b.setImage(UIImage(systemName: "chevron.down", withConfiguration: config), for: .normal)
            b.imageView?.tintColor = Theme.Colors.inactiveInverted
            b.adjustsImageSizeForAccessibilityContentSizeCategory = true
            return b
        }()
        private let up: UIButton = {
            let b = UIButton()
            let config = UIImage.SymbolConfiguration(textStyle: .body)
            b.setImage(UIImage(systemName: "chevron.up", withConfiguration: config), for: .normal)
            b.imageView?.tintColor = Theme.Colors.inactiveInverted
            b.adjustsImageSizeForAccessibilityContentSizeCategory = true
            b.setPreferredSymbolConfiguration(config, forImageIn: .normal)
            return b
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func commonInit() {
            addSubview(up, with: [
                up.leadingAnchor.constraint(equalTo: leadingAnchor),
                up.topAnchor.constraint(equalTo: topAnchor),
                up.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            up.addTarget(self, action: #selector(upAction), for: .touchUpInside)
            
            addSubview(down, with: [
                down.leadingAnchor.constraint(equalTo: up.trailingAnchor, constant: ThemeMetrics.spacing),
                down.topAnchor.constraint(equalTo: topAnchor),
                down.bottomAnchor.constraint(equalTo: bottomAnchor),
                down.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
            down.addTarget(self, action: #selector(downAction), for: .touchUpInside)
            
            up.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
            down.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
            
            setState(.notUsed)
        }
        
        func setState(_ state: TokensSection.Position) {
            self.state = state
            //
            switch state {
            case .middle:
                up.isUserInteractionEnabled = true
                down.isUserInteractionEnabled = true
                up.alpha = 1
                down.alpha = 1
            case .last:
                up.isUserInteractionEnabled = true
                down.isUserInteractionEnabled = false
                up.alpha = 1
                down.alpha = Theme.Alpha.disabledElement
            case .first:
                up.isUserInteractionEnabled = false
                down.isUserInteractionEnabled = true
                up.alpha = Theme.Alpha.disabledElement
                down.alpha = 1
            case .notUsed:
                up.isUserInteractionEnabled = false
                down.isUserInteractionEnabled = false
                up.alpha = 0
                down.alpha = 0
            }
        }
        
        @objc
        private func upAction() {
            moveUp?()
        }
        
        @objc
        private func downAction() {
            moveDown?()
        }
    }
    
    final class StandardLabel: UILabel {
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func commonInit() {
            font = UIFont.preferredFont(forTextStyle: .body)
            textAlignment = .left
            numberOfLines = 1
            allowsDefaultTighteningForTruncation = true
            lineBreakMode = .byTruncatingTail
            setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
            textColor = Theme.Colors.inactiveInverted
            accessibilityTraits = .header
        }
    }
    
    final class ElementCounter: UIView {
        private let label: UILabel = {
            let label = UILabel()
            label.font = UIFontMetrics(forTextStyle: .caption1)
                .scaledFont(for: .systemFont(ofSize: 12, weight: .medium))
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 1
            label.textAlignment = .center
            label.textColor = Theme.Colors.inactiveInverted
            label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func commonInit() {
            let margin = Theme.Metrics.standardMargin / 2.0
            
            addSubview(label, with: [
                widthAnchor.constraint(equalTo: heightAnchor),
                label.topAnchor.constraint(equalTo: topAnchor),
                label.bottomAnchor.constraint(equalTo: bottomAnchor),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin)
            ])
        }
        
        func setCount(_ count: String) {
            label.text = count
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            applyBorder()
        }
        
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            
            guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else { return }

            applyBorder()
        }
        
        private func applyBorder() {
            applyRoundedBorder(withBorderColor: ThemeColor.tableSeparator, width: 1)
        }
    }
    
    final class MenuButton: UIButton {
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func commonInit() {
            let config = UIImage.SymbolConfiguration(textStyle: .body)
            adjustsImageSizeForAccessibilityContentSizeCategory = true
            setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
            imageView?.tintColor = Theme.Colors.Icon.normal
            showsMenuAsPrimaryAction = true
        }
    }
}
