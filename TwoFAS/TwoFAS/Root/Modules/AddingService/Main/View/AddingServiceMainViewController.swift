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

protocol AddingServiceMainViewControlling: AnyObject {}

final class AddingServiceMainViewController: UIViewController {
    var heightChange: ((CGFloat) -> Void)?
    var presenter: AddingServiceMainPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.handleCameraAvailability { [weak self] isCameraAvailable in
            self?.setupView(cameraUnavailable: !isCameraAvailable)
        }
    }
    
    private func setupView(cameraUnavailable: Bool) {
        let main = AddingServiceMain(
            cameraUnavailable: cameraUnavailable,
            changeHeight: { [weak self] height in
                self?.heightChange?(height)
            }, presenter: presenter) { [weak self] in
                self?.presentingViewController?.dismiss(animated: true)
            }
        
        let vc = UIHostingController(rootView: main)
        vc.willMove(toParent: self)
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToParent()
        vc.view.backgroundColor = Theme.Colors.Fill.System.third
        vc.didMove(toParent: self)
    }
}

extension AddingServiceMainViewController: AddingServiceMainViewControlling {}

private struct AddingServiceMain: View {
    @State private var errorReason: String?
    
    let cameraUnavailable: Bool
    let changeHeight: (CGFloat) -> Void
    let dismiss: () -> Void
    
    @ObservedObject var presenter: AddingServiceMainPresenter
    
    init(
        cameraUnavailable: Bool,
        changeHeight: @escaping (CGFloat) -> Void,
        presenter: AddingServiceMainPresenter,
        dismiss: @escaping () -> Void
    ) {
        self.cameraUnavailable = cameraUnavailable
        self.changeHeight = changeHeight
        self.presenter = presenter
        self.dismiss = dismiss
        
        if cameraUnavailable {
            errorReason = T.Tokens.cameraIsUnavailableAppPermission
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
            VStack(spacing: 0) {
                AddingServiceCloseButtonView {
                    dismiss()
                }
                AddingServiceTitleView(text: T.Tokens.addManualTitle)
            }
            .frame(maxWidth: .infinity)

            AddingServiceTextContentView(text: T.Tokens.addDescription)
            AddingServiceLargeSpacing()
            
            Group {
                if errorReason != nil || cameraUnavailable {
                    let reason: AttributedString = {
                        if let errorReason {
                            return AttributedString(errorReason)
                        }
                        var result = AttributedString(T.Tokens.cameraIsUnavailableAppPermission)
                        if let range = result.range(of: T.Tokens.cameraIsUnavailableAppPermissionUnderline) {
                            result[range].underlineStyle = .single
                        }
                        
                        return result
                    }()
                    ErrorTextView(attributedString: reason)
                } else {
                    AddingServiceCameraViewport(didRegisterError: { errorReason in
                        self.errorReason = errorReason
                    }, didFoundCode: { codeType in
                        presenter.handleFoundCode(codeType: codeType)
                    }, cameraFreeze: $presenter.freezeCamera)
                }
            }
            .frame(height: AddingServiceMetrics.cameraActiveAreaHeight)
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .cornerRadius(Theme.Metrics.modalCornerRadius)
            .onTapGesture {
                guard cameraUnavailable else { return }
                presenter.handleToAppSettings()
            }
            
            AddingServiceLargeSpacing()
            
            AddingServiceTitleView(text: T.Tokens.otherMethodsHeader, alignToLeading: true)
            
            AddingServiceFullWidthButtonWithImage(
                text: T.Tokens.addEnterManual,
                icon: Asset.keybordIcon.swiftUIImage
            ) {
                presenter.handleToAddManually()
            }
            
            AddingServiceFullWidthButtonWithImage(
                text: T.Tokens.addFromGallery,
                icon: Asset.imageIcon.swiftUIImage
            ) {
                presenter.handleToGallery()
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
