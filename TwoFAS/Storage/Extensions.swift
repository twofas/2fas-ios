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
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

extension Array where Element: Equatable {
    mutating func move(_ element: Element, to newIndex: Index) {
        if let oldIndex: Int = self.firstIndex(of: element) {
            self.move(from: oldIndex, to: newIndex)
        }
    }
}

extension Array {
    mutating func move(from oldIndex: Index, to newIndex: Index) {
        guard oldIndex != newIndex else { return }
        
        if abs(newIndex - oldIndex) == 1 && newIndex < endIndex && oldIndex < endIndex {
            return swapAt(oldIndex, newIndex)
        }
        let obj = remove(at: oldIndex)
        let newIndex = {
            guard newIndex < endIndex else {
                return endIndex
            }
            return newIndex
        }()
        insert(obj, at: newIndex)
    }
}

extension Array where Element == ServiceEntity {
    func updateOrder() {
        for (index, s) in self.enumerated() {
            if s.sectionOrder != index {
                s.sectionOrder = index
            }
        }
    }
}

extension Collection where Element == ServiceEntity {
    func toServiceData() -> [ServiceData] {
        self.map(ServiceData.createFromManagedObject)
    }
}

extension ServiceEntity {
    func toServiceData() -> ServiceData {
        ServiceData.createFromManagedObject(entity: self)
    }
}

extension Array where Element == ServiceData {
    func contains(_ secret: String) -> Bool {
        self.first(where: { $0.secret == secret }) != nil
    }
}

extension Array where Element == SectionEntity {
    func transformToSectionData() -> [SectionData] {
        self.map({ SectionData.createFromManagedObject($0) })
    }
}

extension Array where Element == ServiceID {
    func encrypt() -> [ServiceID] {
        map({ $0.encrypt() })
    }
}

extension Dictionary where Key == SectionID?, Value == [ServiceData] {
    var allServices: [ServiceData] {
        reduce(into: [ServiceData]()) { partialResult, dict in
            partialResult += dict.value
        }
    }
}
