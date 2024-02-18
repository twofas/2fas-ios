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

final class TrashViewEmptyScreen: UIView {
    private let icon = UIImageView(image: Asset.trashEmptyIcon.image)
    
    private let text: UILabel = {
       let label = UILabel()
        label.text = T.Settings.trashIsEmpty
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = Theme.Colors.Text.inactive
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = Theme.Colors.Table.background
        
        let iconOffset: CGFloat = {
            if let height = icon.image?.size.height {
                return height.half
            }
            return Theme.Metrics.standardSpacing
        }()
        addSubview(icon, with: [
            icon.centerXAnchor.constraint(equalTo: centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -iconOffset)
        ])
        addSubview(text, with: [
            text.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: Theme.Metrics.doubleSpacing),
            text.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Metrics.standardMargin),
            text.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Metrics.standardMargin),
            text.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
    }
}
