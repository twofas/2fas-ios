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

import SwiftUI
import CodeSupport
import AVFoundation

struct AddingServiceCameraViewport: UIViewRepresentable {
    private let height = AddingServiceMetrics.cameraActiveAreaHeight
        
    var didRegisterError: (String?) -> Void
    var didFoundCode: (CodeType) -> Void
    @Binding var cameraFreeze: Bool
    
    final class Coordinator {
        private weak var camera: CameraScanningView?
        
        private let feedbackGenerator = UINotificationFeedbackGenerator()
        private let notificationCenter = NotificationCenter.default
        
        private let parent: AddingServiceCameraViewport
        
        init(_ parent: AddingServiceCameraViewport) {
            self.parent = parent
            
            notificationCenter.addObserver(
                self,
                selector: #selector(cameraStateChanged),
                name: NSNotification.Name.AVCaptureSessionWasInterrupted,
                object: nil
            )
            notificationCenter.addObserver(
                self,
                selector: #selector(resumeCamera),
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )
        }
        
        func dismantle() {
            notificationCenter.removeObserver(self)
        }
        
        @objc
        private func cameraStateChanged(notification: Notification) {
            guard
                let reasonKey = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as? Int,
                let reason = AVCaptureSession.InterruptionReason(rawValue: reasonKey)
            else {
                return
            }

            let errorReason: String? = {
                switch reason {
                case .videoDeviceInUseByAnotherClient:
                    return T.Camera.cameraUsedByOtherAppTitle
                case .videoDeviceNotAvailableDueToSystemPressure:
                    return T.Camera.cameraUnavailableTitle
                case .videoDeviceNotAvailableWithMultipleForegroundApps:
                    return T.Camera.cantInitializeCameraSplitView
                case .videoDeviceNotAvailableInBackground:
                    camera?.stop()
                    return nil
                default: return T.Camera.cantInitializeCameraGeneral
                }
            }()
            parent.didRegisterError(errorReason)
        }
        
        @objc
        private func resumeCamera() {
            camera?.start()
        }
    }
    
    func makeUIView(context: Context) -> CameraScanningView {
        let cam = CameraScanningView()
        cam.codeFound = { didFoundCode($0) }
        return cam
    }
    
    func updateUIView(_ uiView: CameraScanningView, context: Context) {
        uiView.updateOrientation()
        
        if cameraFreeze {
            uiView.freeze()
        } else {
            uiView.unfreeze()
        }
    }
    
    func dismantleUIView(_ uiView: CameraScanningView, coordinator: Coordinator) {
        uiView.dismantle()
        coordinator.dismantle()
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: CameraScanningView, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        return CGSize(width: width, height: height)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

final class CameraScanningView: UIView {
    private var camera: Camera?
    var codeFound: ((CodeType) -> Void)?
    
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    // swiftlint:disable force_cast
    override var layer: CALayer { super.layer as! AVCaptureVideoPreviewLayer }
    // swiftlint:enable force_cast
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        camera = Camera(previewView: self, scanningRegion: .init(origin: .zero, size: frame.size))
        backgroundColor = .black
        camera?.delegate = self
        camera?.startScanning()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        camera?.updateScanningRegion(.init(origin: .zero, size: frame.size))
    }
    
    func stop() {
        camera?.freeze()
        camera?.stopScanning()
    }
    
    func start() {
        camera?.startScanning()
    }
    
    func dismantle() {
        camera?.stopScanning()
        camera?.delegate = nil
        camera?.clear()
        camera = nil
    }
    
    func unfreeze() {
        camera?.unfreeze()
    }
    
    func freeze() {
        camera?.freeze()
    }
    
    func updateOrientation() {
        camera?.updateOrientation()
    }
}

extension CameraScanningView: CameraDelegate {
    func didStartScanning() {}
    func didFoundCode(_ code: CodeType) {
        codeFound?(code)
    }
}
