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

final class LoginViewController: UIViewController, LoginViewModelDelegate {
    var viewModel: LoginViewModel!
    
    private var codeViewController: PINPadViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        codeViewController = PINPadViewController()
        codeViewController.viewModel = viewModel.codeViewModel
        codeViewController.willMove(toParent: self)
        addChild(codeViewController)
        view.addSubview(codeViewController.view)
        codeViewController.view.pinToParent()
        codeViewController.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.viewDidAppear()
    }
    
    func userWasAuthenticated() {
        viewModel.userWasAuthenticated()
    }
    
    func lockUI() {
        viewModel.lock()
    }
    
    func unlockUI() {
        viewModel.unlock()
    }
}
