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

struct CameraErrorTemplate: View {
    private let paddingHorizontal: CGFloat = 3 * Theme.Metrics.standardSpacing
    private let paddingVertical: CGFloat = Theme.Metrics.doubleSpacing
    private let topSpacing: CGFloat = 6 * Theme.Metrics.standardSpacing
    private let containerPadding: CGFloat = Theme.Metrics.standardSpacing
    
    let title: String
    let subtitle: String
    let image: UIImage
    let imageSize: CGSize
    let action: Callback
    let cancel: Callback?
    let actionTitle: String?
    let cancelTitle: String?
    
    var body: some View {
        Group {
            VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
                Group {
                    Image(uiImage: image)
                        .frame(width: imageSize.width, height: imageSize.height)
                }
                .frame(maxHeight: .infinity, alignment: .center)
                
                VStack(spacing: Theme.Metrics.doubleSpacing) {
                    Text(title)
                        .font(.title)
                        .multilineTextAlignment(.center)
                    Text(subtitle)
                        .font(.body)
                        .multilineTextAlignment(.center)
                }
                .frame(alignment: .center)
                .layoutPriority(1)
                
                VStack(spacing: 0) {
                    Button {
                        action()
                    } label: {
                        let title: String = {
                            if let actionTitle {
                                return actionTitle
                            }
                            return T.Tokens.tryAgain
                        }()
                        Text(title)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .buttonStyle(RoundedFilledButtonStyle())
                    Button {
                        cancel?()
                    } label: {
                        let title: String = {
                            if let cancelTitle {
                                return cancelTitle
                            }
                            return T.Commons.cancel
                        }()
                        Text(title)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .buttonStyle(LinkButtonStyle())
                    .isHidden(cancel == nil, remove: true)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .frame(maxWidth: Theme.Metrics.componentWidth)
            .padding(EdgeInsets(
                top: paddingVertical,
                leading: paddingHorizontal,
                bottom: paddingVertical,
                trailing: paddingHorizontal))
            .background(Color(Theme.Colors.decoratedContainer)
            )
            .cornerRadius(Theme.Metrics.cornerRadius)
        }
        .padding(containerPadding)
    }
}

enum CameraError {
    case duplicatedCode
    case generalEror
    case appStore
    
    func view(with action: @escaping Callback, cancel: Callback?) -> some View {
        switch self {
        case .duplicatedCode:
            return CameraErrorTemplate(
                title: T.Commons.warning,
                subtitle: T.Tokens.serviceAlreadyExists,
                image: Asset.scanErrorDuplicateError.image,
                imageSize: .init(width: 154, height: 64),
                action: action,
                cancel: cancel,
                actionTitle: T.Commons.yes,
                cancelTitle: T.Commons.no
            )
        case .generalEror:
            return CameraErrorTemplate(
                title: T.Tokens.thisQrCodeIsInavlid,
                subtitle: T.Tokens.scanQrCodeTitle,
                image: Asset.scanErrorGeneralError.image,
                imageSize: .init(width: 87, height: 85),
                action: action,
                cancel: cancel,
                actionTitle: nil,
                cancelTitle: nil
            )
        case .appStore:
            return CameraErrorTemplate(
                title: T.Tokens.qrCodeLeadsToAppStore,
                subtitle: T.Tokens.scanQrCodeTitle,
                image: Asset.scanErrorAppStore.image,
                imageSize: .init(width: 73, height: 64),
                action: action,
                cancel: cancel,
                actionTitle: nil,
                cancelTitle: nil
            )
        }
    }
}

struct CameraErrorTemplate_Previews: PreviewProvider {
    static var previews: some View {
        CameraError.appStore.view(with: { print("App store") }, cancel: nil)
        CameraError.generalEror.view(with: { print("General error") }, cancel: nil)
        CameraError.duplicatedCode
            .view(
                with: { print("Duplicated code") },
                cancel: {}
            )
            .previewDevice("iPhone SE (1st generation)")
            .background(Color.pink)
            .preferredColorScheme(.dark)
    }
}
