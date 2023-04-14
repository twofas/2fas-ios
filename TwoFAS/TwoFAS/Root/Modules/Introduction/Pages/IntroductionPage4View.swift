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

final class IntroductionPage4View: IntroductionPageView {
    private let image: UIImageView = {
        let img = UIImageView(image: Asset.introductionPage2.image)
        img.contentMode = .scaleAspectFit
        return img
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
        titleLabel.text = T.Introduction.page4Title
        contentLabel.text = T.Introduction.page4ContentIos
        
        topContainer.addSubview(image, with: [
            image.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            image.topAnchor.constraint(greaterThanOrEqualTo: topContainer.topAnchor),
            image.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor),
            image.widthAnchor.constraint(equalTo: topContainer.widthAnchor)
        ])
        bottomContainer.addSubview(titleLabel, with: [
            titleLabel.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: verticalSpacingLarge / 2.0)
        ])
        bottomContainer.addSubview(contentLabel, with: [
            contentLabel.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor),
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: verticalSpacingSmall),
            contentLabel.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor)
        ])
        
        mainButtonAdditionalAction = {
            AppEventLog(.onboardingStart)
        }
    }
    
    override var mainButtonTitle: String { T.Introduction.title }
    override var showSkip: Bool { false }
}
