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
import Common

final class AlertController: UIAlertController {
    var removeController: ((AlertController) -> Void)?
    
    private var alertWindow: UIWindow?

    func show(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        let windowScene = UIApplication.shared.currentScene
            ?? UIApplication.keyWindow?.windowScene
            ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        guard let windowScene else { Log("No window scene for alert"); return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIViewController()
        window.backgroundColor = UIColor.clear
        window.windowLevel = UIWindow.Level.alert
        alertWindow = window
        window.makeKeyAndVisible()

        window.rootViewController?.present(self, animated: flag, completion: completion)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeController?(self)
    }
}
