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
import SwiftUI
import Common

final class PushNotificationPermissionViewController: UIViewController {
    var presenter: PushNotificationPermissionPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = Theme.Colors.Fill.background
        
        let action: Callback = { [weak self] in self?.presenter.handleAction() }
        
        let v = PushNotificationPermissionView(action: action)
        let vc = NavigationBarHiddenHostingController(rootView: v)
        vc.willMove(toParent: self)
        addChild(vc)
        view.addSubview(vc.view, with: [
            vc.view.topAnchor.constraint(equalTo: view.safeTopAnchor),
            vc.view.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        vc.didMove(toParent: self)
    }
}
