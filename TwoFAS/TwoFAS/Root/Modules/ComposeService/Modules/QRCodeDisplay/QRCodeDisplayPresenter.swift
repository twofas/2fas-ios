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

final class QRCodeDisplayPresenter: ObservableObject {
    let qrCodeImage: UIImage
    
    var flowController: QRCodeDisplayFlowControlling?
        
    private var previousBrightness: CGFloat = 0.0
    private var isVisible = false
    private var brightnessObserver: NSObjectProtocol?

    // The screen showing the QR code, captured while the scene is active so
    // brightness can be restored even after the app resigns active.
    private let screen: UIScreen?

    init(qrCodeImage: UIImage) {
        self.qrCodeImage = qrCodeImage
        self.screen = UIApplication.shared.currentScene?.screen
        setupBrightnessObserver()
    }
    
    deinit {
        removeBrightnessObserver()
        restorePreviousBrightness()
        NotificationCenter.default.removeObserver(self)
    }
    
    func viewDidAppear() {
        isVisible = true
        setMaximumBrightness()
    }
    
    func viewWillDisappear() {
        isVisible = false
        restorePreviousBrightness()
    }
    
    func onClose() {
        flowController?.close()
    }
    
    func handleAppWillResignActive() {
        restorePreviousBrightness()
    }
    
    func handleAppWillEnterForeground() {
        if isVisible {
            setMaximumBrightness()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupBrightnessObserver() {
        previousBrightness = screen?.brightness ?? previousBrightness
        brightnessObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppWillResignActive()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppWillEnterForeground()
        }
    }
    
    private func removeBrightnessObserver() {
        if let observer = brightnessObserver {
            NotificationCenter.default.removeObserver(observer)
            brightnessObserver = nil
        }
    }
    
    private func setMaximumBrightness() {
        previousBrightness = screen?.brightness ?? previousBrightness
        screen?.brightness = 1.0
    }

    private func restorePreviousBrightness() {
        screen?.brightness = previousBrightness
    }
}
