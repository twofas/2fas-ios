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

final class SpinnerBackground: UIView {
    private var isAnimating = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = ThemeColor.overlay
        alpha = 0
        isUserInteractionEnabled = false
        isAccessibilityElement = false
    }
    
    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        alpha = 0
        UIView.animate(
            withDuration: ThemeMetrics.animationTime,
            delay: 0,
            options: .curveEaseInOut,
            animations: { self.alpha = 1 },
            completion: { _ in self.isAnimating = false }
        )
    }
}
