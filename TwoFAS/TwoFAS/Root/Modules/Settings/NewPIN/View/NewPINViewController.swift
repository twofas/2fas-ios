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

protocol NewPINViewControlling: AnyObject {
    func setTitle(_ title: String)
    func showCancelButton()
}

final class NewPINViewController: PINKeyboardViewController {
    var presenter: NewPINPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonDisplayMode = .minimal
        presenter.viewDidLoad()
    }
    
    override func deleteButtonTap() {
        presenter.handleDeleteButtonTap()
    }
    
    override func numberButtonTap(_ number: Int) {
        presenter.handleNumberButtonPressed(number)
    }
    
    override func leftButtonTap() {
        presenter.handleCancel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewWillAppear()
    }
    
    @objc
    private func cancelAction() {
        presenter.handleCancel()
    }
    
    override func bottomButtonTap() {
        presenter.handleChangePINType()
    }
}

extension NewPINViewController: NewPINViewControlling {
    func setTitle(_ title: String) {
        self.title = title
    }
    
    func showCancelButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: T.Commons.cancel,
            style: .plain,
            target: self,
            action: #selector(cancelAction)
        )
    }
}
