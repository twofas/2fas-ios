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

public typealias DeviceID = String
public typealias GCMToken = String
public typealias ExtensionID = String
public typealias IconTypeName = String
public typealias ServiceTypeID = UUID
public typealias IconTypeID = UUID
public typealias SectionID = UUID
public typealias DeviceName = String
public typealias CloudStateListenerID = String
public typealias CloudStateListener = (CloudState) -> Void

public typealias Secret = String
public typealias TokenValue = String

public extension IconTypeID {
    static let `default`: IconTypeID = UUID(uuidString: "A5B3FB65-4EC5-43E6-8EC1-49E24CA9E7AD")!
}

public extension TokenValue {
    static let empty = "000000"
}

public typealias Callback = () -> Void
