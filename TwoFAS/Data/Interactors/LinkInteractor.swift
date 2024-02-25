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

public protocol LinkInteracting: AnyObject {
    var hasStoredURL: Bool { get }
    var showCodeAlreadyExists: Callback? { get set }
    var showIncorrectCode: Callback? { get set }
    var showShouldAddCode: ((String?) -> Void)? { get set }
    var showSendLogs: ((UUID) -> Void)? { get set }
    var reloadDataAndRefresh: Callback? { get set }
    var shouldRename: ((String, String) -> Void)? { get set }
    var serviceWasCreated: ((ServiceData) -> Void)? { get set }
    
    func shouldHandleURL(url: URL) -> Bool
    func handleURLIfNecessary()
    func addStoredCode()
    func clearStoredCode()
    
    func renameService(newName: String, secret: String)
    func cancelRenaming(secret: String)
}

final class LinkInteractor {
    private let mainRepository: MainRepository
    private let interactorNew: NewCodeInteracting
    
    var showCodeAlreadyExists: Callback?
    var showIncorrectCode: Callback?
    var showShouldAddCode: ((String?) -> Void)?
    var showSendLogs: ((UUID) -> Void)?
    var reloadDataAndRefresh: Callback?
    var shouldRename: ((String, String) -> Void)?
    var serviceWasCreated: ((ServiceData) -> Void)?
    
    init(mainRepository: MainRepository, interactorNew: NewCodeInteracting) {
        self.mainRepository = mainRepository
        self.interactorNew = interactorNew
        
        interactorNew.shouldRename = { [weak self] in self?.shouldRename?($0, $1) }
        interactorNew.serviceWasCreated = { [weak self] in self?.serviceWasCreated?($0) }
    }
}

extension LinkInteractor: LinkInteracting {
    var hasStoredURL: Bool {
        mainRepository.hasStoredURL()
    }
    
    func shouldHandleURL(url: URL) -> Bool {
        Log("LinkInteractor - shouldHandleURL", module: .interactor)
        Log("URL: \(url)", module: .interactor, save: false)
        
        guard mainRepository.shouldHandleURL(url) else {
            mainRepository.saveHasIncorrectCode()
            Log("LinkInteractor - shouldHandleURL - won't handle", module: .interactor)
            return false
        }
        Log("LinkInteractor - shouldHandleURL - storing URL", module: .interactor)
        mainRepository.storeURL(url)
        return true
    }
    
    func handleURLIfNecessary() {
        Log("LinkInteractor - handleCodeIfNecessary", module: .interactor)
        guard hasStoredURL else {
            Log("LinkInteractor - handleCodeIfNecessary - no url", module: .interactor)
            if mainRepository.hasIncorrectCode {
                Log("LinkInteractor - hasIncorrectCode", module: .interactor)
                mainRepository.clearHasIncorrectCode()
                showIncorrectCode?()
            }
            return
        }
        
        guard let codeType = mainRepository.codeTypeFromStoredURL() else {
            Log("LinkInteractor - handleCodeIfNecessary - no code type - extiting", module: .interactor)
            mainRepository.clearStoredURL()
            return
        }
        
        switch codeType {
        case .service(let code):
            Log("LinkInteractor - handleCodeIfNecessary - no code", module: .interactor)
            handleCode(code)
        case .support(let auditID):
            Log("LinkInteractor - handleCodeIfNecessary - isSupport link!", module: .interactor)
            mainRepository.clearStoredURL()
            showSendLogs?(auditID)
            return
        default:
            Log("LinkInteractor - handleCodeIfNecessary - not supported type - exiting", module: .interactor)
            mainRepository.clearStoredURL()
            showIncorrectCode?()
            return
        }
    }
    
    func addStoredCode() {
        Log("LinkInteractor - addStoredCode", module: .interactor)
        
        guard let code = mainRepository.codeFromStoredURL() else {
            Log("LinkInteractor - addStoredCode - no code", module: .interactor)
            return
        }
        interactorNew.addCode(code, force: false)
        reloadDataAndRefresh?()
        Log("LinkInteractor - addStoredCode. Adding", module: .interactor)
        clearStoredCode()
    }
    
    func clearStoredCode() {
        Log("LinkInteractor - clearStoredCode", module: .interactor)
        mainRepository.clearStoredURL()
    }
    
    func renameService(newName: String, secret: String) {
        Log("LinkInteractor - renameService", module: .interactor)
        interactorNew.renameService(newName: newName, secret: secret)
        reloadDataAndRefresh?()
    }
    
    func cancelRenaming(secret: String) {
        Log("LinkInteractor - cancelRenaming", module: .interactor)
        interactorNew.cancelRenaming(secret: secret)
    }
}

private extension LinkInteractor {
    func handleCode(_ code: Code) {
        guard !interactorNew.codeExists(code) else {
            Log("LinkInteractor - handleCodeIfNecessary - already exists", module: .interactor)
            showCodeAlreadyExists?()
            return
        }
        
        Log("LinkInteractor - shandleCodeIfNecessary - showShouldAddCode", module: .interactor)
        
        showShouldAddCode?(code.summarizeDescription)
    }
}
