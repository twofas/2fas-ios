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

import Foundation
import MessageUI
import Common

final class SettingsScreenSendLogs: NSObject {
    private let exporter: LogExporterController
    private let appSummary: AppSummaryDataController
    
    init(exporter: LogExporterController, appSummary: AppSummaryDataController) {
        self.exporter = exporter
        self.appSummary = appSummary
    }
    
    func sendEmail(completion: @escaping (UIViewController) -> Void) {
        exporter.export { [weak self] value in
            guard let value else {
                let alert = UIAlertController(
                    title: T.InternalDebug.errorCreatingLogsTitle,
                    message: T.InternalDebug.errorCreatingLogsContent,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: T.Commons.OK, style: .cancel, handler: nil))
                completion(alert)
                return
            }
            guard let vc = self?.prepareForPresentation(with: value) else { return }
            completion(vc)
        }
    }
    
    private func prepareForPresentation(with attachment: Data) -> UIViewController {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(
                title: T.Settings.mailServicesNotAvailable,
                message: T.InternalDebug.logsWereCopiedToTheClipboard,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: T.Commons.OK, style: .cancel, handler: nil))
            return alert
        }

        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([Config.technicalEmail])
        composeVC.setSubject(T.InternalDebug.mailSubject)
        composeVC.setMessageBody(appSummary.summarize(), isHTML: false)
        composeVC.addAttachmentData(attachment, mimeType: "application/twofaslog", fileName: "logs.twofaslog")

        return composeVC
    }
}

extension SettingsScreenSendLogs: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true, completion: nil)
    }
}
