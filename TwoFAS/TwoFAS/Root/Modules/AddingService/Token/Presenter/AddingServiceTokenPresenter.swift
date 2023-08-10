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
    
    @Published private(set) var token: String = ""
    @Published private(set) var refreshTokenLocked = true
    @Published private(set) var time: String = ""
    @Published private(set) var willChangeSoon = false
    
    @Published private(set) var progress: Int = 0
    @Published private(set) var period: Int = 0
    @Published private(set) var part: CGFloat = 0
    
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
        interactor.start() // TMP!!!!
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
    
    func handleTOTPInital(progress: Int, period: Int, token: TokenValue, willChangeSoon: Bool) {
        self.progress = progress
        self.period = period
        self.token = token.formattedValue
        self.willChangeSoon = willChangeSoon
        part = CGFloat(progress) / CGFloat(period)
    }
    
    func handleTOTPUpdate(progress: Int, token: TokenValue, willChangeSoon: Bool) {
        self.progress = progress
        self.token = token.formattedValue
        self.willChangeSoon = willChangeSoon
        part = CGFloat(progress) / CGFloat(period)
    }
}
