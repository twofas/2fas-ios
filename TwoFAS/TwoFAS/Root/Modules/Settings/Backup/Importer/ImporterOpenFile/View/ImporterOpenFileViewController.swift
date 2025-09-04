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
import Common

final class ImporterOpenFileViewController: UIDocumentPickerViewController {
    var handleCantReadFile: Callback?
    var handleFileOpen: ((URL) -> Void)?
    var handleCancelFileOpen: Callback?
    
    override init(forOpeningContentTypes contentTypes: [UTType]?, asCopy: Bool) {
        var supportedTypes: [UTType] = [
            UTType.json,
            UTType.text,
            UTType(filenameExtension: "2fas", conformingTo: UTType.json),
            UTType(filenameExtension: "bak", conformingTo: UTType.json)
        ].compactMap({ $0 })
        if let mime = UTType(mimeType: "application/2fas-backup-bak"),
           let type = UTType(filenameExtension: "bak", conformingTo: mime) {
            supportedTypes.append(type)
        }
        if let mime = UTType(mimeType: "application/2fas-backup-2fas"),
           let type = UTType(filenameExtension: "2fas", conformingTo: mime) {
            supportedTypes.append(type)
        }
        super.init(forOpeningContentTypes: supportedTypes, asCopy: false)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        shouldShowFileExtensions = true
        allowsMultipleSelection = false
        delegate = self
    }
}

extension ImporterOpenFileViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            handleCantReadFile?()
            return
        }
        handleFileOpen?(url)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        handleCancelFileOpen?()
    }
}
