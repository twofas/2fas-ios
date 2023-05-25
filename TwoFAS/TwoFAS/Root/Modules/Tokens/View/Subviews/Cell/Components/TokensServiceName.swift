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

final class TokensServiceName: UIView {
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics(forTextStyle: .headline)
            .scaledFont(for: .systemFont(ofSize: 17, weight: .bold))
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = Theme.Colors.Text.main
        label.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
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
        addSubview(label)
        label.pinToParent()
    }
    
    func setKind(_ kind: TokensCellKind) {
        switch kind {
        case .compact:
            label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        case .edit:
            label.font = UIFontMetrics(forTextStyle: .headline)
                .scaledFont(for: .systemFont(ofSize: 13, weight: .bold))
        case .normal:
            label.font = UIFontMetrics(forTextStyle: .headline)
                .scaledFont(for: .systemFont(ofSize: 17, weight: .bold))
        }
    }
    
    func setText(_ text: String) {
        label.text = text
    }
}
