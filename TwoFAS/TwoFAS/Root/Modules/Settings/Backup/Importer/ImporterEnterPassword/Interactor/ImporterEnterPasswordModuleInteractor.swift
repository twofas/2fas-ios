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
import Common

protocol ImporterEnterPasswordModuleInteracting: AnyObject {
    func openFile(with password: String) -> ImportFromFileTwoFASDecrypt
    func parseFile(with decryptedServices: ExchangeDataServices) -> (
        countNew: Int,
        countTotal: Int,
        sections: [CommonSectionData],
        services: [ServiceData]
    )
}

// MARK: - 

final class ImporterEnterPasswordModuleInteractor {
    private let importInteractor: ImportFromFileInteracting
    private let data: ExchangeDataFormat
    
    init(importInteractor: ImportFromFileInteracting, data: ExchangeDataFormat) {
        self.importInteractor = importInteractor
        self.data = data
    }
}

extension ImporterEnterPasswordModuleInteractor: ImporterEnterPasswordModuleInteracting {
    func openFile(with password: String) -> ImportFromFileTwoFASDecrypt {
        importInteractor.decryptTwoFAS(data, password: password)
    }
    
    func parseFile(with decryptedServices: ExchangeDataServices) -> (
        countNew: Int,
        countTotal: Int,
        sections: [CommonSectionData],
        services: [ServiceData]
    ) {
        let sections = importInteractor.parseSectionsTwoFAS(data)
        let services = importInteractor.parseTwoFASServices(with: decryptedServices, sections: sections)
        let countNew = importInteractor.countNewServices(services)
        return (countNew: countNew, countTotal: services.count, sections: sections, services: services)
    }
}
