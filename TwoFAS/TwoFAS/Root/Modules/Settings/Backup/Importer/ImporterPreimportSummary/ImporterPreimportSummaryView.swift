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

struct ImporterPreimportSummaryView: View {
    @Bindable
    var presenter: ImporterPreimportSummaryPresenter
    
    private var attributedDescription: AttributedString {
        let first = AttributedString("\(presenter.subtitle)\n\n")
        var middle = AttributedString(secondaryText)
        middle.inlinePresentationIntent = .stronglyEmphasized
        let last = AttributedString("\n\n\(tertiaryText)")
        return first + middle + last
    }
    
    var body: some View {
        TFInfoView(icon: {
            if let icon = presenter.additionalIcon {
                return .view(view: AnyView(
                    HStack(spacing: .XL) {
                        Image(uiImage: icon)
                        ArrowIcon()
                        Image(uiImage: Asset.gaImport2.image)
                    }
                ))
            }
            return .image(Asset.importBackup.image, .original)
        }(),
                   title: presenter.title,
                   attributedDescription: attributedDescription,
                   buttons: {
            if presenter.isImporting {
                ProgressView()
                    .padding(.vertical, .M)
            } else {
                TFButton(
                    T.Backup.import,
                    variant: .borderedProminent,
                    size: .large
                ) {
                    presenter.handleImport()
                }
                .disabled(presenter.countNew == 0)
                
                TFCancelButton(T.Commons.cancel) {
                    presenter.handleCancel()
                }
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .closeToolbar {
            presenter.handleCancel()
        }
    }
    
    private var secondaryText: String {
        if presenter.isBackupFile {
            return T.Backup.newServices(presenter.countNew)
        }
        return T.Tokens.googleAuthOutOfTitle(presenter.countNew, presenter.countTotal)
    }
    
    private var tertiaryText: String {
        if presenter.isBackupFile {
            return T.Backup.servicesMergeTitle
        }
        return T.Tokens.googleAuthImportSubtitleEnd
    }
}
