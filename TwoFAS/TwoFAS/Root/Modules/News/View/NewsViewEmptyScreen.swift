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

final class NewsViewEmptyScreen: UIView {
    private let text: UILabel = {
       let label = UILabel()
        label.text = T.Notifications.noNotifications
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = Theme.Colors.Text.main
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    private let image: UIImageView = {
        let img = Asset.emptyNotifications.image
        let imgView = UIImageView(image: img)
        imgView.contentMode = .center
        return imgView
    }()
    
    private let container = UIView()
    
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
        
        addSubview(container, with: [
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -Theme.Metrics.doubleSpacing),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Metrics.standardMargin),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Metrics.standardMargin)
        ])
        
        container.addSubview(image, with: [
            image.topAnchor.constraint(equalTo: container.topAnchor),
            image.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        container.addSubview(text, with: [
            text.topAnchor.constraint(equalTo: image.bottomAnchor, constant: Theme.Metrics.doubleSpacing),
            text.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            text.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            text.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
}
