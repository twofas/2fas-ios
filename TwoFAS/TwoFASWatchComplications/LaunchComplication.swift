//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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
//  along with this program. If not, see <https://www.gnu.org/licenses/>.
//

import SwiftUI
import WidgetKit

struct LaunchEntry: TimelineEntry {
    let date: Date
}

struct LaunchProvider: TimelineProvider {
    func placeholder(in context: Context) -> LaunchEntry {
        LaunchEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (LaunchEntry) -> Void) {
        completion(LaunchEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LaunchEntry>) -> Void) {
        // The launcher has no changing content and needs no scheduled refreshes.
        completion(Timeline(entries: [LaunchEntry(date: .now)], policy: .never))
    }
}

struct LaunchComplicationView: View {
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            switch family {
            case .accessoryInline:
                Label("2FAS", systemImage: "key.fill")
            case .accessoryRectangular:
                Label("2FAS", systemImage: "key.fill")
                    .font(.headline)
            default:
                Image(systemName: "key.fill")
                    .font(.title2)
                    .widgetAccentable()
            }
        }
        .accessibilityLabel(Text("Open 2FAS"))
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

@main
struct LaunchComplication: Widget {
    let kind = "TwoFASWatchLauncher"

    var body: some WidgetConfiguration {
        // Without a custom widget URL, tapping opens the containing Watch app
        // at its normal entry point, including its existing PIN protection.
        StaticConfiguration(kind: kind, provider: LaunchProvider()) { _ in
            LaunchComplicationView()
        }
        .configurationDisplayName("2FAS")
        .description("Open 2FAS on your Apple Watch.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}
