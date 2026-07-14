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
import Data

protocol ImporterPreimportSummaryModuleInteracting: AnyObject {
    var countNew: Int { get }
    var countTotal: Int { get }
    func importFromFile() -> Int
}

final class ImporterPreimportSummaryModuleInteractor {
    private let importInteractor: ImportFromFileInteracting
    let countNew: Int
    let countTotal: Int
    private let sections: [CommonSectionData]
    private let services: [ServiceData]
    
    init(
        importInteractor: ImportFromFileInteracting,
        countNew: Int,
        countTotal: Int,
        sections: [CommonSectionData],
        services: [ServiceData]
    ) {
        self.importInteractor = importInteractor
        self.countNew = countNew
        self.countTotal = countTotal
        self.sections = sections
        self.services = services
    }
}

extension ImporterPreimportSummaryModuleInteractor: ImporterPreimportSummaryModuleInteracting {
    func importFromFile() -> Int {
        importInteractor.importServices(services, sections: sections)
    }
}
