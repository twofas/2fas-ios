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
import Common

enum Theme {
    static func applyAppearance() {
        if #unavailable(iOS 26.0) {
            let bgImage = Asset.barsBackground.image
                .resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
            let shadowLine = Asset.shadowLine.image
                .resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .tile)

            let navibarAppearance = UINavigationBar.appearance()
            navibarAppearance.isTranslucent = false
            navibarAppearance.setBackgroundImage(bgImage, for: .any, barMetrics: .default)
            navibarAppearance.shadowImage = shadowLine
            navibarAppearance.backgroundColor = AppColor.backgroundsPrimary.uiColor
            navibarAppearance.tintColor = AppColor.accentsBrand.uiColor
            navibarAppearance.barTintColor = AppColor.accentsBrand.uiColor

            configureNavigationBarButtons(on: navibarAppearance)

            UIView.appearance(
                whenContainedInInstancesOf: [UIAlertController.self]
            ).tintColor = AppColor.accentsBrand.uiColor

            let tabBarAppearance = UITabBar.appearance()
            tabBarAppearance.backgroundColor = AppColor.backgroundsPrimary.uiColor
            tabBarAppearance.tintColor = AppColor.accentsBrand.uiColor
            tabBarAppearance.unselectedItemTintColor = AppColor.labelsTertiary.uiColor
            tabBarAppearance.shadowImage = shadowLine
            tabBarAppearance.backgroundImage = bgImage
            tabBarAppearance.isTranslucent = true
        }
    }

    private static func configureNavigationBarButtons(on navigationBar: UINavigationBar) {
        let brand = AppColor.accentsBrand.uiColor
        let appearances = [
            navigationBar.standardAppearance,
            navigationBar.compactAppearance,
            navigationBar.scrollEdgeAppearance,
            navigationBar.compactScrollEdgeAppearance
        ].compactMap { $0 }

        for appearance in appearances {
            appearance.backButtonAppearance = .chevronOnly
            for buttonAppearance in [appearance.buttonAppearance, appearance.doneButtonAppearance] {
                buttonAppearance.normal.titleTextAttributes[.foregroundColor] = brand
                buttonAppearance.highlighted.titleTextAttributes[.foregroundColor] = brand
                buttonAppearance.focused.titleTextAttributes[.foregroundColor] = brand
            }
        }
    }

    enum Alpha {
        static let disabledElement: CGFloat = 0.5
    }

    enum Animations {
        enum Timing {
            static let show: TimeInterval = 0.1
            static let quick: TimeInterval = 0.2
            static let displayNotification: TimeInterval = 2
        }
    }

    enum Metrics {
        static let lineWidth: CGFloat = ThemeMetrics.lineWidth
        static let separatorHeight: CGFloat = 0.5
        /// 6
        static let cornerRadius: CGFloat = 6
        /// 14
        static let modalCornerRadius: CGFloat = 14
        static let notificationMargin: CGFloat = 8

        static let cameraTopGradientHeigth: CGFloat = 150
        static let cameraBottomGradientHeigth: CGFloat = 180
        static let cameraActiveAreaSize: CGFloat = 230
        static let cameraActiveAreaYOffset: CGFloat = 20

        static let buttonHeight: CGFloat = 50

        /// 540 - preferowana szerokość arkuszy modalnych na iPadzie (regular width)
        static let modalPreferredWidth: CGFloat = 540
        /// 620 - preferowana wysokość dużych arkuszy modalnych na iPadzie (regular width)
        static let modalLargePreferredHeight: CGFloat = 620
        /// 360 - preferowana szerokość popoverów zakotwiczonych w treści (regular width)
        static let popoverPreferredWidth: CGFloat = 360
        /// 440 - preferowana szerokość popoverów informacyjnych z dłuższym tekstem
        static let popoverInfoPreferredWidth: CGFloat = 440

        /// 288
        static let componentWidth: CGFloat = 288
        /// 280
        static let compactCellWidth: CGFloat = 280
        /// 310
        static let defaultCellWidth: CGFloat = 310
    }
}
