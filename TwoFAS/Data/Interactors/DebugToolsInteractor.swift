//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

#if DEV
import UIKit
import Common

/// Debug-only interactor exposing destructive/diagnostic actions.
/// Included in the DEV target only.
public protocol DebugToolsInteracting: AnyObject {
    // Read state
    var deviceID: String? { get }
    var isDeviceIDSet: Bool { get }
    var isPINSet: Bool { get }
    var isBiometryEnabled: Bool { get }
    var notificationStateDescription: String { get }
    var lastNotificationDescription: String { get }
    var pairedBrowsersCount: Int { get }
    var totalServicesCount: Int { get }
    var trashedServicesCount: Int { get }
    var sectionsCount: Int { get }
    var isCloudBackupEnabled: Bool { get }
    var cloudStateDescription: String { get }

    // Actions
    func disableCloudBackup()
    func enableCloudBackup()
    func wipeAllServicesAndSections()
    func emptyTrash()
    func clearAllUserDefaults()
    func removeAllBrowserPairings()
    func reloadPushToken()

    // Generation
    func addRandomService(sectionID: SectionID?)
    func createSection(named title: String) -> SectionID
}

final class DebugToolsInteractor {
    private let mainRepository: MainRepository

    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension DebugToolsInteractor: DebugToolsInteracting {
    var deviceID: String? { mainRepository.deviceID }
    var isDeviceIDSet: Bool { mainRepository.isDeviceIDSet }
    var isPINSet: Bool { mainRepository.isPINSet }
    var isBiometryEnabled: Bool { mainRepository.isBiometryEnabled }

    var notificationStateDescription: String {
        switch mainRepository.notificationState {
        case .unknown: return "unknown"
        case .allowed: return "allowed"
        case .denied: return "denied"
        case .notDetermined: return "notDetermined"
        case .error: return "error"
        }
    }

    var lastNotificationDescription: String {
        guard let last = mainRepository.lastSavedNotification() else { return "none" }
        switch last {
        case .refreshList: return "refreshList"
        case .authInApp(let id): return "authInApp(\(id))"
        }
    }

    var pairedBrowsersCount: Int {
        mainRepository.listAllPairedExtensions().count
    }

    var totalServicesCount: Int {
        mainRepository.listAllNotTrashed().count
    }

    var trashedServicesCount: Int {
        mainRepository.listTrashedServices().count
    }

    var sectionsCount: Int {
        mainRepository.listAllSections().count
    }

    var isCloudBackupEnabled: Bool {
        mainRepository.isCloudBackupConnected
    }

    var cloudStateDescription: String {
        String(describing: mainRepository.cloudCurrentState)
    }

    func disableCloudBackup() {
        mainRepository.disableCloudBackup()
    }

    func enableCloudBackup() {
        mainRepository.enableCloudBackup()
    }

    func wipeAllServicesAndSections() {
        mainRepository.listAllNotTrashed().forEach { mainRepository.deleteService($0) }
        mainRepository.listTrashedServices().forEach { mainRepository.deleteService($0) }
        mainRepository.listAllSections().forEach { mainRepository.deleteSection($0) }
        mainRepository.removeAllAuthRequests()
        mainRepository.saveStorage()
    }

    func emptyTrash() {
        mainRepository.listTrashedServices().forEach { mainRepository.deleteService($0) }
        mainRepository.saveStorage()
    }

    func clearAllUserDefaults() {
        mainRepository.clearAllUserDefaults()
    }

    func removeAllBrowserPairings() {
        mainRepository.listAllPairedExtensions().forEach {
            mainRepository.deletePairedExtension(with: $0.extensionID)
        }
        mainRepository.removeAllAuthRequests()
    }

    func reloadPushToken() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func addRandomService(sectionID: SectionID?) {
        let generator = DebugServiceGenerator(mainRepository: mainRepository)
        generator.addRandomService(sectionID: sectionID)
    }

    @discardableResult
    func createSection(named title: String) -> SectionID {
        mainRepository.createSection(with: title)
    }
}

// MARK: - Random service generator

private final class DebugServiceGenerator {
    private let mainRepository: MainRepository
    private let issuers: [ServiceDefinition]
    private static let base32Alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ234567")

    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
        self.issuers = mainRepository.allServiceDefinitions()
    }

    func addRandomService(sectionID: SectionID?) {
        let tokenType: TokenType = pickTokenType()
        let algorithm = Algorithm.allCases.randomElement() ?? .SHA1
        let digits: Digits = (tokenType == .steam) ? .digits5 : (Digits.allCases.randomElement() ?? .digits6)
        let period = Period.allCases.randomElement() ?? .period30

        let issuer = issuers.randomElement()

        let name: String = issuer?.name ?? randomFallbackName()
        let rawIssuer: String? = issuer?.issuer?.randomElement() ?? issuer?.name

        let iconType: IconType = (issuer != nil && Bool.random()) ? .brand : (Bool.random() ? .brand : .label)
        let iconTypeID: IconTypeID = issuer?.iconTypeID ?? IconTypeID()

        let labelColor: TintColor = .random
        let labelTitle: String = labelTitle(from: name)
        let badgeColor: TintColor? = Bool.random() ? TintColor.random : nil
        let additionalInfo: String? = (Int.random(in: 0...100) < 40) ? randomAdditionalInfo() : nil
        let source: ServiceSource = Bool.random() ? .manual : .link

        let counter: Int? = (tokenType == .hotp) ? Int.random(in: 0...5) : nil
        let secret = randomBase32Secret()

        mainRepository.addService(
            name: name,
            secret: secret,
            serviceTypeID: issuer?.serviceTypeID,
            additionalInfo: additionalInfo,
            rawIssuer: rawIssuer,
            otpAuth: nil,
            tokenPeriod: tokenType == .totp ? period : nil,
            tokenLength: digits,
            badgeColor: badgeColor,
            iconType: iconType,
            iconTypeID: iconTypeID,
            labelColor: labelColor,
            labelTitle: labelTitle,
            algorithm: algorithm,
            counter: counter,
            tokenType: tokenType,
            source: source,
            sectionID: sectionID
        )
    }

    private func pickTokenType() -> TokenType {
        let roll = Int.random(in: 0..<100)
        if roll < 70 { return .totp }
        if roll < 90 { return .hotp }
        return .steam
    }

    private func randomBase32Secret() -> String {
        let length = Int.random(in: 16...32)
        return String((0..<length).map { _ in Self.base32Alphabet.randomElement()! })
    }

    private func randomFallbackName() -> String {
        let words = ["Alpha", "Beta", "Gamma", "Delta", "Sigma", "Omega", "Zeta", "Kappa"]
        let word = words.randomElement() ?? "Service"
        return "\(word) \(Int.random(in: 1...9999))"
    }

    private func randomAdditionalInfo() -> String {
        let domains = ["work", "personal", "test", "prod", "staging", "dev"]
        let domain = domains.randomElement() ?? "info"
        return "\(domain)@example.com"
    }

    private func labelTitle(from name: String) -> String {
        let cleaned = name.uppercased().filter { $0.isLetter }
        let prefix = String(cleaned.prefix(2))
        if prefix.count == 2 { return prefix }
        return "AB"
    }
}
#endif
