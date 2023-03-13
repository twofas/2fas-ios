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
import Common
import Storage

protocol ComposeServiceCategorySelectionModuleInteracting: AnyObject {
    var selectedSection: SectionID? { get }
    
    func listSections() -> [SectionData]
    func addSection(with title: String)
    func setSelection(_ sectionID: SectionID?)
}

final class ComposeServiceCategorySelectionModuleInteractor {
    private let sectionInteractor: SectionInteracting
    private(set) var selectedSection: SectionID?
    
    init(sectionInteractor: SectionInteracting, selectedSection: SectionID?) {
        self.sectionInteractor = sectionInteractor
        self.selectedSection = selectedSection
    }
}

extension ComposeServiceCategorySelectionModuleInteractor: ComposeServiceCategorySelectionModuleInteracting {
    func listSections() -> [SectionData] {
        sectionInteractor.listSections()
    }
    
    func addSection(with title: String) {
        sectionInteractor.create(with: title)
    }
    
    func setSelection(_ sectionID: SectionID?) {
        selectedSection = sectionID
    }
}
