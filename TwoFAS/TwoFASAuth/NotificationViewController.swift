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
import UserNotifications
import UserNotificationsUI
import Common
import CommonUIKit

protocol NotificationViewControlling: SpinnerDisplaying, AnyObject {
    func displayQuestion(domain: String, extensionName: String)
    func displayQuestionForwardToApp(domain: String, extensionName: String)
    func displaySuccess()
    func displayError(_ error: NotificationViewError)
    func displayNotPaired()
    func displayNoServices()
}

final class NotificationViewController: UIViewController, UNNotificationContentExtension {
    private let presenter = NotificationPresenter()
    private let notificationView = NotificationView()
    
    private enum NotificationActionIdentifier: String {
        case continueToApp
        case authorizeInApp
        case cancel
        case authorize
        case dismiss
        
        var localized: String {
            switch self {
            case .continueToApp: return T.Extension.continueToApp
            case .authorizeInApp: return T.Extension.approve
            case .cancel: return T.Extension.deny
            case .authorize: return T.Extension.approve
            case .dismiss: return T.Extension.dismiss
            }
        }
        
        var icon: String {
            switch self {
            case .continueToApp: return "iphone.and.arrow.forward"
            case .authorizeInApp: return "iphone.and.arrow.forward"
            case .cancel: return "lock.fill"
            case .authorize: return "lock.open.fill"
            case .dismiss: return "x.circle.fill"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        
        view.backgroundColor = ThemeColor.background
        notificationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notificationView)
        NSLayoutConstraint.activate([
            notificationView.topAnchor.constraint(equalTo: view.topAnchor),
            notificationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            notificationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            notificationView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func didReceive(_ notification: UNNotification) {
        let data = notification.request.content.userInfo
        guard let domain = data["domain"] as? String, let host = URL(string: domain)?.host,
              let extensionID = data["extension_id"] as? String,
              let tokenRequestID = data["request_id"] as? String,
              notification.request.content.categoryIdentifier == PushNotificationConfig.categoryID else {
            displayError(.generalProblem)
            return
        }
        presenter.handleReceivedRequest(for: host, extensionID: extensionID, tokenRequestID: tokenRequestID)
    }
    
    func didReceive(
        _ response: UNNotificationResponse,
        completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void
    ) {
        switch NotificationActionIdentifier(rawValue: response.actionIdentifier) {
        case .authorize: presenter.handleAuthorization()
        case .continueToApp: completion(.dismissAndForwardAction)
        case .authorizeInApp: completion(.dismissAndForwardAction)
        default: completion(.dismiss)
        }
    }
}

extension NotificationViewController: NotificationViewControlling {
    func displaySuccess() {
        notificationView.setText(header: T.Extension.requestSent, content: nil)
        extensionContext?.notificationActions = [
            .init(
                identifier: NotificationActionIdentifier.dismiss.rawValue,
                title: NotificationActionIdentifier.dismiss.localized,
                options: [],
                icon: UNNotificationActionIcon(systemImageName: NotificationActionIdentifier.dismiss.icon)
            )
        ]
    }
    
    func displayQuestion(domain: String, extensionName: String) {
        notificationView.setText(header: T.Extension.sendQuestionTitle, domain: domain, extensionName: extensionName)
        extensionContext?.notificationActions = [
            .init(
                identifier: NotificationActionIdentifier.authorize.rawValue,
                title: NotificationActionIdentifier.authorize.localized,
                options: .authenticationRequired,
                icon: UNNotificationActionIcon(systemImageName: NotificationActionIdentifier.authorize.icon)
            ),
            .init(
                identifier: NotificationActionIdentifier.cancel.rawValue,
                title: NotificationActionIdentifier.cancel.localized,
                options: [],
                icon: UNNotificationActionIcon(systemImageName: NotificationActionIdentifier.cancel.icon)
            )
        ]
    }
    
    func displayQuestionForwardToApp(domain: String, extensionName: String) {
        notificationView.setText(header: T.Extension.sendQuestionTitle, domain: domain, extensionName: extensionName)
        extensionContext?.notificationActions = [
            .init(
                identifier: NotificationActionIdentifier.authorizeInApp.rawValue,
                title: NotificationActionIdentifier.authorizeInApp.localized,
                options: .foreground,
                icon: UNNotificationActionIcon(systemImageName: NotificationActionIdentifier.authorizeInApp.icon)
            ),
            .init(
                identifier: NotificationActionIdentifier.cancel.rawValue,
                title: NotificationActionIdentifier.cancel.localized,
                options: [],
                icon: UNNotificationActionIcon(systemImageName: NotificationActionIdentifier.cancel.icon)
            )
        ]
    }
    
    func displayError(_ error: NotificationViewError) {
        notificationView.setText(header: T.Extension.errorWhileSending, content: "\(error.localizedDescription)")
        extensionContext?.notificationActions = [
            .init(
                identifier: NotificationActionIdentifier.continueToApp.rawValue,
                title: NotificationActionIdentifier.continueToApp.localized,
                options: .foreground,
                icon: UNNotificationActionIcon(systemImageName: NotificationActionIdentifier.continueToApp.icon)
            )
        ]
    }
    
    func displayNotPaired() {
        notificationView.setText(header: T.Extension.notPairedTitle, content: T.Extension.notPairedContent)
        extensionContext?.notificationActions = [
            .init(
                identifier: NotificationActionIdentifier.continueToApp.rawValue,
                title: NotificationActionIdentifier.continueToApp.localized,
                options: .foreground,
                icon: UNNotificationActionIcon(systemImageName: NotificationActionIdentifier.continueToApp.icon)
            )
        ]
    }
    
    func displayNoServices() {
        notificationView.setText(header: T.Extension.error, content: T.Extension.errorNoServices)
        extensionContext?.notificationActions = [
            .init(
                identifier: NotificationActionIdentifier.continueToApp.rawValue,
                title: NotificationActionIdentifier.continueToApp.localized,
                options: .foreground,
                icon: UNNotificationActionIcon(systemImageName: NotificationActionIdentifier.continueToApp.icon)
            )
        ]
    }
}
