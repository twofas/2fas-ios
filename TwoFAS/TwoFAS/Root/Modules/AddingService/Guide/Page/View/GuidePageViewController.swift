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

import Foundation


import UIKit
import SwiftUI

final class GuidePageViewController: UIViewController {
    var presenter: GuidePagePresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = T.Guides.guideTitle(presenter.serviceName)
        navigationItem.backButtonDisplayMode = .minimal
        view.backgroundColor = Theme.Colors.Fill.System.third
        
        let page = GuidePageView(presenter: presenter)
        
        let vc = UIHostingController(rootView: page)
        vc.willMove(toParent: self)
        addChild(vc)
        view.addSubview(vc.view, with: [
            vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vc.view.topAnchor.constraint(equalTo: view.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: view.safeBottomAnchor)
        ])
        vc.view.backgroundColor = Theme.Colors.Fill.System.third
        vc.didMove(toParent: self)
    }
}
