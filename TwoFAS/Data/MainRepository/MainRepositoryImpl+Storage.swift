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
import Storage
import Common

extension MainRepositoryImpl {
    func trashService(_ serviceData: ServiceData) {
        let result = storageRepository.trashService(serviceData)
        logDataChange.logServiceDeleted(with: result.deleted)
        logDataChange.logServicesModified(with: result.modified)
        reloadWidgets()
    }
    
    func untrashService(_ serviceData: ServiceData) {
        let result = storageRepository.untrashService(serviceData)
        if let added = result.added {
            logDataChange.logNewServiceAdded(with: added)
        }
        logDataChange.logServicesModified(with: result.modified)
        reloadWidgets()
    }
    
    func listTrashedServices() -> [ServiceData] {
        storageRepository.listTrashedServices()
    }
    
    func serviceExists(for secret: String) -> ServiceExistenceStatus {
        storageRepository.serviceExists(for: secret)
    }
    
    func trashedService(for secret: String) -> ServiceData? {
        storageRepository.trashedService(for: secret)
    }
    
    func addService(
        name: String,
        secret: String,
        serviceTypeID: ServiceTypeID?,
        additionalInfo: String?,
        rawIssuer: String?,
        otpAuth: String?,
        tokenPeriod: Period?,
        tokenLength: Digits,
        badgeColor: TintColor?,
        iconType: IconType,
        iconTypeID: IconTypeID,
        labelColor: TintColor,
        labelTitle: String,
        algorithm: Algorithm,
        counter: Int?,
        tokenType: TokenType,
        source: ServiceSource
    ) {
        let result = storageRepository
            .addService(
                name: name,
                secret: secret,
                serviceTypeID: serviceTypeID,
                additionalInfo: additionalInfo,
                rawIssuer: rawIssuer,
                otpAuth: otpAuth,
                tokenPeriod: tokenPeriod,
                tokenLength: tokenLength,
                badgeColor: badgeColor,
                iconType: iconType,
                iconTypeID: iconTypeID,
                labelColor: labelColor,
                labelTitle: labelTitle,
                algorithm: algorithm,
                counter: counter,
                tokenType: tokenType,
                source: source
            )
        
        logDataChange.logNewServiceAdded(with: result)
        cloudHandler.synchronize()
    }
    
    func addService(
        name: String,
        secret: String,
        serviceTypeID: ServiceTypeID?,
        additionalInfo: String?,
        rawIssuer: String?,
        otpAuth: String?,
        tokenPeriod: Period?,
        tokenLength: Digits,
        badgeColor: TintColor?,
        iconType: IconType,
        iconTypeID: IconTypeID,
        labelColor: TintColor,
        labelTitle: String,
        algorithm: Algorithm,
        counter: Int?,
        tokenType: TokenType,
        source: ServiceSource,
        sectionID: SectionID?
    ) {
        let result = storageRepository
            .addService(
                name: name,
                secret: secret,
                serviceTypeID: serviceTypeID,
                additionalInfo: additionalInfo,
                rawIssuer: rawIssuer,
                otpAuth: otpAuth,
                tokenPeriod: tokenPeriod,
                tokenLength: tokenLength,
                badgeColor: badgeColor,
                iconType: iconType,
                iconTypeID: iconTypeID,
                labelColor: labelColor,
                labelTitle: labelTitle,
                algorithm: algorithm,
                counter: counter,
                tokenType: tokenType,
                sectionID: sectionID,
                source: source
            )
        
        logDataChange.logNewServiceAdded(with: result)
        cloudHandler.synchronize()
    }
    
    func updateService(
        _ serviceData: ServiceData,
        name: String,
        serviceTypeID: ServiceTypeID?,
        additionalInfo: String?,
        badgeColor: TintColor?,
        iconType: IconType,
        iconTypeID: IconTypeID,
        labelColor: TintColor,
        labelTitle: String,
        counter: Int?
    ) {
        let result = storageRepository
            .updateService(
                serviceData,
                name: name,
                additionalInfo: additionalInfo,
                badgeColor: badgeColor,
                iconType: iconType,
                iconTypeID: iconTypeID,
                labelColor: labelColor,
                labelTitle: labelTitle,
                counter: counter
            )
        
        logDataChange.logServicesModified(with: [result])
        reloadWidgets()
        cloudHandler.synchronize()
    }
    
    func deleteService(_ serviceData: ServiceData) {
        storageRepository.deleteService(serviceData)
    }
    
    func listAllExistingServices() -> [ServiceData] {
        storageRepository.listAllExistingServices()
    }
    
    func service(for secret: String) -> ServiceData? {
        storageRepository.findService(for: secret)
    }
    
    func listAllNotTrashed() -> [ServiceData] {
        storageRepository.listAllNotTrashed()
    }
    
    func incrementCounter(for secret: Secret) {
        storageRepository.incrementCounter(for: secret)
    }
    
    func listAllServicesWithingCategories(
        for phrase: String?,
        sorting: SortType,
        ids: [ServiceTypeID]
    ) -> [CategoryData] {
        storageRepository.listAllWithingCategories(for: phrase, sorting: sorting, ids: ids)
    }
    
    func countServices() -> Int {
        storageRepository.countServicesNotTrashed()
    }
    
    // MARK: - Categories/Sections
    
    func listAllSections() -> [SectionData] {
        storageRepository.listAllSections()
    }
    
    func moveServiceToSection(secret: String, sectionID: SectionID?) {
        let changedServices = storageRepository.moveServiceToEndOfSection(secret: secret, sectionID: sectionID)
        guard !changedServices.isEmpty else { return }
        logDataChange.logServicesModified(with: changedServices)
    }
    
    func section(for secret: String) -> SectionData? {
        storageRepository.section(for: secret)
    }
    
    @discardableResult
    func createSection(with title: String) -> SectionID {
        let sectionID = storageRepository.createSection(with: title)
        logDataChange.logNewSectionAdded(with: sectionID.uuidString)
        return sectionID
    }
    
    func obtainNextUnknownCodeCounter() -> Int {
        userDefaultsRepository.obtainNextUnknownCodeCounter()
    }
    
    func moveSectionDown(_ sectionData: SectionData) {
        categoryHandler.moveDown(sectionData)
    }
    
    func moveSectionUp(_ sectionData: SectionData) {
        categoryHandler.moveUp(sectionData)
    }
    
    func deleteSection(_ sectionData: SectionData) {
        categoryHandler.delete(sectionData)
    }
    
    func renameSection(_ sectionData: SectionData, newTitle: String) {
        categoryHandler.rename(sectionData, with: newTitle)
    }
    
    func moveService(_ service: ServiceData, from oldIndex: Int, to newIndex: Int, newSection: SectionData?) {
        categoryHandler.move(service: service, from: oldIndex, to: newIndex, newSection: newSection)
    }
    
    func setSectionZeroIsCollapsed(_ isCollapsed: Bool) {
        userDefaultsRepository.setSectionZeroIsCollapsed(isCollapsed)
    }
    
    func collapseSection(_ sectionData: SectionData, isCollapsed: Bool) {
        categoryHandler.collapseAction(for: sectionData, shouldCollapse: isCollapsed)
    }
    
    var isSectionZeroCollapsed: Bool { userDefaultsRepository.isSectionZeroCollapsed }
}
