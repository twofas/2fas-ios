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

final class BackupAreaWarningView: UIView {
    private let iconWidth: CGFloat = 18
    private var label: UILabel!
    private var action: Callback?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = Theme.Colors.Fill.theme
        
        let icon = UIImageView(image: Asset.warningIcon.image)
        icon.contentMode = .center
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)
        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: topAnchor),
            icon.bottomAnchor.constraint(equalTo: bottomAnchor),
            icon.widthAnchor.constraint(equalToConstant: iconWidth),
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Metrics.doubleSpacing)
        ])
        
        label = UILabel()
        label.textColor = Theme.Colors.Text.light
        label.font = Theme.Fonts.warning
        label.textAlignment = .center
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: Theme.Metrics.doubleSpacing),
            label.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -2 * Theme.Metrics.doubleSpacing - iconWidth
            )
        ])
        
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addSubview(button)
        button.pinToParent()
        
        Animate.pulse(icon)
    }
    
    func setTitle(_ title: String, action: @escaping Callback) {
        label.text = title
        self.action = action
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Theme.Metrics.warningHeight)
    }
    
    @objc
    private func buttonTapped() {
        action?()
    }
}
