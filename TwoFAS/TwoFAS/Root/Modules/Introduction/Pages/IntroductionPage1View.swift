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

final class IntroductionPage1View: IntroductionPageView {
    private let logoForPresentation: UIImageView = {
        let img = UIImageView(image: Asset.introductionLogo.image)
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    private let backgroundImage: UIImageView = {
        let img = UIImageView(image: Asset.introductionBackground.image)
        img.contentMode = .center
        img.tintColor = Theme.Colors.Line.secondaryLine
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
        backgroundContainer.addSubview(backgroundImage)
        backgroundImage.pinToParent()
        
        clipsToBounds = true
                
        titleLabel.text = T.Introduction.page1Title
        contentLabel.text = T.Introduction.page1Content
        
        topContainer.addSubview(logoForPresentation, with: [
            logoForPresentation.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            logoForPresentation.topAnchor.constraint(equalTo: topContainer.topAnchor)
        ])
        topContainer.addSubview(titleLabel, with: [
            titleLabel.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor),
            titleLabel.topAnchor.constraint(equalTo: logoForPresentation.bottomAnchor, constant: verticalSpacingLarge)
        ])
        bottomContainer.addSubview(contentLabel, with: [
            contentLabel.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor),
            contentLabel.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: verticalSpacingSmall),
            contentLabel.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor)
        ])
    }
        
    override var showBack: Bool { false }
    override var mainButtonTitle: String { T.Commons.continue }
}
