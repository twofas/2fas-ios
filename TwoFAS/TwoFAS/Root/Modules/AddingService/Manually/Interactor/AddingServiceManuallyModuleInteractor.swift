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
    func checkForServiceIcon(using str: String, callback: @escaping (UIImage?, IconTypeID?) -> Void)
    func isPrivateKeyUsed(_ privateKey: String) -> Bool
    func addService(
        name: String,
        secret: String,
        additionalInfo: String?,
        tokenPeriod: Period?,
        tokenLength: Digits?,
        iconTypeID: IconTypeID?,
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
    func checkForServiceIcon(using str: String, callback: @escaping (UIImage?, IconTypeID?) -> Void) {
        guard let service = serviceDatabase.findServicesByTagOrIssuer(
            str,
            exactMatch: true,
            useTags: false
        ).first else {
            callback(nil, nil)
            return
        }
        callback(service.icon, service.iconTypeID)
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
        iconTypeID: IconTypeID?,
        algorithm: Algorithm?,
        counter: Int?,
        tokenType: TokenType?
    ) -> ServiceData? {
        let iconType: IconType = {
            if iconTypeID != nil {
                return .brand
            }
            return .label
        }()
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
            labelColor: .random,
            labelTitle: name.twoLetters,
            algorithm: algorithm ?? .defaultValue,
            counter: counter,
            tokenType: tokenType ?? .defaultValue,
            source: .manual,
            sectionID: nil
        )
        return serviceModifyInteractor.service(for: secret)
    }
}
