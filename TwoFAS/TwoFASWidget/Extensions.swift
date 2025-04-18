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

import WidgetKit
import SwiftUI
import Intents
import Common

extension CodeEntry {
    static func placeholder(with serviceCount: Int) -> CodeEntry {
        let data: [Entry] = (0..<serviceCount).map { _ in Entry(
            kind: .placeholder,
            data: .createSnapshot()
        )}
        return .init(date: Date(), entries: data)
    }
    
    static func snapshot(with serviceCount: Int) -> CodeEntry {
        let data: [Entry] = (0..<serviceCount).map { _ in Entry(
            kind: .singleEntry,
            data: .createSnapshot()
        )}
        return .init(date: Date(), entries: data)
    }
}

extension CodeEntry.Entry {
    static func placeholder() -> Self {
        .init(kind: .placeholder, data: .createSnapshot())
    }
}

extension CodeEntry.EntryData {
    static func createSnapshot() -> Self {
        let theID = UUID().uuidString
        return .init(
            id: theID,
            secret: theID,
            name: "2FAS",
            info: String(localized: "widget__my_secured_account"),
            iconType: .brand,
            labelTitle: "2F",
            labelColor: .red,
            iconTypeID: IconTypeID.default,
            code: "127 924",
            countdownTo: nil,
            rawEntry: nil
        )
    }
}

extension WidgetFamily {
    var servicesCount: Int {
        switch self {
        case .systemSmall: 1
        case .systemMedium: 3
        case .systemLarge: 6
        case .systemExtraLarge: 12
        case .accessoryCircular: 1
        case .accessoryInline: 1
        case .accessoryRectangular: 1
        default: 1
        }
    }
    
    var isClickable: Bool {
        switch self {
        case .systemSmall: true
        case .systemMedium: true
        case .systemLarge: true
        case .systemExtraLarge: true
        default: false
        }
    }
}

struct CodableImage: Codable, Hashable, Identifiable {
    var id: Int {
        imageInstance?.hash ?? 0
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(imageInstance?.hash ?? 0)
    }
    
    private let imageInstance: UIImage?
    
    var image: UIImage {
        imageInstance ?? UIImage()
    }

    init(image: UIImage) {
        self.imageInstance = image
    }

    enum CodingKeys: CodingKey {
        case data
        case scale
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let scale = try container.decode(CGFloat.self, forKey: .scale)
        let data = try container.decode(Data.self, forKey: .data)
        self.imageInstance = UIImage(data: data, scale: scale)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let image = self.imageInstance {
            try container.encode(image.pngData(), forKey: .data)
            try container.encode(image.scale, forKey: .scale)
        }
    }
}
