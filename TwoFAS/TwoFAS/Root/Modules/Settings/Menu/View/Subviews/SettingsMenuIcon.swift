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

final class SettingsMenuIcon: UIImageView {
    init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        tintColor = Theme.Colors.Fill.theme
        contentMode = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyBorder()
    }
    
    private func applyBorder() {
        applyRoundedBorder(withBorderColor: Theme.Colors.SettingsCell.iconBorder, width: Theme.Metrics.separatorHeight)
        backgroundColor = Theme.Colors.Icon.background
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else { return }
        applyBorder()
    }
    
    func disable() {
        tintColor = Theme.Colors.Icon.inactive
    }
    
    func enable() {
        tintColor = Theme.Colors.Fill.theme
    }
}
