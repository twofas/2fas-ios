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
import Token

protocol AddingServiceTokenViewControlling: AnyObject {
    var totpAdapter: TOTPAdapter { get }
    var hotpAdapter: HOTPAdapter { get }
    func tokenCopied()
}

final class AddingServiceTokenViewController: UIViewController, AddingServiceTokenViewControlling {
    var heightChange: ((CGFloat) -> Void)?
    var presenter: AddingServiceTokenPresenter!
    
    let totpAdapter = TOTPAdapter()
    let hotpAdapter = HOTPAdapter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let token = AddingServiceTokenView(
            presenter: presenter,
            changeHeight: { [weak self] height in
                self?.heightChange?(height)
            }) { [weak self] in
                self?.presentingViewController?.dismiss(animated: true)
            }
        
        let vc = UIHostingController(rootView: token)
        vc.willMove(toParent: self)
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToParent()
        vc.view.backgroundColor = Theme.Colors.Fill.System.third
        vc.didMove(toParent: self)
        
        totpAdapter.configure(presenter: presenter)
        hotpAdapter.configure(presenter: presenter)
        
        presenter.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        presenter.viewWillDisappear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.handleViewDidDisapper()
    }
    
    func tokenCopied() {
        VoiceOver.say(T.Notifications.tokenCopied)
        HUDNotification.presentSuccess(title: T.Notifications.tokenCopied)
    }
}
