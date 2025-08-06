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

import Foundation
import ZIPFoundation
import Common

public protocol CompressionInteracting: AnyObject {
    func zipFiles(_ files: [URL], into fileName: String) async -> URL?
}

final class CompressionInteractor {
    private let fileManager = FileManager.default
}

extension CompressionInteractor: CompressionInteracting {
    func zipFiles(_ files: [URL], into fileName: String) async -> URL? {
        let archiveURL = URL(
            fileURLWithPath: fileManager.temporaryDirectory.appendingPathComponent("\(fileName).zip").path()
        )
        
        do {
            let archive = try Archive(url: archiveURL, accessMode: .create)
            for fileURL in files {
                try archive
                    .addEntry(
                        with: fileURL.lastPathComponent,
                        relativeTo: fileURL.deletingLastPathComponent(),
                        compressionMethod: .deflate
                    )
            }
        } catch {
            Log("CompressionInteractor: Can't create archive. Error: \(error)")
            return nil
        }
        
        return archiveURL
    }
}
