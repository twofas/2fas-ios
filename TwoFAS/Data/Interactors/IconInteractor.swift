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

public protocol IconInteracting: AnyObject {
    func iconTypeID(for serviceTypeID: ServiceTypeID?) -> UIImage
    func grouppedList() -> [IconDescriptionGroup]
    func iconName(for iconTypeID: IconTypeID) -> String?
}

final class IconInteractor {
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension IconInteractor: IconInteracting {
    func iconTypeID(for serviceTypeID: ServiceTypeID?) -> UIImage {
        mainRepository.iconTypeID(for: serviceTypeID)
    }
    
    func grouppedList() -> [IconDescriptionGroup] {
        mainRepository.grouppedList()
    }
    
    func iconName(for iconTypeID: IconTypeID) -> String? {
        mainRepository.iconName(for: iconTypeID)
    }
}
