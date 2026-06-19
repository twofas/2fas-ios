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
import UIKit
import Data

struct GuidePagesView: View {
    let presenter: GuidePagesPresenter
    
    @State
    private var position = ScrollPosition(idType: Int.self)
    
    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            ZStack {
                HStack(spacing: .zero) {
                    let pageNumber = position.viewID as? Int ?? 0
                    TFLiquidGlassSymbolButton(symbol: .back) {
                        if pageNumber > 0 {
                            withAnimation {
                                position.scrollTo(id: pageNumber - 1)
                            }
                        } else {
                            presenter.onBack()
                        }
                    }
                    Spacer()
                    TFLiquidGlassSymbolButton(symbol: .close) {
                        presenter.onClose()
                    }
                }
                TFTitleView(title: "2FAS for \(presenter.serviceName)")
            }
            .padding(.horizontal, .XXXL)
            .padding(.top, .XL)
            .frame(alignment: .top)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(0..<presenter.totalPages, id: \.self) { index in
                        let page = presenter.pages[index]
                        PageView(icon: page.image.icon, description: page.content, pageNumber: index)
                        .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                        .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollDisabled(true)
            .scrollPosition($position)
            .scrollTargetBehavior(.viewAligned)
            .scrollTransition(transition: { content, phase in
                content
                    .blur(radius: phase.isIdentity ? 10 : 0)
            })
            .frame(maxHeight: .infinity)
            .onAppear {
                position.scrollTo(id: 0)
            }
            
            AdaptiveReadableContainer {
                let pageNumber = position.viewID as? Int ?? 0

                ScrollPagingView(
                    showPaging: .constant(true),
                    activePage: Binding(get: { pageNumber }, set: { _ in }),
                    dotsCount: presenter.totalPages
                )
                VStack(spacing: .XL) {
                    TFButton(
                        presenter.buttonTitle(for: pageNumber),
                        variant: .borderedProminent,
                        size: .medium,
                        applyGlass: true
                    ) {
                        switch presenter.buttonAction(for: pageNumber) {
                        case .manually(let data): presenter.onManually(data: data)
                        case .scanner: presenter.onScanner()
                        case .next:
                            if pageNumber < presenter.totalPages - 1 {
                                withAnimation {
                                    position.scrollTo(id: pageNumber + 1)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct PageView: View {
    @Environment(\.colorScheme)
    private var colorScheme
    
    let icon: UIImage
    let description: AttributedString
    let pageNumber: Int
    
    var body: some View {
        AdaptiveReadableContainer {
            VStack(alignment: .center, spacing: .L) {
                Text("Step \(pageNumber + 1)")
                    .textStyle(.title1, .emphasized)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.labelsPrimary)
                Text(attrString(with: description))
                    .textStyle(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.labelsSecondary)
                Spacer()
                Image(uiImage: icon)
                    .accessibilityHidden(true)
                Spacer()
            }
        }
    }
    
    private func attrString(with attrString: AttributedString) -> AttributedString {
        var str = attrString
        str.foregroundColor = AppColor.labelsSecondary.color(for: colorScheme)
        return str
    }
}
