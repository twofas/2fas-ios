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

protocol SectionInteracting: AnyObject {
    var isSectionZeroCollapsed: Bool { get }
    var hasSections: Bool { get }
    func section(for serviceSecret: String) -> SectionData?
    func section(for sectionID: SectionID) -> SectionData?
    func listSections() -> [SectionData]
    func moveServiceToSection(move serviceSecret: String, to sectionID: SectionID?)
    func create(with title: String)
    
    func setSectionZeroIsCollapsed(_ isCollapsed: Bool)
    func collapse(_ section: SectionData, isCollapsed: Bool)
    
    func moveDown(_ sectionData: SectionData)
    func moveUp(_ sectionData: SectionData)
    func delete(_ sectionData: SectionData)
    func rename(_ sectionData: SectionData, newTitle: String)
    
    func findServices(for phrase: String, sort: SortType, tags: [ServiceTypeID]) -> [CategoryData]
    func move(service: ServiceData, from oldIndex: Int, to newIndex: Int, newSection: SectionData?)
    func listAll(sort: SortType) -> [CategoryData]
}

final class SectionInteractor {
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension SectionInteractor: SectionInteracting {
    var isSectionZeroCollapsed: Bool { mainRepository.isSectionZeroCollapsed }
    
    func setSectionZeroIsCollapsed(_ isCollapsed: Bool) {
        mainRepository.setSectionZeroIsCollapsed(isCollapsed)
    }
    
    func collapse(_ section: SectionData, isCollapsed: Bool) {
        mainRepository.collapseSection(section, isCollapsed: isCollapsed)
    }
    
    var hasSections: Bool {
        !listSections().isEmpty
    }
    
    func section(for serviceSecret: String) -> SectionData? {
        mainRepository.section(for: serviceSecret)
    }
    
    func listSections() -> [SectionData] {
        mainRepository.listAllSections()
    }
    
    func moveServiceToSection(move serviceSecret: String, to sectionID: SectionID?) {
        Log(
            "SectionInteractor - moveServiceToSection. SectionID: \(String(describing: sectionID))",
            module: .interactor
        )
        Log("Service secret: \(serviceSecret)", module: .interactor, save: false)
        mainRepository.moveServiceToSection(secret: serviceSecret, sectionID: sectionID)
    }
    
    func section(for sectionID: SectionID) -> SectionData? {
        mainRepository.listAllSections().first(where: { $0.sectionID == sectionID })
    }
    
    func create(with title: String) {
        Log("SectionInteractor - create section. Title: \(title)", module: .interactor)
        mainRepository.createSection(with: title)
    }
    
    func moveDown(_ sectionData: SectionData) {
        mainRepository.moveSectionDown(sectionData)
    }
    
    func moveUp(_ sectionData: SectionData) {
        mainRepository.moveSectionUp(sectionData)
    }
    
    func delete(_ sectionData: SectionData) {
        mainRepository.deleteSection(sectionData)
    }
    
    func rename(_ sectionData: SectionData, newTitle: String) {
        mainRepository.renameSection(sectionData, newTitle: newTitle)
    }
    
    func findServices(for phrase: String, sort: SortType, tags: [ServiceTypeID]) -> [CategoryData] {
        mainRepository.listAllServicesWithingCategories(for: phrase, sorting: sort, tags: tags)
    }
    
    func move(service: ServiceData, from oldIndex: Int, to newIndex: Int, newSection: SectionData?) {
        mainRepository.moveService(service, from: oldIndex, to: newIndex, newSection: newSection)
    }
    
    func listAll(sort: SortType) -> [CategoryData] {
        mainRepository.listAllServicesWithingCategories(for: nil, sorting: sort, tags: [])
    }
}
