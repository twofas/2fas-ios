//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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

import Foundation
import AppIntents

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
struct SelectService: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "SelectServiceIntent"

    static var title = LocalizedStringResource("tokens__select_service")
    static var description = IntentDescription(LocalizedStringResource("widget__settings_description"))
    
    @Parameter(
        title: "Service",
        size: [
        .systemSmall: 1,
        .systemMedium: 3,
        .systemLarge: 6,
        .systemExtraLarge: 12,
        .accessoryCircular: 1,
        .accessoryRectangular: 1,
        .accessoryInline: 1
        ]
    )
    var service: [ServiceAppEntity]

    init() {
        self.service = [.init(id: "Test", displayString: "Test", secret: "Test")]
    }
    
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
}
