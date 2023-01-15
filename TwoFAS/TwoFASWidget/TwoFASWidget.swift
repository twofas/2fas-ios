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

import WidgetKit
import SwiftUI
import Intents

struct TwoFASWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            if let first = entry.entries.first {
                TwoFASWidgetSquareView(entry: first)
            } else {
                Text("widget_size_not_supported")
            }
        case .systemMedium:
            TwoFASWidgetLineView(entries: entry.entries)
        case .systemLarge:
            TwoFASWidgetLineView(entries: entry.entries)
        case .systemExtraLarge:
            TwoFASWidgetLineViewGrid(entries: entry.entries)
        default:
            Text("widget_size_not_supported")
        }
    }
}

//
@main
struct TwoFASWidget: Widget {
    let kind: String = "TwoFASWidget"
    
    var supportedFamilies: [WidgetFamily] = {
        [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
    }()
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectServiceIntent.self, provider: Provider()) { entry in
            TwoFASWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("2FAS")
        .description("widget_settings_description")
        .supportedFamilies(supportedFamilies)
    }
}

struct TwoFASWidget_Previews: PreviewProvider {
    static var previews: some View {
        TwoFASWidgetEntryView(entry: CodeEntry.snapshot(with: WidgetFamily.systemLarge.servicesCount))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
