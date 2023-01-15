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

import XCTest
@testable import Protection

final class LocalKeyEncryptionTests: XCTestCase {
    private let encryption = LocalKeyEncryption()
    // swiftlint:disable all
    private let secrets = ["BA27PZTA3PNFKYXF", "I7NQAURMWN2IXNECANO2OUWFKAG6JMEI", "E6GRZC3W42MSYYSI", "O4YFG3KPJAZXOZ2Q", "LDHDOP4CCXRHFL6J", "HUV2LDVP3WJBRON3", "PI324BDI4AVFLUXY", "VJTQ6XK4L6QGTQOCYYODEUA", "JO2LCO7XJZ7QRM24", "637JDW5QD7VZ544C", "I56KRXCUOQ5JGHQE", "364MIIQUNNXU3SZF", "JCLV2DNC36AOGGK3", "P44PW2BI2EMSG3QINN5BJHXS3R2PTPAK", "HRASMVBRONZWEKKYNB2CU6LUGZ4FIOBYEZESIPZ6EEWH2ILQI4SQ", "OBLC6DP6BY2LJKM5QWVCIPMJQC37N3NB", "KBXX4D7KBFPJX2K7CN2Y2SD2", "F5KCQXX6SRQHSFHKSOQXJMFZPCOIXXQJ", "6AY42YEZWBV3H5O6", "OYLSIQIWTWU46EW7PMKLACJX2Y", "U23EEBINNDHWX5V7", "KGBCTBNNTDAYHPYY", "KRCGQKCIGXZJVQHM44KB2X443UFMPFTQ", "QOWLR7LSN5UU32T5", "HZ3SYI2XZOZO3QSW", "TO7HAMPMGJ6FGVLO", "3X6TZXNODPVXPXGT", "JPKUROCNCDIKFDSR", "H2JVQVANNKUUWGS3XDALZZXHMIIMFMQABM4XQFBDF6O23P373RQA", "7ji5sgejmw4ikiad"]
    // swiftlint:enable all
    
    func testIncompletePasswordParts() {
        // GIVEN
        let secrets = self.secrets.map { $0.uppercased() }
        // WHEN
        // THEN
        secrets.forEach { original in
            let encrypted = encryption.encrypt(original)
            let decrypted = encryption.decrypt(encrypted)
            XCTAssertEqual(original, decrypted)
        }
    }
}
