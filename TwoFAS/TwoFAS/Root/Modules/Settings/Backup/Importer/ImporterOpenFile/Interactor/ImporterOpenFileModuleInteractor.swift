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
import CodeSupport

protocol ImporterOpenFileModuleInteracting: AnyObject {
    var url: URL? { get }
    
    func openFile(_ url: URL, completion: @escaping (Result<Data, ImportFromFileError>) -> Void)
    func parseContent(_ data: Data) -> ImportFromFileParsing?
    //
    func checkTwoFAS(_ data: ExchangeDataFormat) -> ImportFromFileTwoFASCheck
    func parseSectionsTwoFAS(_ data: ExchangeDataFormat) -> [CommonSectionData]
    func parseTwoFASServices(with services: ExchangeDataServices, sections: [CommonSectionData]) -> [ServiceData]
    //
    func countNewServices(_ services: [ServiceData]) -> Int
    func parseAEGIS(_ data: AEGISData) -> [ServiceData]
    func parseLastPass(_ data: LastPassData) -> [ServiceData]
}

final class ImporterOpenFileModuleInteractor {
    private let importInteractor: ImportFromFileInteracting
    
    let url: URL?
    
    init(importInteractor: ImportFromFileInteracting, url: URL?) {
        self.importInteractor = importInteractor
        self.url = url
    }
}

extension ImporterOpenFileModuleInteractor: ImporterOpenFileModuleInteracting {
    func openFile(_ url: URL, completion: @escaping (Result<Data, ImportFromFileError>) -> Void) {
        importInteractor.openFile(url, completion: completion)
    }
    
    func parseContent(_ data: Data) -> ImportFromFileParsing? {
        importInteractor.parseContent(data)
    }
    
    // MARK: -
    
    func checkTwoFAS(_ data: ExchangeDataFormat) -> ImportFromFileTwoFASCheck {
        importInteractor.checkTwoFAS(data)
    }
    
    func parseSectionsTwoFAS(_ data: ExchangeDataFormat) -> [CommonSectionData] {
        importInteractor.parseSectionsTwoFAS(data)
    }
    
    func parseTwoFASServices(with services: ExchangeDataServices, sections: [CommonSectionData]) -> [ServiceData] {
        importInteractor.parseTwoFASServices(with: services, sections: sections)
    }
    
    // MARK: -
    
    func countNewServices(_ services: [ServiceData]) -> Int {
        importInteractor.countNewServices(services)
    }
    
    func parseAEGIS(_ data: AEGISData) -> [ServiceData] {
        importInteractor.parseAEGIS(data)
    }
    
    func parseLastPass(_ data: LastPassData) -> [ServiceData] {
        importInteractor.parseLastPass(data)
    }
}
