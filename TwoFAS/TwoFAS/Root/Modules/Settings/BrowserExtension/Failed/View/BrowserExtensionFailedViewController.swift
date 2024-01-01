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

final class BrowserExtensionFailureViewController: UIViewController {
    var presenter: BrowserExtensionFailurePresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let action: Callback = { [weak self] in self?.presenter.handleAction() }
        let cancel: Callback = { [weak self] in self?.presenter.handleCancel() }
        let contactSupport: Callback = { [weak self] in self?.presenter.handleContactSupport() }
        
        let v = BrowserExtensionPairingFailureView(action: action, cancel: cancel, contactSupport: contactSupport)
        let vc = NavigationBarHiddenHostingController(rootView: v)
        vc.willMove(toParent: self)
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToParent()
        vc.didMove(toParent: self)
    }
}
