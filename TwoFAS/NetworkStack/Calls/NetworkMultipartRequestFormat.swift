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

protocol NetworkMultipartRequestFormat {
    var path: String { get }
    var method: HTTPMethod { get }
    
    var boundary: String { get }
    var httpBody: NSMutableData { get }
}

extension NetworkMultipartRequestFormat {
    func addTextField(
        named name: String,
        value: String
    ) {
        httpBody.append(textFormField(named: name, value: value))
    }

    private func textFormField(
        named name: String,
        value: String
    ) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: text/plain; charset=utf-8\r\n"
        fieldString += "Content-Transfer-Encoding: 8bit\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"

        return fieldString
    }

    func addDataField(
        named name: String,
        data: Data,
        mimeType: String
    ) {
        httpBody.append(dataFormField(named: name, data: data, mimeType: mimeType))
    }

    private func dataFormField(
        named name: String,
        data: Data,
        mimeType: String
    ) -> Data {
        let fieldData = NSMutableData()

        fieldData.append("--\(boundary)\r\n")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"\r\n")
        fieldData.append("Content-Type: \(mimeType)\r\n")
        fieldData.append("\r\n")
        fieldData.append(data)
        fieldData.append("\r\n")

        return fieldData as Data
    }
    
    func addFileField(
        named name: String,
        data: Data,
        filename: String,
        mimeType: String
    ) {
        httpBody.append(
            dataFormField(named: name, data: data, filename: filename, mimeType: mimeType)
        )
    }

    private func dataFormField(
        named name: String,
        data: Data,
        filename: String,
        mimeType: String
    ) -> Data {
        let fieldData = NSMutableData()

        fieldData.append("--\(boundary)\r\n")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
        fieldData.append("Content-Type: \(mimeType); charset=utf-8\r\n")
        fieldData.append("\r\n")
        fieldData.append(data)
        fieldData.append("\r\n")
        fieldData.append("\r\n")

        return fieldData as Data
    }
    
    func seal() {
        httpBody.append("--\(boundary)--")
    }
}
