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
import CodeSupport
import Protection

extension MainRepositoryImpl {
    func export(with password: String?, finished: @escaping (URL?) -> Void) {
        let jsonEncoder = JSONEncoder()
        let encryption = ExchangeFileEncryption()
        guard let appVersion, let versionDecoded = appVersion.splitVersion() else {
            Log("Exporting: can't get app version or split it")
            finished(nil)
            return
        }
        let appCode = versionDecoded.code
        
        let sections = sectionHandler.getAllSections().map {
            ExchangeData2.Group(id: $0.sectionID, name: $0.name, isExpanded: !$0.isCollapsed)
        }
        
        let servicesForExport = packServices()
        let exportedStruct: ExchangeData2
        
        if let password {
            guard let data = try? jsonEncoder.encode(servicesForExport) else {
                Log("Exporting: can't encode services for encryption")
                finished(nil)
                return
            }
            
            guard let encryptedData = encryption.encrypt(with: password, data: data) else {
                Log("Exporting: can't encrypt data")
                finished(nil)
                return
            }
            exportedStruct = ExchangeData2(
                appOrigin: .ios,
                appVersionCode: appCode,
                appVersionName: appVersion,
                schemaVersion: ExchangeConsts.schemaVersion,
                services: [],
                servicesEncrypted: encryptedData.data,
                reference: encryptedData.reference,
                groups: sections
            )
        } else {
            exportedStruct = ExchangeData2(
                appOrigin: .ios,
                appVersionCode: appCode,
                appVersionName: appVersion,
                schemaVersion: ExchangeConsts.schemaVersion,
                services: servicesForExport,
                servicesEncrypted: nil,
                reference: nil,
                groups: sections
            )
        }
        
        guard let encoded = try? jsonEncoder.encode(exportedStruct) else {
            finished(nil); return }

        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(createFileName())
        do {
            try encoded.write(to: fileURL)
        } catch {
            Log("Exporting: Can't save exported file, error: \(error)")
            finished(nil)
            return
        }

        finished(fileURL)
    }
}

private extension MainRepositoryImpl {
    func createFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: Date())
        return "\(ExchangeConsts.fileNameStart)\(date)\(ExchangeConsts.fileNameEnd)"
    }
    
    func packServices() -> [ExchangeData2.Service] {
        let services = storageRepository.listAllWithingCategories(for: nil, sorting: .manual, ids: [])
        return services.map { categoryData -> [ExchangeData2.Service] in
            let sectionID = categoryData.section?.sectionID
            let serviceList = categoryData.services
            return serviceList.enumerated().map { index, s in
                let date = s.modifiedAt
                let dateMiliseconds = Int(date.timeIntervalSince1970) * 1000
                let badge: ExchangeData2.Badge? = {
                    guard let color = s.badgeColor?.toExportString else { return nil }
                    return .init(color: color)
                }()
                let icon: ExchangeData2.Icon = {
                    let iconType: ExchangeData2.IconTypeString = {
                        switch s.iconType {
                        case .brand: return .iconCollection
                        case .label: return .label
                        }
                    }()
                    let label: ExchangeData2.Label? = .init(
                        text: s.labelTitle,
                        backgroundColor: s.labelColor.toExportString
                    )

                    return .init(selected: iconType, label: label, iconCollection: .init(id: s.iconTypeID.uuidString))
                }()
                return ExchangeData2.Service(
                    name: s.name,
                    secret: s.secret,
                    serviceTypeID: s.serviceTypeID?.uuidString,
                    order: .init(position: index),
                    otp: .init(
                        account: s.additionalInfo,
                        issuer: s.rawIssuer,
                        digits: s.tokenLength.rawValue,
                        period: s.tokenPeriod?.rawValue,
                        algorithm: s.algorithm.rawValue,
                        counter: s.counter,
                        tokenType: s.tokenType.rawValue,
                        source: s.source.rawValue,
                        link: s.otpAuth
                    ),
                    updatedAt: dateMiliseconds,
                    badge: badge,
                    icon: icon,
                    groupId: sectionID?.uuidString
                )
            }
        }
        .reduce([ExchangeData2.Service](), +)
    }
}

private extension VersionDecoded {
    var code: Int { self.major * 10000 + self.minor * 100 + self.fix }
}
