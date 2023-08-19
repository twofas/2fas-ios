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

import Foundation

protocol MainSplitModuleInteracting: AnyObject {
    func currentSettingsPath() -> ViewPath.Settings?
    func saveCurrentSettingsPath(_ settingsPath: ViewPath.Settings?)
    
    func restoreViewPath() -> ViewPath?
    func setViewPath(_ viewPath: ViewPath)
    
    var isMenuPortraitOverlayCollapsed: Bool { get }
    func handlePortraitMenuOverlayCollapsed(_ isCollapsed: Bool)
    var isMenuLandscapeCollapsed: Bool { get }
    func handleLandscapeMenuCollapsed(_ isCollapsed: Bool)
    
    var hasUnreadNews: Bool { get }
    var hasStoredURL: Bool { get }
    func markNewsAsRead()
    func fetchNews(completion: @escaping () -> Void)
}

final class MainSplitModuleInteractor {
    private var settingsPath: ViewPath.Settings?
    
    private let viewPathInteractor: ViewPathIteracting
    private let newsInteractor: NewsInteracting
    private let linkInteractor: LinkInteracting
    private let appearanceInteractor: AppearanceInteracting
    
    init(
        viewPathInteractor: ViewPathIteracting,
        newsInteractor: NewsInteracting,
        linkInteractor: LinkInteracting,
        appearanceInteractor: AppearanceInteracting
    ) {
        self.viewPathInteractor = viewPathInteractor
        self.newsInteractor = newsInteractor
        self.linkInteractor = linkInteractor
        self.appearanceInteractor = appearanceInteractor
    }
}

extension MainSplitModuleInteractor: MainSplitModuleInteracting {
    var hasUnreadNews: Bool {
        newsInteractor.hasUnreadNews
    }
    
    var hasStoredURL: Bool {
        linkInteractor.hasStoredURL
    }
    
    func restoreViewPath() -> ViewPath? {
        viewPathInteractor.viewPath()
    }
    
    func setViewPath(_ viewPath: ViewPath) {
        viewPathInteractor.setViewPath(viewPath)
    }
    
    func currentSettingsPath() -> ViewPath.Settings? {
        settingsPath
    }
    
    func saveCurrentSettingsPath(_ settingsPath: ViewPath.Settings?) {
        self.settingsPath = settingsPath
    }
    
    func markNewsAsRead() {
        newsInteractor.clearHasUnreadNews()
    }
    
    func fetchNews(completion: @escaping () -> Void) {
        newsInteractor.fetchList(completion: completion)
    }
    
    var isMenuPortraitOverlayCollapsed: Bool {
        appearanceInteractor.isPortraitMainMenuCollapsed
    }
    
    func handlePortraitMenuOverlayCollapsed(_ isCollapsed: Bool) {
        appearanceInteractor.setIsMenuPortraitCollapsed(isCollapsed)
    }
    
    var isMenuLandscapeCollapsed: Bool {
        appearanceInteractor.isMenuLandscapeCollapsed
    }
    
    func handleLandscapeMenuCollapsed(_ isCollapsed: Bool) {
        appearanceInteractor.setIsMenuLandscapeCollapsed(isCollapsed)
    }
}
