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
import Data
import Common

final class ComposeServiceAdvancedEditTokenTypeCell: UITableViewCell {
    static let identifier = "ComposeServiceAdvancedEditTokenTypeCell"
    
    var didSelect: ((TokenType) -> Void)?
    
    private let totp = SelectionOption()
    private let hotp = SelectionOption()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private var tokenType: TokenType = .totp
    
    private func commonInit() {
        backgroundColor = Theme.Colors.SettingsCell.background
        
        totp.translatesAutoresizingMaskIntoConstraints = false
        hotp.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(totp)
        contentView.addSubview(hotp)
        
        let verticalMargin = Theme.Metrics.doubleMargin
        
        NSLayoutConstraint.activate([
            totp.topAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.topAnchor,
                constant: verticalMargin
            ),
            totp.bottomAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.bottomAnchor,
                constant: -verticalMargin
            ),
            hotp.topAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.topAnchor,
                constant: verticalMargin
            ),
            hotp.bottomAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.bottomAnchor,
                constant: -verticalMargin
            ),
            NSLayoutConstraint(
                item: totp,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerX,
                multiplier: 0.6,
                constant: 0
            ),
            NSLayoutConstraint(
                item: hotp,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerX,
                multiplier: 1.4,
                constant: 0
            )
        ])
        
        totp.setSelected(true)
        totp.hideIconContainer()
        totp.setTitle(T.Tokens.totp)
        
        hotp.setTitle(T.Tokens.hotp)
        hotp.hideIconContainer()
        
        totp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(totpAction)))
        hotp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hotpAction)))
        
        selectionStyle = .none
        
        accessibilityElements = [totp, hotp]
    }
    
    func setSelectedTokenType(_ selectedTokenType: TokenType) {
        self.tokenType = selectedTokenType
        switch tokenType {
        case (.totp, .steam): switchToTOTP()
        case .hotp: switchToHOTP()
        }
    }
    
    @objc
    private func totpAction() {
        switchToTOTP()
        didSelect?(.totp)
    }
    
    @objc
    private func hotpAction() {
        switchToHOTP()
        didSelect?(.hotp)
    }
    
    private func switchToTOTP() {
        totp.setSelected(true)
        hotp.setSelected(false)
    }
    
    private func switchToHOTP() {
        totp.setSelected(false)
        hotp.setSelected(true)
    }
}
