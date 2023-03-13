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
}
