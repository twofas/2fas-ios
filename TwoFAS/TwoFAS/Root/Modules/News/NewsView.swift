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

struct NewsView: View {
    @Bindable
    var presenter: NewsPresenter
    
    private let circleSize: CGFloat = 40
    private let iconSize: CGFloat = 28
    private let dotSize: CGFloat = 8
    
    var body: some View {
        NavigationStack {
            Group {
                if presenter.list.isEmpty {
                    emptyContent()
                } else {
                    list()
                }
            }
            .navigationTitle(T.Commons.notifications)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presenter.close()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .onAppear {
                presenter.viewDidAppear()
            }
        }
    }

    @ViewBuilder
    private func emptyContent() -> some View {
        TFEmptyScreen(
            image: Asset.emptyNotifications.image,
            title: T.Notifications.noNotifications
        )
    }
    
    @ViewBuilder
    private func list() -> some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: .zero) {
                ForEach(Array(presenter.list.enumerated()), id: \.element.id) { index, cell in
                    AdaptiveReadableContainer {
                        Button {
                            presenter.handleSelection(at: index)
                        } label: {
                            row(for: cell)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func row(for cell: NewsCell) -> some View {
        HStack(alignment: .top, spacing: .XL) {
            leadingIcon(for: cell)
            
            VStack(alignment: .leading, spacing: .S) {
                Text(cell.title)
                    .textStyle(.subheadline)
                    .foregroundStyle(.labelsSecondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(cell.publishedAgo)
                    .textStyle(.footnote)
                    .foregroundStyle(.labelsTertiary)
            }
            
            Spacer()
                        
            actionIcon()
                .isHidden(!cell.hasURL, remove: false)
        }
        .padding(.top, .XXXL)
    }
    
    @ViewBuilder
    private func leadingIcon(for cell: NewsCell) -> some View {
        ZStack {
            Circle()
                .foregroundStyle(.accentsBlue)
                .frame(width: circleSize, height: circleSize)
            
            Image(uiImage: cell.icon)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.graysWhite)
                .frame(width: iconSize, height: iconSize)
            
            if !cell.wasRead {
                Circle()
                    .foregroundStyle(.accentsBrand)
                    .frame(width: dotSize, height: dotSize)
                    .overlay {
                        Circle()
                            .inset(by: -0.75)
                            .stroke(.backgroundsPrimary, lineWidth: 1.5)
                            .frame(width: dotSize, height: dotSize)
                    }
                    .frame(width: circleSize, height: circleSize, alignment: .topTrailing)
            }
        }
    }
    
    @ViewBuilder
    private func actionIcon() -> some View {
        Image(systemName: "arrow.up.right")
            .renderingMode(.template)
            .foregroundStyle(.labelsTertiary)
    }
}
