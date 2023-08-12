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

final class AddingServiceTokenPresenter: ObservableObject {
    weak var view: AddingServiceTokenViewControlling?
    
    var serviceIcon: UIImage {
        interactor.serviceIcon
    }
    
    var serviceName: String {
        interactor.serviceName
    }
    
    var serviceAdditionalInfo: String? {
        interactor.serviceAdditionalInfo
    }
    
    var serviceTokenType: TokenType {
        interactor.serviceTokenType
    }
    
    var serviceSecret: String {
        interactor.secret
    }
    
    @Published var token: String = ""
    @Published var refreshTokenLocked = true
    @Published var time: String = ""
    @Published var willChangeSoon = false
    
    @Published var progress: Int = 0
    @Published var period: Int = 0
    @Published var part: CGFloat = 0
    
    private let flowController: AddingServiceTokenFlowControlling
    private let interactor: AddingServiceTokenModuleInteracting
    
    init(flowController: AddingServiceTokenFlowControlling, interactor: AddingServiceTokenModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension AddingServiceTokenPresenter {
    func viewDidLoad() {
        interactor.tokenConsumer = view?.totpAdapter
        interactor.counterConsumer = view?.hotpAdapter        
    }
    
    func viewWillAppear() {
        interactor.start()
    }
    
    func viewWillDisappear() {
        interactor.clear()
    }
    
    func handleRefresh() {
        interactor.refresh()
    }
    
    func handleCopyCode() {
        interactor.copyToken(token)
    }
    
    // MARK: - TOTP
    
    func handleTOTPInital(progress: Int, period: Int, token: TokenValue, willChangeSoon: Bool) {
        self.progress = progress
        self.period = period
        self.token = token.formattedValue
        self.willChangeSoon = willChangeSoon
        updateTime(progress)
        updatePart(progress)
    }
    
    func handleTOTPUpdate(progress: Int, token: TokenValue, willChangeSoon: Bool) {
        self.progress = progress
        self.token = token.formattedValue
        self.willChangeSoon = willChangeSoon
        updateTime(progress)
        updatePart(progress)
    }
    
    // MARK: - HOTP
    
    func handleHOTP(isRefreshLocked: Bool, token: TokenValue) {
        self.refreshTokenLocked = isRefreshLocked
        self.token = token.formattedValue
    }
}

private extension AddingServiceTokenPresenter {
    func updatePart(_ progress: Int) {
        part = CGFloat(progress) / CGFloat(period)
    }
    
    func updateTime(_ progress: Int) {
        time = String(progress - 1)
    }
}
