//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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
import SwiftUI

protocol QRCodeDisplayFlowControllerParent: AnyObject {
    func closeQRCodeDisplay()
}

protocol QRCodeDisplayFlowControlling: AnyObject {
    func close()
}

final class QRCodeDisplayFlowController: FlowController {
    private weak var parent: QRCodeDisplayFlowControllerParent?
   
    static func present(
        on viewController: UIViewController,
        parent: QRCodeDisplayFlowControllerParent,
        qrCodeImage: UIImage
    ) {
        let presenter = QRCodeDisplayPresenter(qrCodeImage: qrCodeImage)
        let view = UIHostingController(rootView: QRCodeDisplayView(presenter: presenter))

        let flowController = QRCodeDisplayFlowController(viewController: view)
        flowController.parent = parent
        
        presenter.flowController = flowController
        
        view.modalPresentationStyle = .fullScreen
        viewController.present(view, animated: true)
    }
}

extension QRCodeDisplayFlowController: QRCodeDisplayFlowControlling {
    func close() {
        parent?.closeQRCodeDisplay()
    }
}
