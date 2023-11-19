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

extension IntroductionViewController {
    final class NaviContainer: UIView {
        var openTOS: Callback?
        
        private let duration = IntroductionCommons.standardAnimationTiming / 2.0
        private let tocButton = TermsOfServiceButton()
        private let dots = IntroductionDots()
        
        private var showingTOS = true
        private var pagesNum: Int = 0
        
        private var leadingXDots: NSLayoutConstraint?
        private var centerXDots: NSLayoutConstraint?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func commonInit() {
            addSubview(tocButton)
            tocButton.pinToParent()
            tocButton.addTarget(self, action: #selector(tocAction), for: .touchUpInside)
            
            addSubview(dots, with: [
                dots.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            
            leadingXDots = dots.trailingAnchor.constraint(equalTo: trailingAnchor)
            centerXDots = dots.centerXAnchor.constraint(equalTo: centerXAnchor)
            leadingXDots?.isActive = true
            dots.alpha = 0
        }
        
        func configure(pagesNum: Int) {
            self.pagesNum = pagesNum
        }
        
        func navigateToPage(_ num: Int) {
            guard num > 0 else {
                showTOS()
                return
            }
            showDots(num: num - 1)
        }
        
        private func showTOS() {
            guard !showingTOS else { return }
            
            leadingXDots?.isActive = true
            centerXDots?.isActive = false
            
            dots.setPage(0, animated: false)
            
            UIView.animate(withDuration: duration) {
                self.tocButton.alpha = 1
                self.dots.alpha = 0
                self.layoutIfNeeded()
            }
            
            showingTOS = true
        }
        
        private func showDots(num: Int) {
            dots.setPage(num, animated: true)
            
            guard showingTOS else { return }
            
            leadingXDots?.isActive = false
            centerXDots?.isActive = true
            
            UIView.animate(withDuration: duration) {
                self.tocButton.alpha = 0
                self.dots.alpha = 1
                self.layoutIfNeeded()
            }
            
            showingTOS = false
        }
        
        @objc
        private func tocAction() {
            openTOS?()
        }
        
        override var intrinsicContentSize: CGSize { CGSize(width: 310, height: 52) }
    }
    
    private final class TermsOfServiceButton: UIButton {
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func commonInit() {
            setTitle(T.Introduction.tos, for: .normal)
            setTitleColor(Theme.Colors.Text.subtitle, for: .normal)
            setTitleColor(Theme.Colors.Text.theme, for: .highlighted)
            titleLabel?.font = Theme.Fonts.Text.info
        }
    }
}
