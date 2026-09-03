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

public enum TintColor: String, Hashable, CaseIterable, Codable {
    case `default`
    case red
    case orange
    case yellow
    case green
    case turquoise
    case lightBlue
    case indigo
    case pink
    case purple
    case brown
}

public extension TintColor {
    init?(optionalRawValue: String?) {
        guard let rawValue = optionalRawValue else { return nil }
        self.init(rawValue: rawValue)
    }
    
    init(optionalWithDefaultRawValue: String?) {
        if let rawValue = optionalWithDefaultRawValue, let value = Self(rawValue: rawValue) {
            self = value
            return
        }
        self = Self.random
    }
    
    static var labelList: [TintColor] {
        TintColor.allCases.filter { $0 != .default }
    }
    
    static var random: TintColor {
        labelList.randomElement() ?? .lightBlue
    }
    
    static var badgeList: [TintColor] {
        TintColor.allCases
    }
    
    static func fromString(_ str: String) -> TintColor? {
        guard let tint = TintColor(rawValue: str) else { return nil }
        return tint
    }
    
    static func fromString(_ str: String?, defaultValue: TintColor = .default) -> TintColor {
        guard let str, let value = fromString(str) else { return defaultValue }
        return value
    }
    
    static func fromImportString(_ str: String) -> TintColor? {
        switch str {
        case "Default": return .default
        case "LightBlue": return .lightBlue
        case "Indigo": return .indigo
        case "Purple": return .purple
        case "Turquoise": return .turquoise
        case "Green": return .green
        case "Red": return .red
        case "Orange": return .orange
        case "Yellow": return .yellow
        case "Pink": return .pink
        case "Brown": return .brown
        default:
            return nil
        }
    }
    
    var toExportString: String {
        switch self {
        case .`default`: return "Default"
        case .lightBlue: return "LightBlue"
        case .indigo: return "Indigo"
        case .purple: return "Purple"
        case .turquoise: return "Turquoise"
        case .green: return "Green"
        case .red: return "Red"
        case .orange: return "Orange"
        case .yellow: return "Yellow"
        case .pink: return "Pink"
        case .brown: return "Brown"
        }
    }
    
#if os(iOS)
    var color: UIColor {
        switch self {
        case .`default`: AppColor.accentsDefault.uiColor
        case .lightBlue: AppColor.accentsBlue.uiColor
        case .indigo: AppColor.accentsIndigo.uiColor
        case .purple: AppColor.accentsPurple.uiColor
        case .turquoise: AppColor.accentsTeal.uiColor
        case .green: AppColor.accentsGreen.uiColor
        case .red: AppColor.accentsBrand.uiColor
        case .orange: AppColor.accentsOrange.uiColor
        case .yellow: AppColor.accentsYellow.uiColor
        case .pink: AppColor.accentsPink.uiColor
        case .brown: AppColor.accentsBrown.uiColor
        }
    }
#endif
    
    func color(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .`default`: AppColor.accentsDefault.color(for: colorScheme)
        case .lightBlue: AppColor.accentsBlue.color(for: colorScheme)
        case .indigo: AppColor.accentsIndigo.color(for: colorScheme)
        case .purple: AppColor.accentsPurple.color(for: colorScheme)
        case .turquoise: AppColor.accentsTeal.color(for: colorScheme)
        case .green: AppColor.accentsGreen.color(for: colorScheme)
        case .red: AppColor.accentsBrand.color(for: colorScheme)
        case .orange: AppColor.accentsOrange.color(for: colorScheme)
        case .yellow: AppColor.accentsYellow.color(for: colorScheme)
        case .pink: AppColor.accentsPink.color(for: colorScheme)
        case .brown: AppColor.accentsBrown.color(for: colorScheme)
        }
    }
}
