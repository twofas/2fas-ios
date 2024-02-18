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

protocol BackupDeleteViewControlling: AnyObject {}

final class BackupDeleteViewController: UIViewController {
    var presenter: BackupDeletePresenter!
    private let spacer0 = UIView()
    private let spacer1 = UIView()
    
    private var deleteButton: LoadingContentButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = generate()
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToParent()
        vc.didMove(toParent: self)
    }
    
    private func generate() -> UIViewController {
        let spacing: CGFloat = 15
        let contentTop = MainContainerTopContentGenerator(placement: .centerHorizontallyLimitWidth, elements: [
            .view(view: spacer0),
            .image(name: "backupDeleted", size: CGSize(width: 280, height: 200)),
            .extraSpacing,
            .text(text: T.Backup.delete2fasBackup, style: MainContainerTextStyling.titleLight)
        ])
        
        let contentMiddle = MainContainerMiddleContentGenerator(
            placement: .centerHorizontallyLimitWidth,
            elements: [.view(view: spacer1)]
        )
        
        let contentBottom = MainContainerBottomContentGenerator(elements: [
            .image(
                name: "WarningIconLarge",
                size: CGSize(width: 30,
                             height: 30),
                kind: .template(color: Theme.Colors.Fill.backgroundLight)
            ),
            .extraSpacing(value: spacing),
            .text(text: T.Backup.warningIntroduction, style: MainContainerTextStyling.noteLight),
            .extraSpacing(value: spacing),
            .decoratedVerticalContainer(elements: [
                .toggle(text: T.Backup.deleteTitle) { [weak self] value in
                    self?.deleteButton?.setState(value ? .active : .inactive)
                },
                .filledButton(
                    text: T.Commons.delete,
                    callback: { [weak self] in
                        self?.presenter.handleDeleteBackup()
                    },
                    created: { [weak self] button in
                        button.apply(MainContainerButtonStyling.filledInDecoratedContainer.value)
                        button.setState(.inactive)
                        self?.deleteButton = button
                    }
                )
            ], created: { c in
                let value: CGFloat = 20
                c.setBackgroundColor(Theme.Colors.decoratedContainer)
                c.setContentEdge(edge: value)
                c.spacing = value
            }),
            .textButton(
                text: T.Commons.cancel,
                callback: { [weak self] in
                    self?.presenter.handleCancel()
                },
                created: { button in
                    button.apply(MainContainerButtonStyling.textOnDark.value)
                }
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
        
        NSLayoutConstraint.activate([
            spacer0.heightAnchor.constraint(equalTo: spacer1.heightAnchor)
        ])
        
        return vc
    }
}

extension BackupDeleteViewController: BackupDeleteViewControlling {}
