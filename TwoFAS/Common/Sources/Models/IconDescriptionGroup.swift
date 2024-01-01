//
//  IconDescriptionGroup.swift
//  
//
//  Created by Zbigniew Cisiński on 16/10/2023.
//

import Foundation

public struct IconDescriptionGroup {
    public let title: String
    public let icons: [IconDescription]
    
    public init(title: String, icons: [IconDescription]) {
        self.title = title
        self.icons = icons
    }
}
