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

enum ViewPath: Equatable, Codable {
    enum Settings: String, Equatable, Codable {
        case externalImport
        case backup
        case security
        case browserExtension
        case trash
        case about
    }
    
    case main
    case settings(option: Settings?)
    case news
}

protocol ViewPathIteracting: AnyObject {
    func setViewPath(_ path: ViewPath)
    func clear()
    func clearFor(_ path: ViewPath)
    func viewPath() -> ViewPath?
}

final class ViewPathInteractor {
    private let saveForMinutes: Int = 15
    
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension ViewPathInteractor: ViewPathIteracting {
    func setViewPath(_ path: ViewPath) {
        Log("ViewPathInteractor: Setting path: \(path)")
        mainRepository.saveViewPath(path)
    }
    
    func clearFor(_ path: ViewPath) {
        Log("ViewPathInteractor: Checking if should clear for path: \(path)")
        guard let currentPath = viewPath(), path == currentPath else { return }
        clear()
    }
    
    func clear() {
        Log("ViewPathInteractor: Clearing")
        mainRepository.clearViewPath()
    }
    
    func viewPath() -> ViewPath? {
        guard let path = mainRepository.viewPath() else { return nil }
        
        let currentDate = Date()
        guard path.savedAt < currentDate && path.savedAt.minutes(to: currentDate) <= saveForMinutes else {
            Log("ViewPathInteractor: Entry to old")
            clear()
            return nil
        }
        
        Log("ViewPathInteractor: Returning path: \(path.viewPath)")
        return path.viewPath
    }
}
