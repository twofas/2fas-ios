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

public protocol NewVersionInteracting: AnyObject {
    var checkEnabled: Bool { get }
    var appStoreURL: URL? { get }
    
    func checkForNewVersion(completion: @escaping (Bool) -> Void)
    func userSkippedVersion()
    func setCheckEnabled(_ enabled: Bool)
}

final class NewVersionInteractor {
    private let firstLevel: Int = 1
    private let secondLevel: Int = 6
    private(set) var appStoreURL: URL?
    private var appStoreVersion: String?
    
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension NewVersionInteractor: NewVersionInteracting {
    var checkEnabled: Bool { !mainRepository.newVersionCheckDisabled }
    
    func checkForNewVersion(completion: @escaping (Bool) -> Void) {
        Log("NewVersionInteractor - checkForNewVersion", module: .interactor)
        guard let currentVersion = mainRepository.appVersion, checkEnabled else {
            Log(
                "NewVersionInteractor - can't get app version from Bundle or check disabled. Skipping check",
                module: .interactor
            )
            completion(false)
            return
        }
        
        Log("NewVersionInteractor - Current version \(currentVersion). Fetching from App Store", module: .interactor)
        
        mainRepository.fetchNewVersion { [weak self] result in
            Log("New Version: Fetch complete")
            guard let self else { return }
            switch result {
            case .success(let appInfo):
                let notify = self.newVersionFetched(currentVersion: currentVersion, appStoreVersion: appInfo.version)
                Log("""
                    NewVersionInteractor - fetch completed
                    
                    currentVersion: \(currentVersion)
                    appStoreVersion: \(appInfo.version)
                    notify: \(notify)
                    appStoreURL: \(appInfo.appStoreURL)
                    """,
                    module: .interactor
                )
                self.appStoreURL = appInfo.appStoreURL
                self.appStoreVersion = appInfo.version
                completion(notify)
            case .failure(let error):
                Log("NewVersionInteractor - fetch error! \(error)", module: .interactor)
                completion(false)
            }
        }
    }
    
    func setCheckEnabled(_ enabled: Bool) {
        Log("NewVersionInteractor - setCheckEnabled: \(enabled)", module: .interactor)
        mainRepository.setNewVersionCheckDisabled(!enabled)
    }
    
    func userSkippedVersion() {
        Log("NewVersionInteractor - userSkippedVersion", module: .interactor)
        guard let appStoreVersion else {
            Log("NewVersionInteractor - userSkippedVersion, can't get appStoreVersion", module: .interactor)
            return
        }
        Log("NewVersionInteractor - setNewVersionIgnored: \(appStoreVersion)", module: .interactor)
        mainRepository.setNewVersionIgnored(appStoreVersion)
    }
}

private extension NewVersionInteractor {
    func newVersionFetched(currentVersion: String, appStoreVersion: String) -> Bool {
        Log("""
            NewVersionInteractor - newVersionFetched:
            currentVersion: \(currentVersion),
            appStoreVersion: \(appStoreVersion)
            """,
            module: .interactor
        )
        
        if appStoreVersion <= currentVersion {
            Log("NewVersionInteractor - appStoreVersion <= currentVersion", module: .interactor)
            return false
        }
        if let ignored = mainRepository.newVersionIgnored, ignored == appStoreVersion {
            Log("NewVersionInteractor - version ignored: \(ignored)", module: .interactor)
            return false
        }
        if let tracked = mainRepository.newVersionTracked, tracked == appStoreVersion {
            Log("NewVersionInteractor - we're tracking that version: \(tracked)", module: .interactor)
            let counter = mainRepository.newVersionCounter
            let newCounter = counter + 1
            Log("NewVersionInteractor - counter: \(counter), newCounter: \(newCounter)", module: .interactor)
            if counter == firstLevel {
                Log(
                    "NewVersionInteractor - counter == firstLevel, setNewVersionCounter: \(newCounter)",
                    module: .interactor
                )
                mainRepository.setNewVersionCounter(newCounter)
                return true
            } else if counter >= secondLevel {
                Log("NewVersionInteractor - counter >= secondLevel, setNewVersionCounter: 0", module: .interactor)
                mainRepository.setNewVersionCounter(0)
                return true
            }
            
            Log("NewVersionInteractor - counter in the middle. newCounter: \(newCounter)", module: .interactor)
            
            mainRepository.setNewVersionCounter(newCounter)
            return false
        }
        
        Log("NewVersionInteractor - New track version: \(appStoreVersion) with counter = 0", module: .interactor)
                
        mainRepository.setNewVersionCounter(0)
        mainRepository.setNewVersionTracked(appStoreVersion)
        return false
    }
}
