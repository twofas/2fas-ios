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

final class ImporterFileErrorViewController: UIViewController {
    var presenter: ImporterFileErrorPresenter!
    
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
        
        let error = presenter.fileError
        let title: String = {
            switch error {
            case .noNewServices: return T.Backup.noNewServices
            default: return T.Backup.fileError
            }
        }()
        var reason: String?
        let content: String = {
            switch error {
            case .noNewServices: return T.Backup.noNewServicesError
            case .newerSchema: return T.Backup.updateRequiredToImportTitle
            case .cantReadFile(let errReason):
                reason = errReason
                return T.Backup.cantReadFileError
            }
        }()
        
        var elements: [MainContainerContentGenerator.Element] = [
            .image(name: "fileError", size: CGSize(width: 280, height: 200)),
            .extraSpacing,
            .text(text: title, style: MainContainerTextStyling.title),
            .extraSpacing,
            .text(text: content, style: MainContainerTextStyling.content)
        ]
        
        if let reason {
            elements.append(
                .text(text: reason, style: .note)
            )
        }
        
        let contentMiddle = MainContainerMiddleContentGenerator(
            placement: .centerHorizontallyLimitWidth,
            elements: elements
        )
        
        let contentBottom: MainContainerBottomContentGenerator = {
            .init(elements: [
                .filledButton(text: T.Commons.close, callback: { [weak self] in self?.presenter.handleClose() })
            ])
        }()
        
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
}
