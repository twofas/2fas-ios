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

final class UUIDInputContainer: UIView {
    private let border = Border()
    private var widthConstraint: NSLayoutConstraint?
    let input = UUIDInputField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        input.textColor = ThemeColor.uuidInputText
        
        addSubview(border)
        border.pinToParent()
        
        addSubview(input, with: [
            input.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Metrics.doubleMargin),
            input.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Metrics.doubleMargin),
            input.topAnchor.constraint(equalTo: topAnchor, constant: Theme.Metrics.standardSpacing),
            input.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.Metrics.standardSpacing)
        ])
        
        widthConstraint = input.widthAnchor.constraint(equalToConstant: 0)
        widthConstraint?.isActive = true
    }
    
    func setLength(_ length: UUIDInputLength) {
        input.setLength(length)
        widthConstraint?.constant = length.width
    }
    
    override var intrinsicContentSize: CGSize {
        input.layoutIfNeeded()
        return CGSize(
            width: 2 * Theme.Metrics.doubleMargin + input.frame.width,
            height: 2 * Theme.Metrics.standardSpacing + input.frame.height
        )
    }
}

private final class Border: UIView {
    private let cornerRadius: CGFloat = 10
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        applyRoundedCorners(withBackgroundColor: ThemeColor.uuidInputBackground, cornerRadius: cornerRadius)
    }
}

private extension UUIDInputLength {
    var width: CGFloat {
        CGFloat(self.rawValue) * 10.0
    }
}
