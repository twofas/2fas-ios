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
import Common
import Storage
import Data

enum SelectFromGalleryModuleInteractorScanResult {
    case noCodes
    case scanError
    case codeTypes(codeTypes: [CodeType])
}

protocol SelectFromGalleryModuleInteracting: AnyObject {
    var serviceWasCreated: ((ServiceData) -> Void)? { get set }
    var shouldRename: ((String, String) -> Void)? { get set }
    
    func scanImage(_ image: UIImage, completion: @escaping(SelectFromGalleryModuleInteractorScanResult) -> Void)
    func addSelectedCode(_ code: Code)
    func addSelectedCodes(_ codes: [Code])
    func codeExists(_ code: Code) -> Bool
    func codeUsedIn(_ code: Code) -> String
    func filterImportableCodes(_ codes: [Code]) -> [Code]
    
    func renameService(newName: String, secret: String)
    func cancelRenaming(secret: String)
}

final class SelectFromGalleryModuleInteractor {
    private let scanInteractor: ScanInteracting
    private let newCodeInteractor: NewCodeInteracting
    
    var serviceWasCreated: ((ServiceData) -> Void)?
    var shouldRename: ((String, String) -> Void)?
    
    init(scanInteractor: ScanInteracting, newCodeInteractor: NewCodeInteracting) {
        self.scanInteractor = scanInteractor
        self.newCodeInteractor = newCodeInteractor
        
        newCodeInteractor.serviceWasCreated = { [weak self] in self?.serviceWasCreated?($0) }
        newCodeInteractor.shouldRename = { [weak self] in self?.shouldRename?($0, $1) }
    }
}

extension SelectFromGalleryModuleInteractor: SelectFromGalleryModuleInteracting {
    func scanImage(_ image: UIImage, completion: @escaping (SelectFromGalleryModuleInteractorScanResult) -> Void) {
        scanInteractor.scan(image: image) { [weak self] result in
            switch result {
            case .success(let codeStrings):
                Log(
                    "SelectFromGalleryModuleInteractor - scanInteractor. Success",
                    module: .moduleInteractor
                )
                self?.handleCodes(codeStrings, completion: completion)
            case .failure(let error):
                Log(
                    "SelectFromGalleryModuleInteractor - scanInteractor. Failure. Error: \(error)",
                    module: .moduleInteractor
                )
                switch error {
                case .scanError:
                    completion(.scanError)
                case .noCodesFound:
                    completion(.noCodes)
                }
            }
        }
    }
    
    private func handleCodes(
        _ codeStrings: [String],
        completion: @escaping (SelectFromGalleryModuleInteractorScanResult) -> Void
    ) {
        let codes: [CodeType] = codeStrings.map({ Code.parse(with: $0) })
        
        guard !codes.isEmpty else {
            Log("No codes found", module: .camera)
            completion(.noCodes)
            return
        }
        
        Log("Found some code types. Count: \(codes.count)", module: .camera)
        completion(.codeTypes(codeTypes: codes))
    }
    
    func addSelectedCode(_ code: Code) {
        Log("Selected code: \(code)", module: .camera)
        newCodeInteractor.addCode(code)
    }
    
    func addSelectedCodes(_ codes: [Code]) {
        newCodeInteractor.addCodes(codes)
    }
    
    func codeExists(_ code: Code) -> Bool {
        newCodeInteractor.codeExists(code)
    }
    
    func codeUsedIn(_ code: Code) -> String {
        newCodeInteractor.service(for: code.secret)?.summarizeDescription ?? ""
    }
    
    func filterImportableCodes(_ codes: [Code]) -> [Code] {
        newCodeInteractor.filterImportableCodes(codes)
    }
    
    func renameService(newName: String, secret: String) {
        newCodeInteractor.renameService(newName: newName, secret: secret)
    }
    
    func cancelRenaming(secret: String) {
        newCodeInteractor.cancelRenaming(secret: secret)
    }
}
