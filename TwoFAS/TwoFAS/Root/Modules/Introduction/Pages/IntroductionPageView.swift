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

class IntroductionPageView: UIView {
    private let width: CGFloat = Theme.Metrics.pageWidth
    private let margin: CGFloat = Theme.Metrics.doubleMargin
    
    let backgroundContainer = UIView()
    let topContainer = UIView()
    let bottomContainer = UIView()
    
    let verticalSpacingLarge: CGFloat = 60
    let verticalSpacingSmall: CGFloat = 25
    let topImageHeight: CGFloat = 202
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.textColor = Theme.Colors.Text.main
        label.font = Theme.Fonts.introTitle
        return label
    }()
    
    let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.textColor = Theme.Colors.Text.main
        label.font = Theme.Fonts.Text.content
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
        addSubview(backgroundContainer, with: [
            backgroundContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundContainer.topAnchor.constraint(equalTo: topAnchor),
            backgroundContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])        
        addSubview(topContainer, with: [
            topContainer.bottomAnchor.constraint(equalTo: centerYAnchor),
            topContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            topContainer.widthAnchor.constraint(equalToConstant: width),
            topContainer.topAnchor.constraint(greaterThanOrEqualTo: safeTopAnchor, constant: margin)
        ])
        addSubview(bottomContainer, with: [
            bottomContainer.topAnchor.constraint(equalTo: centerYAnchor),
            bottomContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomContainer.widthAnchor.constraint(equalToConstant: width)
        ])
    }
    
    var mainButtonTitle: String { T.Commons.next }
    var mainButtonAdditionalAction: Callback?
    var showSkip: Bool { true }
    var showBack: Bool { true }
    
    override var intrinsicContentSize: CGSize { CGSize(width: width, height: UIView.noIntrinsicMetric) }
}
