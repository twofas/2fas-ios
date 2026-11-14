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

import UIKit
import Common
import Data

protocol AddingServiceManuallyModuleInteracting: AnyObject {
    func detectedIconTypeID(for serviceName: String) -> IconTypeID?
    func isPrivateKeyUsed(_ privateKey: String) -> Bool
    func addService(
        name: String,
        secret: String,
        additionalInfo: String?,
        tokenPeriod: Period?,
        tokenLength: Digits?,
        iconType: IconType,
        iconTypeID: IconTypeID?,
        labelTitle: String,
        labelColor: TintColor,
        algorithm: Algorithm?,
        counter: Int?,
        tokenType: TokenType?
    ) -> ServiceData?
}

final class AddingServiceManuallyModuleInteractor {
    private let serviceDatabase: ServiceDefinitionInteracting
    private let serviceListingInteractor: ServiceListingInteracting
    private let serviceModifyInteractor: ServiceModifyInteracting
    
    init(
        serviceDatabase: ServiceDefinitionInteracting,
        serviceListingInteractor: ServiceListingInteracting,
        serviceModifyInteractor: ServiceModifyInteracting
    ) {
        self.serviceDatabase = serviceDatabase
        self.serviceListingInteractor = serviceListingInteractor
        self.serviceModifyInteractor = serviceModifyInteractor
    }
}

extension AddingServiceManuallyModuleInteractor: AddingServiceManuallyModuleInteracting {
    func detectedIconTypeID(for serviceName: String) -> IconTypeID? {
        guard !serviceName.isEmpty else { return nil }
        return serviceDatabase.findServicesByTagOrIssuer(
            serviceName,
            exactMatch: true,
            useTags: false
        ).first?.iconTypeID
    }
    
    func isPrivateKeyUsed(_ privateKey: String) -> Bool {
        serviceListingInteractor.service(for: privateKey) != nil
    }
    
    func addService(
        name: String,
        secret: String,
        additionalInfo: String?,
        tokenPeriod: Period?,
        tokenLength: Digits?,
        iconType: IconType,
        iconTypeID: IconTypeID?,
        labelTitle: String,
        labelColor: TintColor,
        algorithm: Algorithm?,
        counter: Int?,
        tokenType: TokenType?
    ) -> ServiceData? {
        serviceModifyInteractor.addService(
            name: name,
            secret: secret.uppercased(),
            serviceTypeID: nil,
            additionalInfo: additionalInfo,
            rawIssuer: nil,
            otpAuth: nil,
            tokenPeriod: tokenPeriod ?? .defaultValue,
            tokenLength: tokenLength ?? .defaultValue,
            badgeColor: .default,
            iconType: iconType,
            iconTypeID: iconTypeID ?? .default,
            labelColor: labelColor,
            labelTitle: labelTitle.isEmpty ? name.twoLetters : labelTitle,
            algorithm: algorithm ?? .defaultValue,
            counter: counter,
            tokenType: tokenType ?? .defaultValue,
            source: .manual,
            sectionID: nil
        )
        return serviceModifyInteractor.service(for: secret)
    }
}
