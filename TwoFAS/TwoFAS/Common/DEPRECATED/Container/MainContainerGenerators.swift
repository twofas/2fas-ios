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

// swiftlint:disable discouraged_optional_boolean
struct MainContainerBarConfiguration: MainContainerBarConfigurable {
    let title: String?
    let left: MainContainerViewController.LeftBarButton?
    let right: MainContainerViewController.RightBarButton?
    let hideTabBar: Bool?
    let hideNavigationBar: Bool?
    let statusBar: MainContainerViewController.StatusBar?
}
// swiftlint:enable discouraged_optional_boolean

struct MainContainerTopContentGenerator: MainContainerContentGeneratable {
    let placement: MainContainerViewController.ViewPlacement
    let elements: [MainContainerContentGenerator.Element]
    
    func generate() -> UIView { MainContainerContentGenerator.generate(from: elements) }
}

struct MainContainerMiddleContentGenerator: MainContainerContentGeneratable {
    let placement: MainContainerViewController.ViewPlacement
    let elements: [MainContainerContentGenerator.Element]
    
    func generate() -> UIView { MainContainerContentGenerator.generate(from: elements) }
}

struct MainContainerBottomContentGenerator: MainContainerContentGeneratable {
    let placement: MainContainerViewController.ViewPlacement = .centerHorizontallyLimitWidth
    let elements: [MainContainerBottomNavigationGenerator.Element]
    
    func generate() -> UIView { MainContainerBottomNavigationGenerator.generate(from: elements) }
}

struct MainContainerForceLightMode: MainContainerGeneralConfigurable {
    var interfaceStyle: UIUserInterfaceStyle { .light }
    var userDidUseEnterKey: Callback?
}

struct MainContainerForceDarkMode: MainContainerGeneralConfigurable {
    var interfaceStyle: UIUserInterfaceStyle { .dark }
    var userDidUseEnterKey: Callback?
}

struct MainContainerNonScrollable: MainContainerGeneralConfigurable {
    var interfaceStyle: UIUserInterfaceStyle { .unspecified }
    var userDidUseEnterKey: Callback?
    var isScrollEnabled: Bool { false }
}

extension MainContainerBarConfiguration {
    static var empty: MainContainerBarConfiguration {
        .init(title: nil, left: nil, right: nil, hideTabBar: nil, hideNavigationBar: nil, statusBar: nil)
    }
    static func statusBar(_ statusBar: MainContainerViewController.StatusBar) -> MainContainerBarConfiguration {
        .init(title: nil, left: nil, right: nil, hideTabBar: nil, hideNavigationBar: nil, statusBar: statusBar)
    }
}
