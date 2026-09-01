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

import SwiftUI
import Common

struct TrashServiceView: View {
    @ObservedObject
    var presenter: TrashServicePresenter

    var body: some View {
        SheetContent(
            sizing: .fitContent,
            onClose: presenter.handleCancel
        ) {
            TFInfoContent(
                icon: .image(Asset.trashIcon.image, .original),
                title: "\(T.Tokens.deleteToken) \(presenter.serviceName)",
                subtitle: nil,
                description: T.Tokens.signInNotPossibleTitle(presenter.serviceName, presenter.serviceName)
            )
            .padding(.top, .M)
            .padding(.bottom, .L)
            .frame(maxWidth: Theme.Metrics.modalPreferredWidth)
            .padding(.horizontal, .XL)
        } buttons: {
            TFButton(
                T.Tokens.moveToTrash,
                variant: .borderedProminent,
                size: .large,
                applyGlass: true
            ) {
                presenter.handleTrashing()
            }

            TFCancelButton(T.Commons.cancel, action: presenter.handleCancel)
        }
        .onHeightChange { presenter.handleContentHeight($0) }
    }
}
