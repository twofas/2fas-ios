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

protocol ImporterPreimportSummaryViewControlling: AnyObject {
    func showImporting()
}

final class ImporterPreimportSummaryViewController: UIViewController {
    var presenter: ImporterPreimportSummaryPresenter!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = generate()
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToParent()
        vc.didMove(toParent: self)
    }
    
    private func generate() -> UIViewController {
        let barConfiguration = MainContainerBarConfiguration(
            title: nil,
            left: nil,
            right: nil,
            hideTabBar: true,
            hideNavigationBar: true,
            statusBar: nil
        )
        
        let contentMiddle = MainContainerMiddleContentGenerator(placement: .centerHorizontallyLimitWidth, elements: [
            { () -> MainContainerContentGenerator.Element in
                if let icon = presenter.additionalIcon {
                    return .view(view: createImportImage(with: icon))
                }
                return .image(name: "importBackup", size: CGSize(width: 280, height: 200))
            }(),
            .extraSpacing,
            .text(text: presenter.title, style: MainContainerTextStyling.title),
            .extraSpacing,
            .text(text: presenter.subtitle, style: MainContainerTextStyling.content),
            .text(
                text: {
                    if presenter.isBackupFile {
                        return T.Backup.newServices(presenter.countNew)
                    }
                    return T.Tokens.googleAuthOutOfTitle(presenter.countNew, presenter.countTotal)
                }(),
                style: MainContainerTextStyling.boldContent
            ),
            .text(text: {
                if presenter.isBackupFile {
                    return T.Backup.servicesMergeTitle
                }
                return T.Tokens.googleAuthImportSubtitleEnd
            }(), style: MainContainerTextStyling.content)
        ])
        
        let contentBottom = MainContainerBottomContentGenerator(elements: [
            .filledButton(text: T.Backup.importFile, callback: { [weak self] in self?.presenter.handleImport() }),
            .textButton(
                text: T.Commons.cancel,
                callback: { [weak self] in self?.presenter.handleCancel() },
                created: nil
            )
        ])
        
        let config = MainContainerViewController.Configuration(
            barConfiguration: barConfiguration,
            contentTop: nil,
            contentMiddle: contentMiddle,
            contentBottom: contentBottom
        )
        
        let vc = MainContainerViewController()
        vc.configure(with: config)
        
        return vc
    }
    
    private func createImportImage(with icon: UIImage) -> UIView {
        let views = [
            UIImageView(image: icon),
            UIImageView(image: Asset.gaImport1.image),
            UIImageView(image: Asset.gaImport2.image)
        ]
        views.forEach({
            $0.contentMode = .center
        })
        let stackView = UIStackView(arrangedSubviews: views)
        
        stackView.spacing = Theme.Metrics.doubleSpacing
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .horizontal
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            container.heightAnchor.constraint(equalToConstant: 80)
        ])
        container.addSubview(stackView)
        stackView.pinToParentCenter()
        
        return container
    }
}

extension ImporterPreimportSummaryViewController: ImporterPreimportSummaryViewControlling {
    func showImporting() {
        view.isUserInteractionEnabled = false
        let spinner = UIActivityIndicatorView(style: .medium)
        view.addSubview(spinner, with: [
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        spinner.startAnimating()
    }
}
