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
            let img = UIImageView(image: UIImage(icon: .chevronUp, withConfiguration: config))
            img.tintColor = AppColor.labelsSecondary.uiColor
            img.adjustsImageSizeForAccessibilityContentSizeCategory = true
            img.contentMode = .center
            return img
        }()
        private let expand: UIImageView = {
            let config = UIImage.SymbolConfiguration(textStyle: .body)
            let img = UIImageView(image: UIImage(icon: .chevronDown, withConfiguration: config))
            img.tintColor = AppColor.labelsSecondary.uiColor
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
            b.setImage(UIImage(icon: .chevronDown, withConfiguration: config), for: .normal)
            b.imageView?.tintColor = AppColor.labelsSecondary.uiColor
            b.adjustsImageSizeForAccessibilityContentSizeCategory = true
            return b
        }()
        private let up: UIButton = {
            let b = UIButton()
            let config = UIImage.SymbolConfiguration(textStyle: .body)
            b.setImage(UIImage(icon: .chevronUp, withConfiguration: config), for: .normal)
            b.imageView?.tintColor = AppColor.labelsSecondary.uiColor
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
            font = TextStyle.body.uiFont(.medium)
            textAlignment = .left
            numberOfLines = 1
            allowsDefaultTighteningForTruncation = true
            lineBreakMode = .byTruncatingTail
            setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
            textColor = AppColor.labelsSecondary.uiColor
            accessibilityTraits = .header
        }
    }
    
    final class ElementCounter: UIView {
        private let bgView: UIView = {
            let v = UIView()
            v.backgroundColor = AppColor.backgroundsPrimary.uiColor
            v.applyRoundedCorners(
                    withBackgroundColor: AppColor.backgroundsPrimary.uiColor,
                    cornerRadius: TFCornerRadius.small.value
                )
            return v
        }()
        
        private let label: UILabel = {
            let label = UILabel()
            label.font = TextStyle.subheadline.uiFont(.emphasized)
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 1
            label.textAlignment = .center
            label.textColor = AppColor.labelsSecondary.uiColor
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
            addSubview(bgView)
            bgView.pinToParent()
            
            let margin = Spacing.S.rawValue
                        
            addSubview(label, with: [
                widthAnchor.constraint(equalTo: heightAnchor),
                label.topAnchor.constraint(equalTo: topAnchor),
                label.bottomAnchor.constraint(equalTo: bottomAnchor),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin)
            ])
            
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection) in
                guard self.traitCollection.userInterfaceStyle !=
                        previousTraitCollection.userInterfaceStyle else { return }
                
                self.applyBorder()
            }
        }
        
        func setCount(_ count: String) {
            label.text = count
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            applyBorder()
        }
        
        private func applyBorder() {
            applyRoundedBorder(
                withBorderColor: AppColor.bordersPrimary.uiColor,
                width: 1,
                cornerRadius: TFCornerRadius.small.value
            )
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
            setImage(UIImage(icon: .ellipsis, withConfiguration: config), for: .normal)
            imageView?.tintColor = AppColor.labelsSecondary.uiColor
            showsMenuAsPrimaryAction = true
        }
    }
}
