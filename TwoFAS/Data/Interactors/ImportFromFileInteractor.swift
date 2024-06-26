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
import Protection

public enum ImportFromFileError: Error {
    case cantReadFile(reason: String?)
}

public enum ImportFromFileParsing {
    public enum AEGISParseResult {
        case error
        case encrypted
        case success(AEGISData)
    }
    public enum LastPassResult {
        case success(LastPassData)
    }
    case twoFAS(ExchangeDataFormat)
    case aegis(AEGISParseResult)
    case lastPass(LastPassResult)
    case raivo([RaivoData])
    case andOTP([AndOTPData])
    case authenticatorPro([Code])
}

public enum ImportFromFileTwoFASCheck {
    case newerSchema
    case encrypted
    case unencrypted
}

public enum ImportFromFileAEGISParse {
    case newerSchema
    case encrypted
    case error
    case success([ServiceData])
}

public enum ImportFromFileTwoFASDecrypt {
    case success(ExchangeDataServices)
    case wrongPassword
    case cantReadFile
}

public enum ImportFromFileAuthenticatorPro {
    case success([Code])
    case cantReadFile
}

public protocol ImportFromFileInteracting: AnyObject {
    func openFile(_ url: URL, completion: @escaping (Result<Data, ImportFromFileError>) -> Void)
    func parseContent(_ data: Data) -> ImportFromFileParsing?
    //
    func checkTwoFAS(_ data: ExchangeDataFormat) -> ImportFromFileTwoFASCheck
    func decryptTwoFAS(_ data: ExchangeDataFormat, password: String) -> ImportFromFileTwoFASDecrypt
    func parseSectionsTwoFAS(_ data: ExchangeDataFormat) -> [CommonSectionData]
    func parseTwoFASServices(with services: ExchangeDataServices, sections: [CommonSectionData]) -> [ServiceData]
    //
    func countNewServices(_ services: [ServiceData]) -> Int
    func importServices(_ services: [ServiceData], sections: [CommonSectionData]) -> Int
    func parseAEGIS(_ data: AEGISData) -> [ServiceData]
    func parseLastPass(_ data: LastPassData) -> [ServiceData]
    func parseRaivo(_ data: [RaivoData]) -> [ServiceData]
    func parseAndOTP(_ data: [AndOTPData]) -> [ServiceData]
    func parseAuthenticatorPro(_ data: [Code]) -> [ServiceData]
}

final class ImportFromFileInteractor {
    private let mainRepository: MainRepository
    let jsonDecoder = JSONDecoder()
    let serviceDefinitionInteractor: ServiceDefinitionInteracting
    let modifyInteractor: ServiceModifyInteracting
    
    init(
        mainRepository: MainRepository,
        serviceDefinitionInteractor: ServiceDefinitionInteracting,
        modifyInteractor: ServiceModifyInteracting
    ) {
        self.mainRepository = mainRepository
        self.serviceDefinitionInteractor = serviceDefinitionInteractor
        self.modifyInteractor = modifyInteractor
    }
}

extension ImportFromFileInteractor: ImportFromFileInteracting {
    func openFile(_ url: URL, completion: @escaping (Result<Data, ImportFromFileError>) -> Void) {
        Log("ImportFromFileInteractor - open file, url: \(url)", module: .interactor)
        mainRepository.openFile(url: url) { result in
            switch result {
            case .success(let data): completion(.success(data))
            case .failure(let error):
                switch error {
                case .cantReadFile(let reason): completion(.failure(.cantReadFile(reason: reason)))
                }
            }
        }
    }
    
    func parseContent(_ data: Data) -> ImportFromFileParsing? {
        Log("ImportFromFileInteractor - parseContent", module: .interactor)
        if let services = try? jsonDecoder.decode(ExchangeData2.self, from: data),
           services.schemaVersion == ExchangeConsts.schemaVersionV3 ||
            services.schemaVersion == ExchangeConsts.schemaVersionV4 {
            return .twoFAS(.twoFASV34(services))
        }
        
        if let services = try? jsonDecoder.decode(ExchangeData.self, from: data) {
            return .twoFAS(.twoFAS(services))
        }

        if let lastPass = try? jsonDecoder.decode(LastPassData.self, from: data) {
            return .lastPass(.success(lastPass))
        }
        
        if let raivo = try? jsonDecoder.decode([RaivoData].self, from: data) {
            return .raivo(raivo)
        }
        
        if let andOTP = try? jsonDecoder.decode([AndOTPData].self, from: data) {
            return .andOTP(andOTP)
        }
        
        let authenticatorPro = importFromAuthenticatorProFileFormat(data)
        if case ImportFromFileAuthenticatorPro.success(let list) = authenticatorPro {
            return .authenticatorPro(list)
        }
        
        do {
            let services = try jsonDecoder.decode(AEGISData.self, from: data)
            return .aegis(.success(services))
        } catch {
            guard let error = error as? AEGISDataParseError else {
                return nil
            }
            switch error {
            case .encrypted: return .aegis(.encrypted)
            case .error: return .aegis(.error)
            }
        }
    }
    
    func countNewServices(_ services: [ServiceData]) -> Int {
        let value = mainRepository.countNewServices(from: services)
        Log("ImportFromFileInteractor - countNewServices: \(value)", module: .interactor)
        return value
    }
    
    func importServices(_ services: [ServiceData], sections: [CommonSectionData]) -> Int {
        mainRepository.importServices(services, sections: sections)
    }
}

private extension AEGISData.Entry.Info.Algo {
    var toAlgoritm: Algorithm {
        switch self {
        case .sha1: return .SHA1
        case .sha256: return .SHA256
        case .sha512: return .SHA512
        }
    }
}

private extension AEGISData.Entry.EntryType {
    var toTokenType: TokenType {
        switch self {
        case .hotp: return .hotp
        case .totp: return .totp
        case .steam: return .steam
        }
    }
}
