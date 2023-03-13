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

protocol TrashServiceViewControlling: AnyObject {
    func setupView(with name: String)
    func dismissing()
    func deleted()
}

final class TrashServiceViewController: UIViewController {
    var presenter: TrashServicePresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    func generate(with serviceName: String) -> UIViewController {
        let contentTop = MainContainerTopContentGenerator(placement: .centerHorizontallyLimitWidth, elements: [
            .text(text: T.Tokens.deleteToken, style: MainContainerTextStyling.content),
            .text(text: serviceName, style: MainContainerTextStyling.boldTitleOneLine)
        ])
        
        let contentMiddle = MainContainerMiddleContentGenerator(placement: .centerHorizontallyLimitWidth, elements: [
            .centeredImage(image: Asset.deleteScreenIcon.image),
            .extraSpacing,
            .text(
                text: T.Tokens.signInNotPossibleTitle(serviceName, serviceName),
                style: MainContainerTextStyling.content
            )
        ])
        
        let contentBottom = MainContainerBottomContentGenerator(elements: [
            .filledButton(text: T.Tokens.moveToTrash, callback: { [weak self] in self?.presenter.handleTrashing() }),
            .textButton(text: T.Commons.cancel, callback: { [weak self] in self?.presenter.handleCancel() })
        ])
        
        let config = MainContainerViewController.Configuration(
            barConfiguration: MainContainerBarConfiguration.statusBar(.hide),
            contentTop: contentTop,
            contentMiddle: contentMiddle,
            contentBottom: contentBottom,
            generalConfiguration: MainContainerNonScrollable()
        )
        
        let vc = MainContainerViewController()
        vc.configure(with: config)
        vc.view.backgroundColor = Theme.Colors.Fill.background
        
        return vc
    }
}

extension TrashServiceViewController: TrashServiceViewControlling {
    func setupView(with name: String) {
        let vc = generate(with: name)
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToParent()
        vc.didMove(toParent: self)
    }
    
    func dismissing() {
        VoiceOver.say(T.Voiceover.dismissing)
    }
    
    func deleted() {
        VoiceOver.say(T.Voiceover.serviceDeleted)
    }
}
