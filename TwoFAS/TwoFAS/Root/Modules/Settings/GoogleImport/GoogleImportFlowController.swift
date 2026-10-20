//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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
import Common
import Data

protocol GoogleImportFlowControllerParent: AnyObject {
    func googleImportClose()
    func googleImportDidImport(count: Int)
}

protocol GoogleImportFlowControlling: AnyObject {
    func toCamera()
    func toGallery()
    func toSummary(importableCount: Int, totalCount: Int)
    func toImportSummary(count: Int)
    func close()
}

final class GoogleImportFlowController: FlowController {
    private weak var parent: GoogleImportFlowControllerParent?
    private weak var presenter: GoogleImportPresenter?
    private weak var navigationController: UINavigationController?
    private var galleryViewController: UIViewController?

    static func present(
        on viewController: UIViewController,
        parent: GoogleImportFlowControllerParent,
        data: GoogleScanData
    ) {
        let built = makeFlowController(parent: parent, data: data, showsCloseButton: true)
        let navi = CommonNavigationController()
        navi.modalPresentationStyle = .fullScreen
        navi.isModalInPresentation = true
        built.flowController.navigationController = navi
        built.flowController.presentInitial(importViewController: built.viewController, in: navi, animated: false)

        viewController.present(navi, animated: true)
    }

    static func push(
        in navigationController: UINavigationController,
        parent: GoogleImportFlowControllerParent,
        data: GoogleScanData
    ) {
        let built = makeFlowController(parent: parent, data: data, showsCloseButton: false)
        built.flowController.navigationController = navigationController
        built.flowController.presentInitial(
            importViewController: built.viewController,
            in: navigationController,
            animated: true
        )
    }

    private static func makeFlowController(
        parent: GoogleImportFlowControllerParent,
        data: GoogleScanData,
        showsCloseButton: Bool
    ) -> (viewController: UIViewController, flowController: GoogleImportFlowController) {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        hosting.view.backgroundColor = AppColor.backgroundsPrimary.uiColor
        let flowController = GoogleImportFlowController(viewController: hosting)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.googleImportModuleInteractor()
        let presenter = GoogleImportPresenter(
            flowController: flowController,
            interactor: interactor,
            data: data
        )
        flowController.presenter = presenter
        hosting.rootView = AnyView(GoogleImportView(presenter: presenter, showsCloseButton: showsCloseButton))
        return (hosting, flowController)
    }

    private func presentInitial(
        importViewController: UIViewController,
        in navigationController: UINavigationController,
        animated: Bool
    ) {
        var stack = navigationController.viewControllers + [importViewController]
        if presenter?.isComplete == true, let params = presenter?.beginSummary() {
            stack.append(makeSummaryViewController(importableCount: params.importable, totalCount: params.total))
        }
        navigationController.setViewControllers(stack, animated: animated)
    }
}

extension GoogleImportFlowController: GoogleImportFlowControlling {
    func toCamera() {
        guard let _viewController else { return }
        CameraScannerFlowController.present(
            on: _viewController,
            parent: self,
            googleMultiscanFeedback: { [weak self] data in
                self?._viewController?.dismiss(animated: true) {
                    self?.presenter?.handleScannedBatch(data)
                }
            }
        )
    }

    func toGallery() {
        guard let _viewController else { return }
        galleryViewController = SelectFromGalleryFlowController.present(
            on: _viewController,
            applyOverlay: true,
            parent: self,
            googleMultiscanFeedback: { [weak self] data in
                self?.presenter?.handleScannedBatch(data)
                self?.galleryViewController = nil
            }
        )
    }

    func toSummary(importableCount: Int, totalCount: Int) {
        guard let navigationController else { return }
        let hosting = makeSummaryViewController(importableCount: importableCount, totalCount: totalCount)
        navigationController.pushViewController(hosting, animated: true)
    }

    func toImportSummary(count: Int) {
        parent?.googleImportDidImport(count: count)
    }

    func close() {
        parent?.googleImportClose()
    }
}

private extension GoogleImportFlowController {
    func makeSummaryViewController(importableCount: Int, totalCount: Int) -> UIViewController {
        let summary = CameraGoogleAuth(
            importedCount: importableCount,
            totalCount: totalCount,
            action: { [weak presenter] in presenter?.handleImport() },
            cancel: { [weak presenter] in presenter?.handleClose() }
        )
        let hosting = SummaryHostingController(
            rootView: AnyView(summary.background(AppColor.backgroundsPrimaryElevated, ignoresSafeAreaEdges: .all))
        )
        hosting.view.backgroundColor = AppColor.backgroundsPrimaryElevated.uiColor
        return hosting
    }
}

extension GoogleImportFlowController: CameraScannerFlowControllerParent {
    func cameraScannerDidFinish() {
        _viewController?.dismiss(animated: true)
    }

    func cameraScannerDidImport(count: Int) {}

    func cameraScannerServiceWasCreated(serviceData: ServiceData) {}

    func cameraScannerToGoogleAuthImport(data: GoogleScanData) {
        // Delivered through googleMultiscanFeedback.
    }
}

extension GoogleImportFlowController: SelectFromGalleryFlowControllerParent {
    func galleryWillShow(alongside coordinator: UIViewControllerTransitionCoordinator?) {}
    func galleryWillCancel(alongside coordinator: UIViewControllerTransitionCoordinator?) {}

    func galleryDidImport(count: Int) {}

    func galleryServiceWasCreated(serviceData: ServiceData) {}

    func galleryDidCancel() {
        galleryViewController = nil
    }

    func galleryToGoogleAuthImport(data: GoogleScanData) {
        // Delivered through googleMultiscanFeedback.
    }
}

private final class SummaryHostingController<Content: View>: UIHostingController<Content> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
