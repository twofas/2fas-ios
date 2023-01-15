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

import SwiftUI

extension View {
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
    
    @ViewBuilder func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
         if conditional {
            AnyView(content(self))
         } else {
            AnyView(self)
         }
     }
    
    @ViewBuilder func ifElse<Content: View>(
        _ conditional: Bool,
        @ViewBuilder contentIf: (Self) -> Content,
        @ViewBuilder contentElse: (Self) -> Content
    ) -> some View {
         if conditional {
            AnyView(contentIf(self))
         } else {
            AnyView(contentElse(self))
         }
     }
    
    @inlinable
    func modify<T: View>(@ViewBuilder modifier: (Self) -> T) -> T {
        modifier(self)
    }
}
