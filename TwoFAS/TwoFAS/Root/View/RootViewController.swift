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
import CommonUIKit
import Common

protocol RootViewControlling: AnyObject {
    func hideAllNotifications()
    func rateApp()
    func tokenCopied()
}

final class RootViewController: UIViewController {
    var presenter: RootPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Colors.Fill.background
        SpinnerViewLocalizations.voiceOverSpinner = T.Voiceover.spinner
        Theme.applyAppearance()
    }
    
    override var shouldAutorotate: Bool { UIDevice.isiPad }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        NotificationCenter.default.post(Notification(name: Notification.Name.orientationSizeWillChange))
    }
}

extension RootViewController: RootViewControlling {
    func hideAllNotifications() {
        ToastNotification.hideAll()
    }
    
    func rateApp() {
        RatingController.uiIsVisible()
    }
    
    func tokenCopied() {
        func flashNotification() {
            VoiceOver.say(T.Notifications.tokenCopied)
            if let keyWindow = UIApplication.keyWindow {
                HUDNotification.presentSuccess(title: T.Notifications.tokenCopied, on: keyWindow)
            }
        }
        
        if UIApplication.keyWindow != nil && view != nil {
            flashNotification()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                flashNotification()
            }
        }
    }
}
