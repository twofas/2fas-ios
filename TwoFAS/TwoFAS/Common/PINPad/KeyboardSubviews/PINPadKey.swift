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

final class PINPadKey: UIButton {
    private let emptyCircle: PINPadCircleView
    private let fullCircle: PINPadCircleView
    
    private let digitLabelNormal: UILabel
    private let digitLabelActive: UILabel
    
    private let number: Int
    private let action: (Int) -> Void
    
    init(number: Int, dimension: CGFloat, action: @escaping (Int) -> Void) {
        assert(number >= 0)
        
        let borderWidth = Theme.Metrics.lineWidth / 2.0

        emptyCircle = PINPadCircleView(typeOfCircle: .empty, dimension: dimension, borderWidth: borderWidth)
        fullCircle = PINPadCircleView(typeOfCircle: .full, dimension: dimension, borderWidth: borderWidth)

        digitLabelNormal = UILabel()
        digitLabelActive = UILabel()
        
        self.number = number
        self.action = action
        
        super.init(frame: CGRect.zero)

        let views: [UIView] = [emptyCircle, fullCircle, digitLabelNormal, digitLabelActive]
        UIView.prepareViewsForAutoLayout(withViews: views, superview: self)
        
        digitLabelNormal.font = Theme.Fonts.Controls.PINPad
        digitLabelNormal.textColor = Theme.Colors.Text.main
        digitLabelNormal.text = String(number)
        
        digitLabelActive.font = Theme.Fonts.Controls.PINPad
        digitLabelActive.textColor = Theme.Colors.Text.light
        digitLabelActive.text = String(number)

        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        addTarget(self, action: #selector(touchCancel), for: .touchCancel)
        addTarget(self, action: #selector(touchCancel), for: .touchDragExit)
        addTarget(self, action: #selector(touchCancel), for: .touchDragOutside)
        addTarget(self, action: #selector(touchCancel), for: .touchUpOutside)

        NSLayoutConstraint.activate([
            emptyCircle.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyCircle.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptyCircle.topAnchor.constraint(equalTo: topAnchor),
            emptyCircle.bottomAnchor.constraint(equalTo: bottomAnchor),
            fullCircle.leadingAnchor.constraint(equalTo: leadingAnchor),
            fullCircle.trailingAnchor.constraint(equalTo: trailingAnchor),
            fullCircle.topAnchor.constraint(equalTo: topAnchor),
            fullCircle.bottomAnchor.constraint(equalTo: bottomAnchor),
            digitLabelNormal.centerXAnchor.constraint(equalTo: centerXAnchor),
            digitLabelNormal.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1),
            digitLabelActive.centerXAnchor.constraint(equalTo: centerXAnchor),
            digitLabelActive.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1)
        ])
        
        fullCircle.alpha = 0
        digitLabelActive.alpha = 0
        accessibilityLabel = String(number)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else { return }
        let hitView = hitTest(touch.location(in: self), with: nil)
        
        if !(hitView is PINPadKey) {
            
            normal()
        }
    }
    
    func cancelIfActive() {
        normal()
    }
    
    @objc private func touchDown() {
        over()
    }
    
    @objc private func touchUp() {
        normal()
    }
    
    @objc private func touchCancel() {
        normal()
    }
    
    private func over() {
        UIView.animate(
            withDuration: Theme.Animations.Timing.show,
            delay: 0,
            options: [.beginFromCurrentState, Theme.Animations.Curve.show],
            animations: {
            self.fullCircle.alpha = 1
            self.digitLabelActive.alpha = 1
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.action(self.number)
        })
    }
    
    private func normal() {
        UIView.animate(
            withDuration: Theme.Animations.Timing.hide,
            delay: 0,
            options: [.beginFromCurrentState, Theme.Animations.Curve.hide],
            animations: {
            self.fullCircle.alpha = 0
            self.digitLabelActive.alpha = 0
        }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
