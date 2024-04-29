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

import UIKit
#if os(watchOS)
import SwiftUI
#endif

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
    
    static func fromImportString(_ str: String?, defaultValue: TintColor = .default) -> TintColor {
        guard let str, let value = fromImportString(str) else { return defaultValue }
        return value
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
        let bundle = Bundle(for: CountdownTimer.self)
        switch self {
        case .`default`: return UIColor(named: "tintDefaultColor", in: bundle, compatibleWith: nil)!
        case .lightBlue: return UIColor(named: "tintLightBlueColor", in: bundle, compatibleWith: nil)!
        case .indigo: return UIColor(named: "tintIndigoColor", in: bundle, compatibleWith: nil)!
        case .purple: return UIColor(named: "tintPurpleColor", in: bundle, compatibleWith: nil)!
        case .turquoise: return UIColor(named: "tintTurquoiseColor", in: bundle, compatibleWith: nil)!
        case .green: return UIColor(named: "tintGreenColor", in: bundle, compatibleWith: nil)!
        case .red: return UIColor(named: "tintRedColor", in: bundle, compatibleWith: nil)!
        case .orange: return UIColor(named: "tintOrangeColor", in: bundle, compatibleWith: nil)!
        case .yellow: return UIColor(named: "tintYellowColor", in: bundle, compatibleWith: nil)!
        case .pink: return UIColor(named: "tintPinkColor", in: bundle, compatibleWith: nil)!
        case .brown: return UIColor(named: "tintBrownColor", in: bundle, compatibleWith: nil)!
        }
    }
    #elseif os(watchOS)
    var color: Color {
        let bundle = Bundle(for: CoreDataStack.self)
        switch self {
        case .`default`: return Color("tintDefaultColor", bundle: bundle)
        case .lightBlue: return Color("tintLightBlueColor", bundle: bundle)
        case .indigo: return Color("tintIndigoColor", bundle: bundle)
        case .purple: return Color("tintPurpleColor", bundle: bundle)
        case .turquoise: return Color("tintTurquoiseColor", bundle: bundle)
        case .green: return Color("tintGreenColor", bundle: bundle)
        case .red: return Color("tintRedColor", bundle: bundle)
        case .orange: return Color("tintOrangeColor", bundle: bundle)
        case .yellow: return Color("tintYellowColor", bundle: bundle)
        case .pink: return Color("tintPinkColor", bundle: bundle)
        case .brown: return Color("tintBrownColor", bundle: bundle)
        }
    }
    #endif
}
