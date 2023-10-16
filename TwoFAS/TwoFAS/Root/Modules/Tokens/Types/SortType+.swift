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

extension SortType {
    var localized: String {
        switch self {
        case .az: return T.Tokens.sortByAToZ
        case .za: return T.Tokens.sortByZToA
        case .manual: return T.Tokens.sortByManual
        }
    }
    
    func image(forSelectedOption option: Self) -> UIImage {
        let configuration = UIImage.SymbolConfiguration(weight: .bold)
        var img: UIImage?
        switch self {
        case .az: img = UIImage(systemName: "arrow.down")
        case .za: img = UIImage(systemName: "arrow.up")
        case .manual: img = UIImage(systemName: "line.3.horizontal") 
        }
        
        if self == option {
            img = img?.withConfiguration(configuration)
        }
        
        return img?.apply(Theme.Colors.Icon.theme)?.withRenderingMode(.alwaysOriginal) ?? UIImage()
    }
}
