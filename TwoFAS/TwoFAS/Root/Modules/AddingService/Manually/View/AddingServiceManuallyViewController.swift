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
import Data

protocol AddingServiceManuallyViewControlling: AnyObject {}

final class AddingServiceManuallyViewController: UIViewController, AddingServiceManuallyViewControlling {
    private lazy var pairButton = UIBarButtonItem(
        title: T.Commons.pair,
        style: .plain,
        target: self,
        action: #selector(pairAction)
    )
    
    var presenter: AddingServiceManuallyPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: T.Commons.cancel,
            style: .plain,
            target: self,
            action: #selector(cancelAction)
        )
        
        navigationItem.rightBarButtonItem = pairButton
        navigationItem.title = T.Tokens.addManualTitle
        navigationItem.backButtonDisplayMode = .minimal
        
        let manually = AddingServiceManuallyView(presenter: presenter) { [weak self] enable in
            self?.pairButton.isEnabled = enable
        }
        
        let vc = UIHostingController(rootView: manually)
        vc.willMove(toParent: self)
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToParent()
        vc.view.backgroundColor = Theme.Colors.Fill.System.third
        vc.didMove(toParent: self)
        
        presenter.viewDidLoad()
    }
    
    @objc
    private func cancelAction() {
        presenter.handleCancel()
    }
    
    @objc
    private func pairAction() {
        presenter.handlePair()
    }
}
