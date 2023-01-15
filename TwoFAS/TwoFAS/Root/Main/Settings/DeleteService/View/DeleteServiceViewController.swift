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

protocol DeleteServiceViewControlling: AnyObject {
    func setupView()
    func dismissing()
    func deleted()
}

final class DeleteServiceViewController: UIViewController {
    var presenter: DeleteServicePresenter!
    
    private var deleteButton: LoadingContentButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    func generate() -> UIViewController {
        let contentTop = MainContainerTopContentGenerator(placement: .centerHorizontallyLimitWidth, elements: [
            .text(text: T.Commons.warning.uppercased(), style: MainContainerTextStyling.titleLight),
            .extraSpacing,
            .centeredImage(image: Asset.deleteForeverIcon.image)
        ])
        
        let contentMiddle = MainContainerMiddleContentGenerator(placement: .centerHorizontallyLimitWidth, elements: [
            .noSpacingContainer(elements: [
                .text(text: T.Tokens.tokenNotPossibleToRestore, style: MainContainerTextStyling.contentLight)
            ])
        ])
        
        let contentBottom = MainContainerBottomContentGenerator(elements: [
            .decoratedVerticalContainer(elements: [
                .toggle(text: T.Tokens.iWantToDeleteThisToken, action: { [weak self] value in
                    self?.deleteButton?.setState(value ? .active : .inactive)
                }),
                .filledButton(
                    text: T.Tokens.removeItForever,
                    callback: { [weak self] in self?.presenter.handleDelete() },
                    created: { [weak self] button in
                    button.apply(MainContainerButtonStyling.filledInDecoratedContainer.value)
                    button.setState(.inactive)
                    self?.deleteButton = button
                })
            ], created: { c in
                let value: CGFloat = 20
                c.setBackgroundColor(Theme.Colors.decoratedContainer)
                c.setContentEdge(edge: value)
                c.spacing = value
            }),
            .textButton(
                text: T.Commons.cancel,
                callback: { [weak self] in self?.presenter.handleCancel() },
                created: { button in button.apply(MainContainerButtonStyling.textOnDark.value) }
            )
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
        vc.view.backgroundColor = Theme.Colors.Fill.theme
        
        return vc
    }
}

extension DeleteServiceViewController: DeleteServiceViewControlling {
    func setupView() {
        let vc = generate()
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
