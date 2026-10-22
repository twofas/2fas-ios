//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

final class TokensServiceTitle: UIView {
    private let serviceNameLabel = TokensServiceName()
    private let additionalInfoLabel: TokensAdditionalInfo = {
        let comp = TokensAdditionalInfo()
        comp.isHidden = true
        return comp
    }()
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [serviceNameLabel, additionalInfoLabel])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
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
        addSubview(stackView)
        stackView.pinToParent()
        setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        setContentHuggingPriority(.defaultLow - 1, for: .vertical)
    }

    func setKind(_ kind: TokensCellKind) {
        serviceNameLabel.setKind(kind)
        additionalInfoLabel.setKind(kind)
    }

    func setText(name: String, additionalInfo: String?) {
        serviceNameLabel.setText(name)

        let trimmedAdditionalInfo = additionalInfo?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmedAdditionalInfo.isEmpty {
            additionalInfoLabel.clear()
            additionalInfoLabel.isHidden = true
        } else {
            additionalInfoLabel.setText(trimmedAdditionalInfo)
            additionalInfoLabel.isHidden = false
        }
    }
}
