//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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
import Common

public extension ToastPresenter {
    func presentCopied() {
        present(
            T.Tokens.copiedClipboard,
            style: .info,
            icon: UIImage(icon: .rectangleOnRectangle)
        )
    }

    func presentTokenCopied() {
        present(T.Notifications.tokenCopied, style: .success)
    }

    func presentNextTokenCopied() {
        present(T.Notifications.nextTokenCopied, style: .success)
    }

    func presentServiceKeyCopied() {
        present(T.Notifications.serviceKeyCopied, style: .success)
    }

    func presentLinkCopied() {
        present(T.Notifications.linkCopied, style: .success)
    }

    func presentCounterCopied() {
        present(T.Notifications.counterCopied, style: .success)
    }

    func presentSuccess(title: String, onDismiss: @escaping Callback = {}) {
        present(title, style: .success, onDismiss: onDismiss)
    }

    func presentFailure(title: String, onDismiss: @escaping Callback = {}) {
        present(title, style: .failure, onDismiss: onDismiss)
    }
}
