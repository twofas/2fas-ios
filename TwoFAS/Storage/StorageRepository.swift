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

public protocol StorageRepository: AnyObject {
    var hasServices: Bool { get }
    func trashService(_ serviceData: ServiceData) -> (deleted: String, modified: [String])
    func untrashService(_ serviceData: ServiceData) -> (added: String?, modified: [String])
    func listTrashedServices() -> [ServiceData]
    func serviceExists(for secret: String) -> ServiceExistenceStatus
    func trashedService(for secret: String) -> ServiceData?
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
    ) -> String
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
        sectionID: SectionID?,
        source: ServiceSource
    ) -> String
    @discardableResult
    func updateService(
        _ serviceData: ServiceData,
        name: String,
        additionalInfo: String?,
        badgeColor: TintColor?,
        iconType: IconType,
        iconTypeID: IconTypeID,
        labelColor: TintColor,
        labelTitle: String,
        counter: Int?
    ) -> String
    func deleteService(_ serviceData: ServiceData)
    func deleteServices(_ services: [ServiceData])
    func listAllExistingServices() -> [ServiceData]
    func listAllNotTrashed() -> [ServiceData]
    func listAllWithingCategories(
        for phrase: String?,
        sorting: SortType,
        ids: [ServiceTypeID]
    ) -> [CategoryData]
    func findService(for secret: String) -> ServiceData?
    func findAllUnknownServices() -> [ServiceData]
    func countServicesNotTrashed() -> Int
    func incrementCounter(for secret: String)
    
    // MARK: - Pairings
    func createPairing(name: String, extensionID: ExtensionID, publicKey: String)
    func deletePairing(_ pairing: PairedWebExtension)
    func updatePairing(_ pairing: PairedWebExtension, name: String)
    func removeAllPairings()
    func listAllPairings() -> [PairedWebExtension]
    
    // MARK: - Auth Requests
    func removeAuthRequest(_ authRequest: PairedAuthRequest)
    func removeAuthRequests(_ authRequests: [PairedAuthRequest])
    func createAuthRequest(for secret: String, extensionID: ExtensionID, domain: String)
    func listAllAuthRequests(for secret: String) -> [PairedAuthRequest]
    func listAllAuthRequests(for domain: String, extensionID: ExtensionID) -> [PairedAuthRequest]
    func listAllAuthRequestsForExtensionID(_ extensionID: ExtensionID) -> [PairedAuthRequest]
    func updateAuthRequestUsage(for authRequest: PairedAuthRequest)
    func removeAllAuthRequests()
    
    // MARK: - News
    func createNewsEntry(from newsEntry: ListNewsEntry)
    func deleteNewsEntry(with newsEntry: ListNewsEntry)
    func updateNewsEntry(with newsEntry: ListNewsEntry)
    func markNewsEntryAsRead(with newsEntry: ListNewsEntry)
    func listAllNews() -> [ListNewsEntry]
    func listAllFreshlyAddedNews() -> [ListNewsEntry]
    func hasNewsEntriesUnreadItems() -> Bool
    func markAllAsRead()
    
    // MARK: - Categories/Sections
    func listAllSections() -> [SectionData]
    func moveServiceToEndOfSection(secret: String, sectionID: SectionID?) -> [String]
    func section(for secret: String) -> SectionData?
    func createSection(with title: String) -> SectionID
}
