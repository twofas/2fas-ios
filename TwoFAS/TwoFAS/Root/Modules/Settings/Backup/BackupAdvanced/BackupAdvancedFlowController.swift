//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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
import UniformTypeIdentifiers
import Common

protocol BackupAdvancedFlowControllerParent: AnyObject {}

protocol BackupAdvancedFlowControlling: AnyObject {
    func toDeleteBackup()
    func toExportKeys(url: URL)
    func toKeysError(_ message: String)
    func toImportKeysWarning(confirm: @escaping () -> Void)
    func toAskEncryptionTypeForImport(completion: @escaping (BackupAdvancedImportEncryptionType) -> Void)
    func toCollectPasswordForImport(completion: @escaping (String) -> Void)
    func toImportKeys(completion: @escaping (URL) -> Void)
    func importKeysSuccess()
    func toKeysImportError()
}

final class BackupAdvancedFlowController: FlowController {
    private weak var parent: BackupAdvancedFlowControllerParent?
    private var navigationController: UINavigationController? { _viewController?.navigationController }
    private var importKeysPickerDelegateHandler: BackupAdvancedImportKeysDocumentPickerDelegate?

    static func push(
        in navigationController: UINavigationController,
        parent: BackupAdvancedFlowControllerParent
    ) {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        hosting.hidesBottomBarWhenPushed = false
        let flowController = BackupAdvancedFlowController(viewController: hosting)
        flowController.parent = parent
        let presenter = BackupAdvancedPresenter(
            flowController: flowController,
            interactor: ModuleInteractorFactory.shared.backupAdvancedModuleInteractor()
        )
        hosting.rootView = AnyView(BackupAdvancedView(presenter: presenter))

        navigationController.pushViewController(hosting, animated: true)
    }
}

extension BackupAdvancedFlowController: BackupAdvancedFlowControlling {
    func toDeleteBackup() {
        guard let vc = _viewController else { return }
        BackupDeleteFlowController.present(on: vc, parent: self)
    }

    func toExportKeys(url: URL) {
        guard let vc = _viewController else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = vc.view
            popover.sourceRect = CGRect(
                x: vc.view.bounds.midX,
                y: vc.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        vc.present(activityVC, animated: true)
    }

    func toKeysError(_ message: String) {
        guard let vc = _viewController else { return }
        let alert = UIAlertController(title: T.Commons.error, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .default))
        vc.present(alert, animated: true)
    }

    func toImportKeysWarning(confirm: @escaping () -> Void) {
        guard let vc = _viewController else { return }
        let alert = UIAlertController(
            title: T.Backup.cloudBackup,
            message: T.Backup.keysImportWarning,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .destructive) { _ in confirm() })
        vc.present(alert, animated: true)
    }

    func toAskEncryptionTypeForImport(completion: @escaping (BackupAdvancedImportEncryptionType) -> Void) {
        guard let vc = _viewController else { return }
        let alert = UIAlertController(
            title: T.Backup.encryptionTitle,
            message: T.Backup.encryptionMethodFooter,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: T.Backup.keyImportSystemKey, style: .default) { _ in
            completion(.systemKey)
        })
        alert.addAction(UIAlertAction(title: T.Backup.customPassword, style: .default) { _ in
            completion(.customPassword)
        })
        alert.addAction(UIAlertAction(title: T.Commons.cancel, style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = vc.view
            popover.sourceRect = CGRect(
                x: vc.view.bounds.midX,
                y: vc.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        vc.present(alert, animated: true)
    }

    func toCollectPasswordForImport(completion: @escaping (String) -> Void) {
        guard let vc = _viewController else { return }
        let alert = UIAlertController(
            title: T.Backup.enterPasswordDialogTitle,
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = T.Backup.password
        }
        alert.addAction(UIAlertAction(title: T.Commons.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: T.Commons.apply, style: .default) { _ in
            let password = alert.textFields?.first?.text ?? ""
            completion(password)
        })
        vc.present(alert, animated: true)
    }

    func toImportKeys(completion: @escaping (URL) -> Void) {
        guard let vc = _viewController else { return }
        let delegate = BackupAdvancedImportKeysDocumentPickerDelegate(completion: completion) { [weak self] in
            self?.importKeysPickerDelegateHandler = nil
        }
        importKeysPickerDelegateHandler = delegate
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.data, .item])
        picker.delegate = delegate
        picker.allowsMultipleSelection = false
        vc.present(picker, animated: true)
    }

    func importKeysSuccess() {
        guard let vc = _viewController else { return }
        let alert = UIAlertController(
            title: nil,
            message: T.Commons.done,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .default))
        vc.present(alert, animated: true)
    }

    func toKeysImportError() {
        toKeysError(T.Backup.keysImportError)
    }
}

extension BackupAdvancedFlowController: BackupDeleteFlowControllerParent {
    func closeDeleteBackup(didDelete: Bool) {
        _viewController?.dismiss(animated: true)
        if didDelete {
            navigationController?.popViewController(animated: true)
        }
    }
}

private final class BackupAdvancedImportKeysDocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
    private let completion: (URL) -> Void
    private let onDone: () -> Void
    init(completion: @escaping (URL) -> Void, onDone: @escaping () -> Void) {
        self.completion = completion
        self.onDone = onDone
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        controller.dismiss(animated: true)
        onDone()
        completion(url)
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        onDone()
    }
}
