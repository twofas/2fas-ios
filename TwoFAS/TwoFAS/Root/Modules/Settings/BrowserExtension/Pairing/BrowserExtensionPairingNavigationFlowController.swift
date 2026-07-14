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

protocol BrowserExtensionPairingNavigationFlowControllerParent: AnyObject {
    func browserExtensionPairingClose()
}

final class BrowserExtensionPairingNavigationFlowController: NavigationFlowController {
    private weak var parent: BrowserExtensionPairingNavigationFlowControllerParent?
    
    static func show(
        on viewController: UIViewController,
        parent: BrowserExtensionPairingNavigationFlowControllerParent,
        extensionID: ExtensionID
    ) {
        let flowController = BrowserExtensionPairingNavigationFlowController()
        flowController.parent = parent
        
        let navi = CommonNavigationControllerFlow(flowController: flowController)
        flowController.navigationController = navi
        
        navi.configureAsModal()
        navi.setNavigationBarHidden(true, animated: false)

        BrowserExtensionPairingPlainFlowController.showAsRoot(
            in: navi,
            parent: flowController,
            with: extensionID
        )
        
        viewController.present(navi, animated: true)
    }
    
    func close() {
        parent?.browserExtensionPairingClose()
    }
}

extension BrowserExtensionPairingNavigationFlowController: BrowserExtensionPairingPlainFlowControllerParent {
    func pairingSuccess() {
        BrowserExtensionSuccessFlowController.push(in: navigationController, parent: self)
    }
    
    func pairingError() {
        BrowserExtensionFailureFlowController.push(in: navigationController, parent: self)
    }
    
    func pairingAlreadyPaired() {
        BrowserExtensionPairingAlreadyPairedFlowController.push(in: navigationController, parent: self)
    }
}

extension BrowserExtensionPairingNavigationFlowController: BrowserExtensionFailureFlowControllerParent {
    func browserExtensionFailureClose() {
        close()
    }
    
    func browserExtensionFailurePairing() {
        close()
    }
}

extension BrowserExtensionPairingNavigationFlowController: BrowserExtensionPairingAlreadyPairedFlowControllerParent {
    func browserExtensionAlreadyPairedClose() {
        close()
        NotificationCenter.default.post(name: .switchToBrowserExtension, object: nil)
    }
}

extension BrowserExtensionPairingNavigationFlowController: BrowserExtensionSuccessFlowControllerParent {
    func browserExtensionSuccessClose() {
        close()
        NotificationCenter.default.post(name: .switchToBrowserExtension, object: nil)
    }
}
