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
import Storage
import Common
import CodeSupport

enum OpenError: Error {
    case cantReadFile(reason: String?)
}

extension MainRepositoryImpl {
    func countNewServices(from services: [ServiceData]) -> Int {
        service.countNewServices(from: services)
    }
    
    func importServices(_ services: [ServiceData], sections: [CommonSectionData]) -> Int {
        sectionHandler.addNonexistentSections(sections)
        return service.addNonexistentServices(services)
    }

    func openFile(url: URL, completion: @escaping (Result<Data, OpenError>) -> Void) {
        do {
            var data: Data?
            if url.startAccessingSecurityScopedResource() {
                var error: NSError?
                NSFileCoordinator().coordinate(readingItemAt: url, options: [.withoutChanges], error: &error) { url in
                    do {
                        data = try Data(contentsOf: url)
                    } catch {
                        url.stopAccessingSecurityScopedResource()
                        completion(.failure(.cantReadFile(reason: error.localizedDescription)))
                        return
                    }
                }
                url.stopAccessingSecurityScopedResource()
            } else {
                data = try Data(contentsOf: url)
            }
            
            guard let data else {
                completion(.failure(.cantReadFile(reason: nil)))
                return
            }
            
            completion(.success(data))
        } catch {
            Log("Can't import data from file: \(url), error: \(error)")
            completion(.failure(.cantReadFile(reason: error.localizedDescription)))
            return
        }
    }
}
