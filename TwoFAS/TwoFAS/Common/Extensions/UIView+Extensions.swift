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

extension UIView {
    func pinToParent(flexibleBottom: Bool = false) {
        guard let s = superview else {
            Log("No parent view available")
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: s.topAnchor),
            leftAnchor.constraint(equalTo: s.leftAnchor),
            rightAnchor.constraint(equalTo: s.rightAnchor)
        ])
        
        if flexibleBottom {
            bottomAnchor.constraint(lessThanOrEqualTo: s.bottomAnchor).isActive = true
        } else {
            bottomAnchor.constraint(equalTo: s.bottomAnchor).isActive = true
        }
    }
    
    func pinToParent(with margin: UIEdgeInsets) {
        guard let s = superview else {
            Log("No parent view available")
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: s.topAnchor, constant: margin.top),
            leadingAnchor.constraint(equalTo: s.leadingAnchor, constant: margin.left),
            trailingAnchor.constraint(equalTo: s.trailingAnchor, constant: -margin.right),
            bottomAnchor.constraint(equalTo: s.bottomAnchor, constant: -margin.bottom)
        ])
    }
    
    func pinContentToScrollView(withTopMargin topMargin: CGFloat) {
        pinToParentMargin(withInsets: UIEdgeInsets(top: topMargin, left: 0, bottom: 0, right: 0), flexibleBottom: true)
    }
    
    func pinToParentMargin(withInsets insets: UIEdgeInsets = UIEdgeInsets.zero, flexibleBottom: Bool = false) {
        guard let s = superview else {
            
            Log("No parent view available")
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: s.layoutMarginsGuide.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: s.layoutMarginsGuide.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: s.layoutMarginsGuide.trailingAnchor, constant: insets.right)
        ])
        
        if flexibleBottom {
            bottomAnchor.constraint(
                lessThanOrEqualTo: s.layoutMarginsGuide.bottomAnchor,
                constant: insets.bottom
            ).isActive = true
        } else {
            bottomAnchor.constraint(
                equalTo: s.layoutMarginsGuide.bottomAnchor,
                constant: insets.bottom
            ).isActive = true
        }
    }
    
    func pinToParentCenter() {
        guard let s = superview else {
            Log("No parent view available")
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: s.centerXAnchor),
            centerYAnchor.constraint(equalTo: s.centerYAnchor)
        ])
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20, 20, -20, 20, -10, 10, -5, 5, 0]
        layer.add(animation, forKey: "shake")
    }
    
    static func prepareViewsForAutoLayout(withViews views: [UIView], superview: UIView?) {
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        guard let s = superview else { return }
        
        views.forEach { s.addSubview($0) }
    }
    
    func overlay(_ view: UIView, on overlayed: UIView) {
        addSubview(view, with: [
            view.leadingAnchor.constraint(equalTo: overlayed.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: overlayed.trailingAnchor),
            view.topAnchor.constraint(equalTo: overlayed.topAnchor),
            view.bottomAnchor.constraint(equalTo: overlayed.bottomAnchor)
        ])
    }
    
    func addSubview(_ v: UIView, with constraints: [NSLayoutConstraint]) {
        v.translatesAutoresizingMaskIntoConstraints = false
        addSubview(v)
        NSLayoutConstraint.activate(constraints)
    }
    
    func animateReplacementOfSubview(_ subview: UIView?, with replacement: UIView, completion: @escaping Callback) {
        replacement.alpha = 0
        
        if let subview {
            subview.quickAnim({
                subview.alpha = 0
            }) {
                replacement.quickAnim({
                    replacement.alpha = 1
                }, completion: completion)
            }
        } else {
            replacement.quickAnim({
                replacement.alpha = 1
            }, completion: completion)
        }
    }
    
    func applyRoundedCorners(withBackgroundColor color: UIColor, cornerRadius: CGFloat = Theme.Metrics.cornerRadius) {
        backgroundColor = color
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
    
    func applyRoundedBorder(withBorderColor color: UIColor, width borderWidth: CGFloat? = nil) {
        backgroundColor = UIColor.clear
        layer.cornerRadius = Theme.Metrics.cornerRadius
        layer.masksToBounds = true
        layer.borderWidth = borderWidth ?? Theme.Metrics.lineWidth
        layer.borderColor = color.cgColor
    }
    
    func clearBorder() {
        layer.borderWidth = 0
        layer.borderColor = nil
    }
    
    var safeTopAnchor: NSLayoutYAxisAnchor { self.safeAreaLayoutGuide.topAnchor }
    var safeLeadingAnchor: NSLayoutXAxisAnchor { self.safeAreaLayoutGuide.leadingAnchor }
    var safeTrailingAnchor: NSLayoutXAxisAnchor { self.safeAreaLayoutGuide.trailingAnchor }
    var safeBottomAnchor: NSLayoutYAxisAnchor { self.safeAreaLayoutGuide.bottomAnchor }
    
    func quickAnim(_ animations: @escaping Callback) {
        quickAnim(animations, completion: nil)
    }
    
    func quickAnim(_ animations: @escaping Callback, completion: Callback? = nil) {
        UIView.animate(
            withDuration: Theme.Animations.Timing.show,
            animations: animations,
            completion: { _ in completion?() }
        )
    }
    
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}
