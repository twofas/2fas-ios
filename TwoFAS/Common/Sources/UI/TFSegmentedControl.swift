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

public struct TFSegmentedControl<Value: Hashable>: View {
    public struct Segment: Identifiable {
        public let value: Value
        public let title: String

        public var id: Value { value }

        public init(value: Value, title: String) {
            self.value = value
            self.title = title
        }
    }

    @Binding
    private var selection: Value
    private let segments: [Segment]

    @Namespace
    private var namespace
    @Environment(\.colorScheme)
    private var colorScheme

    @ScaledMetric(relativeTo: .subheadline)
    private var segmentMinWidth: CGFloat = 96

    private var pillColor: AppColor {
        colorScheme == .dark ? .graysGray2 : .graysWhite
    }

    private let selectionID = "TFSegmentedControlSelection"

    public init(selection: Binding<Value>, segments: [Segment]) {
        self._selection = selection
        self.segments = segments
    }

    public var body: some View {
        HStack(spacing: .zero) {
            ForEach(segments) { segment in
                segmentButton(segment)
            }
        }
        .padding(.S)
        .fixedSize()
        .background {
            Capsule()
                .foregroundStyle(AppColor.backgroundsGroupedTertiary)
        }
        .animation(.snappy(duration: AnimationTiming.duration), value: selection)
        .sensoryFeedback(.selection, trigger: selection)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func segmentButton(_ segment: Segment) -> some View {
        let isSelected = segment.value == selection
        Button {
            guard !isSelected else { return }
            selection = segment.value
        } label: {
            Text(segment.title)
                .textStyle(.subheadline, isSelected ? .emphasized : .regular)
                .foregroundStyle(.labelsPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.vertical, .S)
                .padding(.horizontal, .L)
                .frame(minWidth: segmentMinWidth)
                .background {
                    if isSelected {
                        Capsule()
                            .foregroundStyle(pillColor)
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                            .matchedGeometryEffect(id: selectionID, in: namespace)
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    TFSegmentedControlPreview()
}

private struct TFSegmentedControlPreview: View {
    @State
    private var selection = 0

    var body: some View {
        TFSegmentedControl(
            selection: $selection,
            segments: [
                .init(value: 0, title: "Icon"),
                .init(value: 1, title: "Label")
            ]
        )
        .padding()
    }
}
