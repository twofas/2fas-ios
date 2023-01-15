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

final class ComposeServiceFormError: UILabel {
    private let extraHeight: CGFloat = 10
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        font = Theme.Fonts.Form.error
        textColor = Theme.Colors.Form.error
        numberOfLines = 0
        allowsDefaultTighteningForTruncation = true
        lineBreakMode = .byWordWrapping
        minimumScaleFactor = 0.7
        textAlignment = .left
        adjustsFontSizeToFitWidth = true
        isUserInteractionEnabled = false
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: super.intrinsicContentSize.width, height: super.intrinsicContentSize.height + extraHeight)
    }
}
