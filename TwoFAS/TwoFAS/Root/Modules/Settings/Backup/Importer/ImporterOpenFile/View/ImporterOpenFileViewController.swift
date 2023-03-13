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
import UniformTypeIdentifiers

final class ImporterOpenFileViewController: UIDocumentBrowserViewController {
    var presenter: ImporterOpenFilePresenter?
    
    override init(forOpening contentTypes: [UTType]?) {
        super.init(forOpening: contentTypes)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        allowsDocumentCreation = false
        allowsPickingMultipleItems = false
        shouldShowFileExtensions = true
        delegate = self
        additionalTrailingNavigationBarButtonItems = [
            UIBarButtonItem(
                title: T.Commons.cancel,
                style: .plain,
                target: self,
                action: #selector(cancelImportAction)
            )
        ]
        UINavigationBar.appearance(whenContainedInInstancesOf: [
            UIDocumentBrowserViewController.self
        ]).tintColor = Theme.Colors.Text.theme
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter = nil
    }
    
    @objc
    private func cancelImportAction() {
        presenter?.handleCancelFileOpen()
    }
}

extension ImporterOpenFileViewController: UIDocumentBrowserViewControllerDelegate {
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let url = documentURLs.first else {
            presenter?.handleCantReadFile()
            return
        }
        presenter?.handleFileOpen(url)
    }
}
