//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
//  Contributed by Grzegorz Machnio. All rights reserved.
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
import CommonWatch

public struct KeyboardButton: ButtonStyle {
    let press: (() -> Void)?
    let release: (() -> Void)?

    init(press: (() -> Void)? = nil, release: (() -> Void)? = nil) {
        self.press = press
        self.release = release
    }

    public func makeBody(configuration: Configuration) -> some View {
        GeometryReader(content: { geometry in
            if configuration.isPressed {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.7))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .scaleEffect(1.1)
            } else {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.6))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .scaleEffect(1)
            }

            configuration.label
                .background(
                    ZStack {
                        GeometryReader(content: { geometry in
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.clear)
                                .frame(
                                    width: configuration.isPressed ? geometry.size.width / 0.75 : geometry.size.width,
                                    height: configuration.isPressed ? geometry.size.height / 0.8 : geometry.size.height
                                )
                        })
                    }
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                .scaleEffect(configuration.isPressed ? 1.2 : 1)
        })
        .onChange(of: configuration.isPressed) { old, new in
            if new {
                press?()
                DispatchQueue.main.async {
                    WKInterfaceDevice().play(.click)
                }
            } else if old && !new {
                release?()
            }
        }
    }
}

#Preview {
    VStack {
        Button("1") { }
            .foregroundColor(.black)
            .buttonStyle(KeyboardButton())
    }
}
