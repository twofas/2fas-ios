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

extension ServiceMatchRules {
    public func isMatching(for value: String) -> Bool {
        let template: String = {
            if ignoreCase {
                return text.lowercased()
            }
            return text
        }()
        let value: String = {
            if ignoreCase {
                return value.lowercased()
            }
            return value
        }()
        switch self.matcher {
        case .contains:
            return value.contains(template)
        case .startsWith:
            return value.hasPrefix(template)
        case .endsWith:
            return value.hasSuffix(template)
        case .equals:
            return value == template
        case .regex:
            if let range = value.range(of: text, options: regexOptions), !value[range].isEmpty {
                return true
            }
            return false
        }
    }
    
    public func matchRegex(for value: String) -> String? {
        if let range = value.range(of: text, options: regexOptions), !value[range].isEmpty {
            return String(value[range])
        }
        return nil
    }
    
    var regexOptions: String.CompareOptions {
        var options: String.CompareOptions = [.regularExpression]
        if ignoreCase {
            options = [.regularExpression, .caseInsensitive]
        }
        return options
    }
}
