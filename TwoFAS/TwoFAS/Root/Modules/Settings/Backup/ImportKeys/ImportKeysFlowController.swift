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
import UniformTypeIdentifiers
import Common

protocol ImportKeysFlowControllerParent: AnyObject {
    func importKeysDidFinish(success: Bool)
    func importKeysDidCancel()
}

final class ImportKeysFlowController: FlowController {
    private weak var parent: ImportKeysFlowControllerParent?
    private var interactor: ImportKeysModuleInteracting!
    private var showWarning = true
    private var pickerDelegate: ImportKeysDocumentPickerDelegate?

    static func make(
        presentingOn viewController: UIViewController,
        parent: ImportKeysFlowControllerParent,
        showWarning: Bool
    ) -> ImportKeysFlowController {
        let flowController = ImportKeysFlowController(viewController: viewController)
        flowController.parent = parent
        flowController.interactor = ModuleInteractorFactory.shared.importKeysModuleInteractor()
        flowController.showWarning = showWarning
        return flowController
    }

    func start() {
        if showWarning {
            toWarning { [weak self] in self?.askEncryptionType() }
        } else {
            askEncryptionType()
        }
    }
}

private extension ImportKeysFlowController {
    func askEncryptionType() {
        toAskEncryptionType { [weak self] type in
            switch type {
            case .systemKey:
                self?.pickFile(password: nil)
            case .customPassword:
                self?.toCollectPassword { [weak self] password in
                    self?.pickFile(password: password)
                }
            }
        }
    }

    func pickFile(password: String?) {
        toDocumentPicker { [weak self] url in
            self?.runImport(url: url, password: password)
        }
    }

    func runImport(url: URL, password: String?) {
        interactor.importKeys(url: url, password: password) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.parent?.importKeysDidFinish(success: true)
            case .failure:
                self.toKeysImportError()
                self.parent?.importKeysDidFinish(success: false)
            }
        }
    }
}

private extension ImportKeysFlowController {
    func toWarning(confirm: @escaping () -> Void) {
        guard let vc = _viewController else { return }
        let alert = UIAlertController(
            title: T.Backup.cloudBackup,
            message: T.Backup.keysImportWarning,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.cancel, style: .cancel) { [weak self] _ in
            self?.parent?.importKeysDidCancel()
        })
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .destructive) { _ in confirm() })
        vc.present(alert, animated: true)
    }

    func toAskEncryptionType(completion: @escaping (ImportKeysEncryptionType) -> Void) {
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
        alert.addAction(UIAlertAction(title: T.Commons.cancel, style: .cancel) { [weak self] _ in
            self?.parent?.importKeysDidCancel()
        })
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

    func toCollectPassword(completion: @escaping (String) -> Void) {
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
        alert.addAction(UIAlertAction(title: T.Commons.cancel, style: .cancel) { [weak self] _ in
            self?.parent?.importKeysDidCancel()
        })
        alert.addAction(UIAlertAction(title: T.Commons.apply, style: .default) { _ in
            let password = alert.textFields?.first?.text ?? ""
            completion(password)
        })
        vc.present(alert, animated: true)
    }

    func toDocumentPicker(completion: @escaping (URL) -> Void) {
        guard let vc = _viewController else { return }
        let delegate = ImportKeysDocumentPickerDelegate(completion: completion) { [weak self] cancelled in
            self?.pickerDelegate = nil
            if cancelled {
                self?.parent?.importKeysDidCancel()
            }
        }
        pickerDelegate = delegate
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.data, .item])
        picker.delegate = delegate
        picker.allowsMultipleSelection = false
        vc.present(picker, animated: true)
    }

    func toKeysImportError() {
        guard let vc = _viewController else { return }
        let alert = UIAlertController(
            title: T.Commons.error,
            message: T.Backup.keysImportError,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .default))
        vc.present(alert, animated: true)
    }
}

private final class ImportKeysDocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
    private let completion: (URL) -> Void
    private let onDone: (_ cancelled: Bool) -> Void

    init(completion: @escaping (URL) -> Void, onDone: @escaping (_ cancelled: Bool) -> Void) {
        self.completion = completion
        self.onDone = onDone
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        controller.dismiss(animated: true)
        onDone(false)
        completion(url)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        onDone(true)
    }
}
