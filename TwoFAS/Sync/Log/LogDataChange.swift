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

public protocol LogDataChange: AnyObject {
    func logNewServiceAdded(with secret: String)
    func logServicesModified(with secrets: [String])
    func logServiceDeleted(with secret: String)
    
    func logNewSectionAdded(with sectionID: String)
    func logSectionModified(with sectionID: String)
    func logSectionsModified(with sectionIDs: [String])
    func logSectionDeleted(with sectionID: String)
}

final class LogDataChangeImpl: LogDataChange {
    private let logHandler: LogHandler
    
    init(logHandler: LogHandler) {
        self.logHandler = logHandler
    }
    
    func logNewServiceAdded(with secret: String) {
        logHandler.log(entityID: secret, actionType: .created, kind: .service3)
    }
    
    func logServicesModified(with secrets: [String]) {
        secrets.forEach {
            logHandler.log(entityID: $0, actionType: .modified, kind: .service3)
        }
    }
    
    func logServiceDeleted(with secret: String) {
        logHandler.log(entityID: secret, actionType: .deleted, kind: .service3)
    }
    
    // MARK: Section
    func logNewSectionAdded(with sectionID: String) {
        logHandler.log(entityID: sectionID, actionType: .created, kind: .section)
    }
    
    func logSectionModified(with sectionID: String) {
        logHandler.log(entityID: sectionID, actionType: .modified, kind: .section)
    }
    
    func logSectionsModified(with sectionIDs: [String]) {
        sectionIDs.forEach({
            logHandler.log(entityID: $0, actionType: .modified, kind: .section)
        })
    }
    
    func logSectionDeleted(with sectionID: String) {
        logHandler.log(entityID: sectionID, actionType: .deleted, kind: .section)
    }
}
