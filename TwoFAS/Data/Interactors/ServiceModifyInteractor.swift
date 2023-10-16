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
import Storage

public protocol ServiceModifyInteracting: AnyObject {
    func serviceExists(for secret: String) -> ServiceExistenceStatus
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
    )
    func updateService(
        _ serviceData: ServiceData,
        name: String,
        additionalInfo: String?,
        badgeColor: TintColor?,
        iconType: IconType,
        iconTypeID: IconTypeID,
        labelColor: TintColor,
        labelTitle: String
    )
    func renameService(_ serviceData: ServiceData, newName: String)
    func service(for secret: String) -> ServiceData?
    func incrementCounter(for secret: Secret)
    func createNameForUnknownService() -> String
}

final class ServiceModifyInteractor {
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension ServiceModifyInteractor: ServiceModifyInteracting {
    func serviceExists(for secret: String) -> ServiceExistenceStatus {
        mainRepository.serviceExists(for: secret)
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
        Log("ServiceModifyInteractor - adding service", module: .interactor)
        if serviceExists(for: secret) == .trashed {
            guard let serviceForDeletition = mainRepository.trashedService(for: secret) else {
                return
            }
            mainRepository.deleteService(serviceForDeletition)
        }
        mainRepository.addService(
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
            source: source,
            sectionID: sectionID
        )
    }
    
    func updateService(
        _ serviceData: ServiceData,
        name: String,
        additionalInfo: String?,
        badgeColor: TintColor?,
        iconType: IconType,
        iconTypeID: IconTypeID,
        labelColor: TintColor,
        labelTitle: String
    ) {
        Log("ServiceModifyInteractor - updateService", module: .interactor)

        mainRepository.updateService(
            serviceData,
            name: name,
            serviceTypeID: serviceData.serviceTypeID,
            additionalInfo: additionalInfo,
            badgeColor: badgeColor,
            iconType: iconType,
            iconTypeID: iconTypeID,
            labelColor: labelColor,
            labelTitle: labelTitle,
            counter: serviceData.counter
        )
    }
    
    func renameService(_ serviceData: ServiceData, newName: String) {
        Log("ServiceModifyInteractor - renameService", module: .interactor)
        updateService(
            serviceData,
            name: newName,
            additionalInfo: serviceData.additionalInfo,
            badgeColor: serviceData.badgeColor,
            iconType: serviceData.iconType,
            iconTypeID: serviceData.iconTypeID,
            labelColor: serviceData.labelColor,
            labelTitle: serviceData.labelTitle
        )
    }
    
    func service(for secret: String) -> ServiceData? {
        mainRepository.service(for: secret)
    }
    
    func incrementCounter(for secret: Secret) {
        Log("ServiceModifyInteractor - incrementCounter", module: .interactor)
        mainRepository.incrementCounter(for: secret)
    }
    
    func createNameForUnknownService() -> String {
        mainRepository.serviceNameTranslation + " " + String(mainRepository.obtainNextUnknownCodeCounter())
    }
}
