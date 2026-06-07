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
import Common
import Data

protocol AddingServiceFlowControllerParent: AnyObject {
    func addingServiceToManual(_ name: String?)
    func addingServiceDismiss()
    func addingServiceToGallery()
    func addingServiceToGoogleAuthSummary(importable: Int, total: Int, codes: [Code])
    func addingServiceToLastPassSummary(importable: Int, total: Int, codes: [Code])
    func addingServiceToSendLogs(auditID: UUID)
    func addingServiceToPushPermissions(for extensionID: Common.ExtensionID)
    func addingServiceToTwoFASWebExtensionPairing(for extensionID: Common.ExtensionID)
    func addingServiceToToken(_ serviceData: ServiceData)
    func addingServiceToGuides()
}

protocol AddingServiceFlowControlling: AnyObject {
    func toToken(serviceData: ServiceData)
    func close()
    func toAddManually()
    func toAppSettings()
    func toGuides()
    
    func toGoogleAuthSummary(importable: Int, total: Int, codes: [Code])
    func toLastPassSummary(importable: Int, total: Int, codes: [Code])
    func toGallery()
    func toTwoFASWebExtensionPairing(for extensionID: ExtensionID)
    func toSendLogs(auditID: UUID)
    func toPushPermissions(for extensionID: ExtensionID)
}

final class AddingServiceFlowController: FlowController {
    private weak var parent: AddingServiceFlowControllerParent?

    static func isPresented(on viewController: UIViewController) -> Bool {
        viewController.presentedViewController is UIHostingController<AddServiceHostingView>
    }

    static func present(
        on viewController: UIViewController,
        parent: AddingServiceFlowControllerParent
    ) {
        let box = FlowControllerBox()
        
        let rootView = AddServiceHostingView(flowController: box, onFullyDismissed: { [weak parent] in
            parent?.addingServiceDismiss()
        })
        
        let hosting = UIHostingController(rootView: rootView)
        
        hosting.view.backgroundColor = .clear
        // Keep the presenting VC in the hierarchy so the background shows through.
        hosting.modalPresentationStyle = .overFullScreen
        hosting.modalTransitionStyle = .crossDissolve
        hosting.isModalInPresentation = true
        hosting.definesPresentationContext = true
        // Prevents UIKit from snapshotting the full focus environment on present(),
        // which blocks the main thread for several seconds on large token lists.
        hosting.restoresFocusAfterTransition = false
        
        let flowController = AddingServiceFlowController(viewController: hosting)
        flowController.parent = parent
        box.flowController = flowController
        
        viewController.present(hosting, animated: false)
    }
}

private final class FlowControllerBox {
    var flowController: AddingServiceFlowControlling?
}

private struct AddServiceHostingView: View {
    let flowController: FlowControllerBox
    let onFullyDismissed: () -> Void
        
    @State
    private var appear = false
    
    /// Must match the genie hide animation duration (spring + syncPresentationState buffer).
    private let dismissAnimationDuration: TimeInterval = 0.62
    
    var body: some View {
        Color.clear
            .ignoresSafeArea()
            .onAppear {
                appear = true
            }
            .onChange(of: appear) { oldValue, newValue in
                // Both close button and tap-outside set appear=false.
                // Wait for the genie animation to finish before dismissing.
                guard oldValue == true, newValue == false else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + dismissAnimationDuration) {
                    onFullyDismissed()
                }
            }
            .genieModal(isPresented: $appear) {
                if let flowController = flowController.flowController {
                    AddingServiceView(
                        presenter: AddingServicePresenter(
                            flowController: flowController,
                            interactor: ModuleInteractorFactory.shared.addingServiceModuleInteractor()),
                        onClose: { appear = false }
                    )
                    .background(.clear)
                }
            }
    }
    
    private func closeFlow() {
        appear = false
    }
}

extension AddingServiceFlowController: AddingServiceFlowControlling {
    func toToken(serviceData: ServiceData) {
        parent?.addingServiceToToken(serviceData)
    }
    
    func close() {
        parent?.addingServiceDismiss()
    }
    
    func toAddManually() {
        parent?.addingServiceToManual(nil)
    }
    
    func toAppSettings() {
        parent?.addingServiceDismiss()
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    func toGuides() {
        parent?.addingServiceToGuides()
    }
    
    func toGallery() {
        parent?.addingServiceToGallery()
    }
    
    func toGoogleAuthSummary(importable: Int, total: Int, codes: [Code]) {
        parent?.addingServiceToGoogleAuthSummary(importable: importable, total: total, codes: codes)
    }
    
    func toLastPassSummary(importable: Int, total: Int, codes: [Code]) {
        parent?.addingServiceToLastPassSummary(importable: importable, total: total, codes: codes)
    }
    
    func toPushPermissions(for extensionID: ExtensionID) {
        parent?.addingServiceToPushPermissions(for: extensionID)
    }
    
    func toTwoFASWebExtensionPairing(for extensionID: ExtensionID) {
        parent?.addingServiceToTwoFASWebExtensionPairing(for: extensionID)
    }
    
    func toSendLogs(auditID: UUID) {
        parent?.addingServiceToSendLogs(auditID: auditID)
    }
}
