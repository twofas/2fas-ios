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

protocol AddingServiceTokenModuleInteracting: AnyObject {
    var tokenConsumer: TokenTimerConsumer? { get set }
    var counterConsumer: TokenCounterConsumer? { get set }
    
    var serviceData: ServiceData { get }
    var serviceName: String { get }
    var serviceAdditionalInfo: String? { get }
    var serviceIcon: UIImage { get }
    var serviceTypeName: String? { get }
    var secret: String { get }
    var serviceTokenType: TokenType { get }
        
    func copyToken(_ token: String)
    func refresh()
    
    func start()
    func clear()
}

final class AddingServiceTokenModuleInteractor {
    private let notificationsInteractor: NotificationInteracting
    private let tokenInteractor: TokenInteracting
    private let serviceDefinitionInteractor: ServiceDefinitionInteracting
    let serviceData: ServiceData
    
    weak var tokenConsumer: TokenTimerConsumer?
    weak var counterConsumer: TokenCounterConsumer?
    
    init(
        notificationsInteractor: NotificationInteracting,
        tokenInteractor: TokenInteracting,
        serviceDefinitionInteractor: ServiceDefinitionInteracting,
        serviceData: ServiceData
    ) {
        self.notificationsInteractor = notificationsInteractor
        self.tokenInteractor = tokenInteractor
        self.serviceDefinitionInteractor = serviceDefinitionInteractor
        self.serviceData = serviceData
    }
}

extension AddingServiceTokenModuleInteractor: AddingServiceTokenModuleInteracting {
    var serviceName: String { serviceData.name }
    var serviceAdditionalInfo: String? { serviceData.additionalInfo }
    var serviceIcon: UIImage { serviceData.icon }
    var serviceTypeName: String? { serviceDefinitionInteractor.serviceName(for: serviceData.serviceTypeID) }
    var secret: String { serviceData.secret }

    var serviceTokenType: TokenType { serviceData.tokenType }
    
    func copyToken(_ token: String) {
        notificationsInteractor.copyWithSuccess(value: token)
    }
    
    func refresh() {
        guard serviceTokenType == .hotp else { return }
        tokenInteractor.unlockCounter(for: serviceData.secret)
    }
    
    func start() {
        switch serviceTokenType {
        case .totp, .steam:
            guard let tokenConsumer else { return }
            tokenInteractor.startTimer(tokenConsumer)
        case .hotp:
            guard let counterConsumer else { return }
            tokenInteractor.enableCounter(counterConsumer)
            refresh()
        }
    }
    
    func clear() {
        switch serviceTokenType {
        case .totp, .steam:
            guard let tokenConsumer else { return }
            tokenInteractor.stopTimer(tokenConsumer)
        case .hotp:
            guard let counterConsumer else { return }
            tokenInteractor.disableCounter(counterConsumer)
        }
    }
}
