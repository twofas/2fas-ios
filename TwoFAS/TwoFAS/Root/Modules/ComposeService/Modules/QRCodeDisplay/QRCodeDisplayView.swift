//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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

struct QRCodeDisplayView: View {
    @ObservedObject var presenter: QRCodeDisplayPresenter
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: {
                        presenter.onClose()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.black)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                
                Spacer()
                
                Image(uiImage: presenter.qrCodeImage)
                    .frame(width: presenter.qrCodeImage.size.width, height: presenter.qrCodeImage.size.height)
                    .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .onAppear {
            presenter.viewDidAppear()
        }
        .onDisappear {
            presenter.viewWillDisappear()
        }
    }
}
