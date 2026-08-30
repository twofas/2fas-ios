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

public struct TFInfoContent: View {
    private let animDelay: CGFloat = 0.4
    
    public enum Icon {
        case systemImage(String)
        case image(UIImage, Image.TemplateRenderingMode)
        case view(view: AnyView)
    }

    private let icon: Icon
    private let title: String
    private let subtitle: String?
    private let description: String?
    private let attributedDescription: AttributedString?

    @State private var animateIcon = false

    public init(
        icon: Icon,
        title: String,
        subtitle: String? = nil,
        description: String? = nil,
        attributedDescription: AttributedString? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.attributedDescription = attributedDescription
    }
    
    public var body: some View {
        VStack(spacing: .M) {
            iconView
                .padding(.bottom, .M)
                .accessibilityHidden(true)
            
            Text(title)
                .textStyle(.title2, .emphasized)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .textStyle(.title2)
                    .foregroundStyle(.accentsBrand)
                    .foregroundStyle(.labelsSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if let description, !description.isEmpty {
                Text(description)
                    .textStyle(.callout)
                    .foregroundStyle(.labelsSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if let attributedDescription {
                Text(attributedDescription)
                    .textStyle(.callout)
                    .foregroundStyle(.labelsSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case let .systemImage(name):
            Image(systemName: name)
                .textStyle(.iconLarge)
                .foregroundStyle(.accentsBrand)
                .symbolEffect(.bounce.down, value: animateIcon)
                .task {
                    try? await Task.sleep(for: .seconds(animDelay))
                    animateIcon = true
                }
        case let .image(image, renderingMode):
            Group {
                switch renderingMode {
                case .original:
                    Image(uiImage: image)
                        .renderingMode(.original)
                        .resizable()
                case .template:
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .resizable()
                        .foregroundStyle(.accentsBrand)
                @unknown default:
                    EmptyView()
                }
            }
            .scaledToFit()
            .frame(width: 41, height: 41)
        case let .view(view):
            view
        }
    }
}
