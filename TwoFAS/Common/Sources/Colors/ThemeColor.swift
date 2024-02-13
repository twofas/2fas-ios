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

// swiftlint:disable all
public enum ThemeColor {
    private static let bundle = Bundle(for: CountdownTimer.self)
    public static let backgroundLight = UIColor.white
    public static let light = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.00)
    public static let dark = UIColor(red: 0.14, green: 0.12, blue: 0.13, alpha: 1.00)
    public static let tableBackground = UIColor.systemGroupedBackground
    public static let background = UIColor(named: "ColorBackground", in: bundle, compatibleWith: nil)!
    public static let settingsCellBackground = UIColor.secondarySystemGroupedBackground
    public static let tableSeparator = UIColor(named: "TableDivider", in: bundle, compatibleWith: nil)!
    public static let highlighed = UIColor(named: "ColorHighlighed", in: bundle, compatibleWith: nil)!
    public static let theme = UIColor(named: "ColorTheme", in: bundle, compatibleWith: nil)!
    public static let divider = UIColor(named: "ColorDivider", in: bundle, compatibleWith: nil)!
    public static let primary = UIColor(named: "ColorPrimary", in: bundle, compatibleWith: nil)!
    public static let secondary = UIColor(named: "ColorSecondary", in: bundle, compatibleWith: nil)!
    public static let secondarySofter = UIColor(named: "ColorSecondarySofter", in: bundle, compatibleWith: nil)!
    public static let tertiary = UIColor(named: "ColorTertiary", in: bundle, compatibleWith: nil)!
    public static let quaternary = UIColor(named: "ColorQuaternary", in: bundle, compatibleWith: nil)!
    public static let inactive = UIColor(named: "ColorInactive", in: bundle, compatibleWith: nil)!
    public static let decoratedContainer = UIColor(named: "ColorDecoratedContainer", in: bundle, compatibleWith: nil)!
    public static let decoratedContainerButton = UIColor(named: "ColorDecoratedContainerButton", in: bundle, compatibleWith: nil)!
    public static let inactiveInverted = UIColor(named: "ColorInactiveInverted", in: bundle, compatibleWith: nil)!
    public static let inactiveMoreContrast = UIColor(named: "ColorInactiveMoreContrast", in: bundle, compatibleWith: nil)!
    public static let decoratedContainerButtonInverted = UIColor(named: "ColorDecoratedContainerButtonInverted", in: bundle, compatibleWith: nil)!
    public static let overlay = UIColor(named: "ColorOverlay", in: bundle, compatibleWith: nil)!
    public static let cameraOverlay = UIColor(white: 0, alpha: 0.67)
    public static let uuidInputBackground = UIColor(named: "UUIDInputBackground", in: bundle, compatibleWith: nil)!
    public static let uuidInputText = UIColor(named: "UUIDInputText", in: bundle, compatibleWith: nil)!
    public static let buttonCloseBackground = UIColor(named: "ColorButtonCloseBackground", in: bundle, compatibleWith: nil)!
    public static let labelText = UIColor(named: "ColorLabelText", in: bundle, compatibleWith: nil)!
    public static let buttonCloseForeground = UIColor(named: "ColorButtonCloseForeground", in: bundle, compatibleWith: nil)!
    public static let activeLine = UIColor(named: "ColorActiveLine", in: bundle, compatibleWith: nil)!
    public static let secondarySeparator = UIColor(named: "ColorSecondarySeparator", in: bundle, compatibleWith: nil)!
    public static let selectionBorder = UIColor(named: "ColorSelectionBorder", in: bundle, compatibleWith: nil)!
    public static let labelTextBackground = UIColor(named: "ColorLabelTextBackground", in: bundle, compatibleWith: nil)!
    public static let pageIndicator = UIColor(named: "ColorPageIndicator", in: bundle, compatibleWith: nil)!
    public static let secondaryDivider = UIColor(named: "ColorSecondaryDivider", in: bundle, compatibleWith: nil)!
}
// swiftlint:enable all
