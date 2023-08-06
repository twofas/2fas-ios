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
import SwiftUI
import CodeSupport

protocol AddingServiceMainViewControlling: AnyObject {
}

final class AddingServiceMainViewController: UIViewController {
    var heightChange: ((CGFloat) -> Void)?
    var presenter: AddingServiceMainPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.handleCameraAvailbility { [weak self] isCameraAvailable in
            self?.setupView(cameraUnavailable: !isCameraAvailable)
        }
    }
    
    private func setupView(cameraUnavailable: Bool) {
        let main = AddingServiceMain(cameraUnavailable: cameraUnavailable) { [weak self] codeType in
            self?.presenter.handleFoundCode(codeType: codeType)
        } addManually: { [weak self] in
            self?.presenter.handleToAddManually()
        } gotoGallery: { [weak self] in
            self?.presenter.handleToGallery()
        } changeHeight: { [weak self] height in
            self?.heightChange?(height)
        } cameraTapAction: { [weak self] in
            self?.presenter.handleToAppSettings()
        }
                
        let vc = UIHostingController(rootView: main)
        vc.willMove(toParent: self)
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToParent()
        vc.view.backgroundColor = Theme.Colors.Fill.System.second
        vc.didMove(toParent: self)
    }
}

extension AddingServiceMainViewController: AddingServiceMainViewControlling {}

private struct AddingServiceMain: View {
    @State private var errorReason2: String?
    
    let cameraUnavailable: Bool
    let foundCode: (CodeType) -> Void
    let addManually: Callback
    let gotoGallery: Callback
    let changeHeight: (CGFloat) -> Void
    let cameraTapAction: Callback
    
    init(
        cameraUnavailable: Bool,
        foundCode: @escaping (CodeType) -> Void,
        addManually: @escaping Callback,
        gotoGallery: @escaping Callback,
        changeHeight: @escaping (CGFloat) -> Void,
        cameraTapAction: @escaping Callback
    ) {
        self.cameraUnavailable = cameraUnavailable
        self.foundCode = foundCode
        self.addManually = addManually
        self.gotoGallery = gotoGallery
        self.changeHeight = changeHeight
        self.cameraTapAction = cameraTapAction
        
        if cameraUnavailable {
            errorReason2 = "Camera is unavailable. Check app's access permission"
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
            AddingServiceTitleView(text: "Pair service with 2FAS")
            AddingServiceTextContentView(text: "Point your camera to the screen to\ncapture the QR code.")
            AddingServiceLargeSpacing()

            Group {
                if errorReason2 != nil || cameraUnavailable {
                    let reason: AttributedString = {
                        if let errorReason2 {
                            return AttributedString(errorReason2)
                        }
                        var result = AttributedString("Camera is unavailable. Check app's access permission in System Settings")
                        if let range = result.range(of: "System Settings") {
                            result[range].underlineStyle = .single
                        }
                        
                        return result
                    }()
                    ErrorTextView(attributedString: reason)
                } else {
                    AddingServiceCameraViewport(didRegisterError: { errorReason in
                        self.errorReason2 = errorReason
                    }, didFoundCode: { codeType in
                        foundCode(codeType)
                    })
                }
            }
            .frame(height: AddingServiceMetrics.cameraActiveAreaHeight)
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .cornerRadius(Theme.Metrics.modalCornerRadius)
            .onTapGesture {
                guard cameraUnavailable else { return }
                
            }

            AddingServiceLargeSpacing()

            AddingServiceTitleView(text: "Other methods?", alignToLeading: true)

            AddingServiceFullWidthButton(
                text: "Enter secret key manually",
                icon: Asset.keybordIcon.swiftUIImage
            ) {
                addManually()
            }

            AddingServiceFullWidthButton(
                text: "Upload screen with QR code",
                icon: Asset.imageIcon.swiftUIImage
            ) {
                gotoGallery()
            }
        }
        .padding(.horizontal, Theme.Metrics.doubleMargin)
        .observeHeight(onChange: { height in
            changeHeight(height)
        })
    }
}

private struct ErrorTextView: View {
    let text: AttributedString
    
    init(attributedString: AttributedString) {
        self.text = attributedString
    }
    
    var body: some View {
        Text(text)
            .font(.headline)
            .foregroundColor(Color(Theme.Colors.Text.light))
            .multilineTextAlignment(.center)
            .padding(.horizontal, Theme.Metrics.doubleMargin)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
