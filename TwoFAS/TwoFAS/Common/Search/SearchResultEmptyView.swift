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

final class SearchResultEmptyView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme.Colors.Text.inactive
        label.font = Theme.Fonts.Text.boldContent
        label.text = T.Commons.noResults
        label.textAlignment = .center
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.7
        label.allowsDefaultTighteningForTruncation = true
        label.adjustsFontSizeToFitWidth = true
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
        addSubview(titleLabel, with: [
            titleLabel.topAnchor.constraint(equalTo: safeTopAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: safeBottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Metrics.doubleMargin),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Metrics.doubleMargin)
        ])
    }
}
