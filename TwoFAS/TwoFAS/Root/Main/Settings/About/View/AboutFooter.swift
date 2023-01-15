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

final class AboutFooter: UIView {
    let height: CGFloat = 80

    private let label: UILabel = {
        let l = UILabel()
        l.isUserInteractionEnabled = true
        l.textColor = Theme.Colors.Text.inactive
        l.textAlignment = .left
        l.numberOfLines = 1
        l.font = Theme.Fonts.introContentSmall
        l.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        return l
    }()
    
    private let image: UIImageView = {
        let image = Asset.aboutLogo.image
        let imgView = UIImageView(image: image)
        imgView.contentMode = .right
        imgView.setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
        return imgView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(origin: .zero, size: .init(width: height, height: height)))
        
        commonInit()
    }
    
    private var constraint: NSLayoutConstraint?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        let margin = Theme.Metrics.doubleMargin
        addSubview(label, with: [
            label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            label.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: margin),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin)
        ])
        
        addSubview(image, with: [
            image.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: margin),
            image.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin),
            image.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            image.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: margin)
        ])
    }
    
    func setText(_ text: String) {
        label.text = text
    }
}
