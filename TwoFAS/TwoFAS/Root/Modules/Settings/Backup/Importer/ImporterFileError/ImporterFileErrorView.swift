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

struct ImporterFileErrorView: View {
    let fileError: ImporterOpenFileError
    let action: Callback

    private let image = Asset.fileError.image

    var body: some View {
        TFInfoView {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: image.size.width / 2, height: image.size.height / 2)
        } texts: {
            Text(title)
                .textStyle(.title1, .emphasized)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.center)
            Text(content)
                .textStyle(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.labelsSecondary)
            if let reason {
                Text(reason)
                    .textStyle(.footnote, .regular, .tight)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.labelsTertiary)
            }
        } buttons: {
            TFButton(T.Commons.close, variant: .borderedProminent, size: .large, action: action)
        }
        .navigationBarHidden(true)
    }

    private var title: String {
        switch fileError {
        case .noNewServices: return T.Backup.noNewServices
        default: return T.Backup.fileError
        }
    }

    private var content: String {
        switch fileError {
        case .noNewServices: return T.Backup.noNewServicesError
        case .newerSchema: return T.Backup.updateRequiredToImportTitle
        case .cantReadFile: return T.Backup.cantReadFileError
        }
    }

    private var reason: String? {
        if case .cantReadFile(let reason) = fileError {
            return reason
        }
        return nil
    }
}
