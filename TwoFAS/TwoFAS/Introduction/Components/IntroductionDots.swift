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

import Foundation
import UIKit

final class IntroductionDots: UIView {
    private let width: CGFloat = 42
    private let height: CGFloat = 5
    
    private let dot0 = Dot(frame: .zero)
    private let dot1 = Dot(frame: .zero)
    private let bar = Bar(frame: .zero)
    
    private var dot0Constraint: NSLayoutConstraint?
    private var dot1Constraint: NSLayoutConstraint?
    private var barConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(dot0, with: [
            dot0.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        addSubview(dot1, with: [
            dot1.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        addSubview(bar, with: [
            bar.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        dot0Constraint = dot0.leadingAnchor.constraint(equalTo: leadingAnchor)
        dot1Constraint = dot1.leadingAnchor.constraint(equalTo: leadingAnchor)
        barConstraint = bar.leadingAnchor.constraint(equalTo: leadingAnchor)
        
        NSLayoutConstraint.activate([
            dot0Constraint!, dot1Constraint!, barConstraint!
        ])
        
        page0Layout()
    }
    
    func setPage(_ pageNumber: Int, animated: Bool) {
        let page: () -> Void
        switch pageNumber {
        case 0: page = page0Layout
        case 1: page = page1Layout
        case 2: page = page2Layout
        default: page = page0Layout
        }
        if animated {
            layoutIfNeeded()
            UIView.animate(
                withDuration: IntroductionCommons.shortAnimationTiming,
                delay: 0,
                options: [.curveEaseInOut, .beginFromCurrentState],
                animations: {
                    page()
                    self.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            page()
        }
    }
    
    private func page0Layout() {
        dot0Constraint?.constant = 27
        dot1Constraint?.constant = 37
        barConstraint?.constant = 0
    }
    
    private func page1Layout() {
        dot0Constraint?.constant = 0
        dot1Constraint?.constant = 37
        barConstraint?.constant = 10
    }
    
    private func page2Layout() {
        dot0Constraint?.constant = 0
        dot1Constraint?.constant = 10
        barConstraint?.constant = 20
    }
    
    override var intrinsicContentSize: CGSize { CGSize(width: width, height: height) }
}

private extension IntroductionDots {
    final class Bar: UIView {
        private let width: CGFloat = 22
        private let heigth: CGFloat = 5
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func commonInit() {
            let shape = CAShapeLayer()
            shape.fillColor = Theme.Colors.Fill.theme.cgColor
            let bar = UIBezierPath(
                roundedRect: CGRect(origin: .zero, size: CGSize(width: width, height: heigth)), cornerRadius: 2.5
            )
            shape.path = bar.cgPath
            layer.addSublayer(shape)
        }
        
        override var intrinsicContentSize: CGSize { CGSize(width: width, height: heigth) }
    }
    
    final class Dot: UIView {
        private let dotSize: CGFloat = 5
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func commonInit() {
            let shape = CAShapeLayer()
            shape.fillColor = Theme.Colors.Fill.theme.cgColor
            let circle = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: dotSize, height: dotSize)))
            shape.path = circle.cgPath
            layer.addSublayer(shape)
        }
        
        override var intrinsicContentSize: CGSize { CGSize(width: dotSize, height: dotSize) }
    }
}
