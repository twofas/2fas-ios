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

protocol FileInteracting: AnyObject {
    var url: URL? { get }
    
    func shouldHandleURL(url: URL) -> Bool
    func markAsHandled()
}

final class FileIteractor {
    private let mainRepository: MainRepository
        
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension FileIteractor: FileInteracting {
    var url: URL? { mainRepository.fileURL }
    
    func shouldHandleURL(url: URL) -> Bool {
        guard
            url.pathExtension == ExchangeConsts.extension ||
            url.pathExtension == ExchangeConsts.extensionV2 ||
            url.pathExtension == ExchangeConsts.extensionAEGIS
        else { return false }
        mainRepository.fileURL = url
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .fileAwaitsOpening, object: nil)
        }
        return true
    }
    
    func markAsHandled() {
        mainRepository.fileURL = nil
    }
}
