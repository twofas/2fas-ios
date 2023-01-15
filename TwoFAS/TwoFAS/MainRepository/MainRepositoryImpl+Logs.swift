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
import Common
import Storage
import DeviceKit

extension MainRepositoryImpl {
    func generateLogs() -> String {
        storage.log.listAll()
            .map { entry in
                LogPrinter.format(
                    content: entry.content,
                    timestamp: entry.timestamp,
                    module: entry.module,
                    severity: entry.severity
                )
            }
            .joined(separator: "\n")
    }
    
    var totalDiskSpace: String {
        ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.file)
    }
    
    var freeDiskSpace: String {
        ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.file)
    }
    
    var usedDiskSpace: String {
        ByteCountFormatter.string(fromByteCount: usedDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.file)
    }
    
    var currentDevice: String {
        Device.current.safeDescription
    }
    
    var systemVersion: String {
        UIDevice.current.systemVersion
    }
    
    // MARK: Get raw value
    private var totalDiskSpaceInBytes: Int64 {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value
            return space ?? 0
        } catch {
            return 0
        }
    }
    
    private var freeDiskSpaceInBytes: Int64 {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
            return freeSpace ?? 0
        } catch {
            return 0
        }
    }
    
    private var usedDiskSpaceInBytes: Int64 { totalDiskSpaceInBytes - freeDiskSpaceInBytes }
}
