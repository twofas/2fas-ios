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
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

extension StorageRepositoryImpl {
    func listAllSections() -> [SectionData] {
        SectionEntity.listAll(
            on: context,
            includesPendingChanges: true)
        .map({ SectionData.createFromManagedObject($0) })
    }
    
    func moveServiceToEndOfSection(secret: String, sectionID: SectionID?) -> [String] {
        let encryptedSecret = secret.encrypt()
        guard let serviceData = ServiceEntity.getService(on: context, encryptedSecret: encryptedSecret) else {
            Log("Can't find service for provided secret in moveServiceToSection", module: .storage)
            return []
        }

        let targetSectionServicesCount = ServiceEntity.listAll(on: context, sectionID: sectionID).count
        let updated = ServiceEntity.move(
            on: context,
            from: Int(serviceData.sectionOrder),
            currentSectionID: serviceData.sectionID,
            to: targetSectionServicesCount,
            newSectionID: sectionID
        )
        save()
        return updated.map { $0.secret.decrypt() }
    }
    
    func section(for secret: String) -> SectionData? {
        let encryptedSecret = secret.encrypt()
        guard let serviceData = ServiceEntity.getService(on: context, encryptedSecret: encryptedSecret) else {
            Log("Can't find service for provided secret in section(for: secret)", module: .storage)
            return nil
        }
        guard let sectionID = serviceData.sectionID else {
            return nil
        }
        guard let sectionEntity = SectionEntity.section(on: context, for: sectionID) else {
            Log("Can't find section for provided sectionID in section(for: secret)", module: .storage)
            return nil
        }
        return SectionData.createFromManagedObject(sectionEntity)
    }
    
    func createSection(with title: String) -> SectionID {
        let uuid = SectionEntity.create(on: context, title: title)
        save()
        return uuid
    }
}
