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

struct ExportQuestionView: View {
    @StateObject
    var presenter: ExportQuestionPresenter
    let exportType: ExportQuestionType
    
    @State private var enableSave = false
    
    var body: some View {
        TFInfoView(
            icon: .image(Asset.exportBackup.image, .original),
            title: exportType.title,
            description: exportType.message,
            background: .backgroundsPrimary,
            buttons: {
                TFToggleRow(T.Exportwarning.toggle, isOn: $enableSave, isElevated: true)
                    .padding(.bottom, .S)
                
                TFButton(
                    exportType.cta,
                    variant: .borderedProminent,
                    size: .large
                ) {
                    presenter.handleShowPIN()
                }
                .disabled(!enableSave)
                
                TFButton(
                    T.Commons.cancel,
                    variant: .borderless,
                    size: .large
                ) {
                    presenter.handleClose()
                }
            })
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    presenter.handleClose()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}

private extension ExportQuestionType {
    var title: String {
        switch self {
        case .file: T.Exportwarning.titleFile
        case .qr: T.Exportwarning.titleQr
        }
    }
    
    var message: String {
        switch self {
        case .file: T.Exportwarning.descriptionFile
        case .qr: T.Exportwarning.descriptionQr
        }
    }
    
    var cta: String {
        switch self {
        case .file: T.Exportwarning.ctaFile
        case .qr: T.Exportwarning.ctaQr
        }
    }
}
