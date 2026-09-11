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

    func addSubview(_ v: UIView, with constraints: [NSLayoutConstraint]) {
        v.translatesAutoresizingMaskIntoConstraints = false
        addSubview(v)
        NSLayoutConstraint.activate(constraints)
    }

    func applyRoundedCorners(withBackgroundColor color: UIColor, cornerRadius: CGFloat = Theme.Metrics.cornerRadius) {
        backgroundColor = color
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }

    func applyRoundedBorder(
        withBorderColor color: UIColor,
        width borderWidth: CGFloat? = nil,
        cornerRadius: CGFloat = Theme.Metrics.cornerRadius
    ) {
        backgroundColor = UIColor.clear
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        layer.borderWidth = borderWidth ?? Theme.Metrics.lineWidth
        layer.borderColor = color.cgColor
    }

    var safeTopAnchor: NSLayoutYAxisAnchor { self.safeAreaLayoutGuide.topAnchor }
    var safeLeadingAnchor: NSLayoutXAxisAnchor { self.safeAreaLayoutGuide.leadingAnchor }
    var safeBottomAnchor: NSLayoutYAxisAnchor { self.safeAreaLayoutGuide.bottomAnchor }
}

extension UITraitEnvironment {
    var isRegularWidthLayout: Bool {
        traitCollection.horizontalSizeClass == .regular
    }
}
