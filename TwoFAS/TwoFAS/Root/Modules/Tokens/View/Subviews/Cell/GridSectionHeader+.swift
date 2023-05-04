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

extension GridSectionHeader {
    final class CollapseButton: UIView {
        enum State {
            case collapsed
            case expaned
            case invisible
        }
        var userChangedCollapse: Callback?
        
        private var state: State = .invisible
        
        private let collapse: UIButton = {
            let b = UIButton()
            b.setImage(Asset.collapseGroup.image, for: .normal)
            b.imageView?.tintColor = Theme.Colors.inactiveInverted
            return b
        }()
        private let expand: UIButton = {
            let b = UIButton()
            b.setImage(Asset.expandGroup.image, for: .normal)
            b.imageView?.tintColor = Theme.Colors.inactiveInverted
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
            addSubview(collapse)
            collapse.pinToParent()
            collapse.addTarget(self, action: #selector(collapseAction), for: .touchUpInside)
            
            addSubview(expand)
            expand.pinToParent()
            expand.addTarget(self, action: #selector(collapseAction), for: .touchUpInside)
            
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
        
        @objc
        private func collapseAction() {
            userChangedCollapse?()
        }
    }
    
    final class UpDown: UIView {
        static let totalWidth: CGFloat = 70
        private let width: CGFloat = 35
        
        var moveUp: Callback?
        var moveDown: Callback?
        
        private var state: GridSection.Position = .notUsed
        
        private let down: UIButton = {
            let b = UIButton()
            b.setImage(Asset.expandGroup.image, for: .normal)
            b.imageView?.tintColor = Theme.Colors.inactiveInverted
            return b
        }()
        private let up: UIButton = {
            let b = UIButton()
            b.setImage(Asset.collapseGroup.image, for: .normal)
            b.imageView?.tintColor = Theme.Colors.inactiveInverted
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
                up.widthAnchor.constraint(equalToConstant: width),
                up.topAnchor.constraint(equalTo: topAnchor),
                up.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            up.addTarget(self, action: #selector(upAction), for: .touchUpInside)
            
            addSubview(down, with: [
                down.leadingAnchor.constraint(equalTo: up.trailingAnchor),
                down.widthAnchor.constraint(equalToConstant: width),
                down.topAnchor.constraint(equalTo: topAnchor),
                down.bottomAnchor.constraint(equalTo: bottomAnchor),
                down.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
            down.addTarget(self, action: #selector(downAction), for: .touchUpInside)
            
            setState(.notUsed)
        }
        
        func setState(_ state: GridSection.Position) {
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
            font = Theme.Fonts.sectionHeader
            textAlignment = .left
            numberOfLines = 1
            allowsDefaultTighteningForTruncation = true
            minimumScaleFactor = 0.7
            lineBreakMode = .byTruncatingTail
            setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
            textColor = Theme.Colors.inactiveInverted
        }
    }
    
    final class ElementCounter: UIView {
        private let label: UILabel = {
            let label = UILabel()
            label.font = UIFontMetrics(forTextStyle: .caption1)
                .scaledFont(for: .systemFont(ofSize: 12, weight: .medium))
            label.adjustsFontForContentSizeCategory = true
            label.minimumScaleFactor = 0.5
            label.numberOfLines = 1
            label.textAlignment = .center
            label.allowsDefaultTighteningForTruncation = true
            label.adjustsFontSizeToFitWidth = true
            label.lineBreakMode = .byTruncatingTail
            label.textColor = Theme.Colors.Text.subtitle
            label.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
            label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
            label.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
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
            applyRoundedBorder(withBorderColor: ThemeColor.secondarySofter, width: 1)
            let margin = Theme.Metrics.standardMargin
            addSubview(label, with: [
                label.widthAnchor.constraint(equalTo: label.heightAnchor),
                label.topAnchor.constraint(equalTo: topAnchor, constant: margin),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin)
            ])
        }
        
        func setCount(_ count: String) {
            label.text = count
        }
    }
    
    final class MenuButton: UIButton {
        static let buttonSize: CGFloat = 50
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func commonInit() {
            setImage(UIImage(systemName: "ellipsis"), for: .normal)
            imageView?.tintColor = Theme.Colors.Icon.normal
            showsMenuAsPrimaryAction = true
        }
        
        override var intrinsicContentSize: CGSize { CGSize(width: Self.buttonSize, height: Self.buttonSize) }
    }
}
