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

protocol WidgetWarningViewControlling: AnyObject {}

final class WidgetWarningViewController: UIViewController {
    var presenter: WidgetWarningPresenter!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = generate()
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToParent()
        vc.didMove(toParent: self)
    }
    
    private func generate() -> UIViewController {
        let contentMiddle = MainContainerMiddleContentGenerator(placement: .centerLimitWidth, elements: [
            .image(name: "WidgetWarningIcon", size: CGSize(width: 280, height: 200)),
            .extraSpacing,
            .text(text: "\(T.Commons.warning.uppercased())!", style: MainContainerTextStyling.title),
            .extraSpacing,
            .text(text: T.Settings.widgetsTitle, style: MainContainerTextStyling.content)
        ])
        
        let contentBottom = MainContainerBottomContentGenerator(elements: [
            .filledButton(text: T.Commons.continue, callback: { [weak self] in
                self?.presenter.handleEnableWidgets()
            }),
            .textButton(text: T.Commons.cancel, callback: { [weak self] in
                self?.presenter.handleCancel()
            })
        ])
        
        let config = MainContainerViewController.Configuration(
            barConfiguration: nil,
            contentTop: nil,
            contentMiddle: contentMiddle,
            contentBottom: contentBottom
        )
        
        let vc = MainContainerViewController()
        vc.configure(with: config)
        return vc
    }
}

extension WidgetWarningViewController: WidgetWarningViewControlling {}
