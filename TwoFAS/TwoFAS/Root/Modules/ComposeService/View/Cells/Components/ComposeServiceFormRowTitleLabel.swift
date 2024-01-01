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

final class ComposeServiceFormRowTitleLabel: UILabel {
    var didTap: Callback?
    private let height: CGFloat = 40
    private let width: CGFloat = 110
    
    convenience init(text: String) {
        self.init(frame: .zero)
        self.text = text
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        textColor = Theme.Colors.Form.rowTitle
        font = UIFont.preferredFont(forTextStyle: .body)
        numberOfLines = 1
        allowsDefaultTighteningForTruncation = true
        lineBreakMode = .byTruncatingTail
        minimumScaleFactor = 0.7
        textAlignment = .left
        adjustsFontSizeToFitWidth = true
        setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAction)))
        isUserInteractionEnabled = true
    }
    
    override var intrinsicContentSize: CGSize {
        let newWidth: CGFloat = {
            if super.intrinsicContentSize.width > width {
                return super.intrinsicContentSize.width
            }
            return width
        }()
        
        return CGSize(width: newWidth, height: height)
    }
    
    func setTitleForRequiredValue(_ title: String) {
        let newTitle = title + "*"
        attributedText = NSAttributedString.create(
            text: newTitle,
            emphasis: "*",
            standardAttributes: [.foregroundColor: Theme.Colors.Form.rowTitle],
            emphasisAttributes: [.foregroundColor: Theme.Colors.Form.requried]
        )
    }
    
    @objc(didTapAction)
    private func didTapAction() {
        didTap?()
    }
}
