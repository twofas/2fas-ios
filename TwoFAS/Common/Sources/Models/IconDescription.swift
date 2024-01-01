//
//  IconDescription.swift
//
//
//  Created by Zbigniew Cisiński on 16/10/2023.
//

import UIKit

public struct IconDescription {
    public let iconTypeID: IconTypeID
    public let name: String
    
    public init(iconTypeID: IconTypeID, name: String) {
        self.iconTypeID = iconTypeID
        self.name = name
    }
}
