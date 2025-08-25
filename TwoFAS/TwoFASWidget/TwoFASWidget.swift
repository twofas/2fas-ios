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
import Common

struct TwoFASWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    private var noEntryView: some View {
        VStack(alignment: .leading) {
            Image("TwoFASLogo")
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.widgetBackground)
                        .frame(width: 32, height: 32)
                )
            
            Spacer()

            Text(T.Widget.noSelectedServices)
                .foregroundStyle(.textAccent)
                .multilineTextAlignment(.leading)
                .font(.system(size: 16).weight(.semibold))
                .bold()
                .frame(maxWidth: 200, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(4)
        .addWidgetContentMargins()
        .widgetBackground(backgroundView: Color.accent)
    }

    @ViewBuilder
    var body: some View {
        if entry.entries.isEmpty || entry.entries.filter({ $0.kind != .placeholder }).isEmpty {
            noEntryView
        } else {
            Group {
                switch family {
                case .systemSmall:
                    TwoFASWidgetSquareView(entry: entry.entries.first)
                case .systemMedium:
                    TwoFASWidgetLineView(entries: entry.entries, isRevealTokenOverlayVisible: true)
                case .systemLarge:
                    TwoFASWidgetLineView(entries: entry.entries, isRevealTokenOverlayVisible: true)
                case .systemExtraLarge:
                    TwoFASWidgetLineViewGrid(entries: entry.entries)
                case .accessoryCircular:
                    TwoFASWidgetCircular(entry: entry.entries.first)
                case .accessoryRectangular:
                    TwoFASWidgetRectangular(entry: entry.entries.first)
                case .accessoryInline:
                    TwoFASWidgetInline(entry: entry.entries.first)
                default:
                    Text("widget__size_not_supported")
                }
            }
            .widgetBackground(backgroundView: Color.widgetBackground)
            .addWidgetContentMargins()
        }
    }
}

// MARK: - Widget Bundle

@main
struct TwoFASWidgetBundle: WidgetBundle {
    var body: some Widget {
        TwoFASWidget()
        
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, *) {
            TwoFASControlWidget()
        }
    }
}

// MARK: - Main TwoFAS Widget

struct TwoFASWidget: Widget {
    let kind: String = "TwoFASWidget"
    
    var supportedFamilies: [WidgetFamily] {
        if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
            [
                .systemSmall,
                .systemMedium,
                .systemLarge,
                .systemExtraLarge,
                .accessoryCircular,
                .accessoryRectangular,
                .accessoryInline
            ]
        } else {
            [
                .systemSmall,
                .systemMedium,
                .systemLarge,
                .systemExtraLarge
            ]
        }
    }
    
    @MainActor
    var body: some WidgetConfiguration {
        if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
            return AppIntentConfiguration(
                kind: kind,
                intent: SelectService.self,
                provider: AppIntentProvider()
            ) { entry in
                TwoFASWidgetEntryView(entry: entry)
            }
            .configurationDisplayName("2FAS")
            .description("widget__settings_description")
            .supportedFamilies(supportedFamilies)
        } else {
            return IntentConfiguration(kind: kind, intent: SelectServiceIntent.self, provider: Provider()) { entry in
                TwoFASWidgetEntryView(entry: entry)
            }
            .configurationDisplayName("2FAS")
            .description("widget__settings_description")
            .supportedFamilies(supportedFamilies)
        }
    }
}

// MARK: - Previews

struct TwoFASWidget_Previews: PreviewProvider {
    static var previews: some View {
        TwoFASWidgetEntryView(entry: CodeEntry.snapshot(with: WidgetFamily.accessoryRectangular.servicesCount))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}

// MARK: - Extensions

extension View {
    func widgetBackground(backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

extension WidgetConfiguration {
    func widgetNotInStandBy() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.disfavoredLocations([.standBy, .iPhoneWidgetsOnMac], for: [.systemSmall, .systemMedium])
        } else {
            return self
        }
    }
}
