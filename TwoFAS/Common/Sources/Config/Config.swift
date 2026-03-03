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

public enum Config {
    public static let tosURL = URL(string: "https://2fas.com/terms-of-service/")!
    public static let allowedTimeIntervalDifference: Int = 5
        
    public static let suiteName = "group.twofas.com"
    
    public static let exchangeTokenKey = "exchangeTokenKey"
    
    public static let hiddenSecret = "[hidden]"
    
    public enum API {
        public static let baseURL = URL(string: "https://api2.2fas.com")!
        public static let notificationsURL = URL(string: "https://notify.2fas.com")!
    }
    
    public enum TokenConsts {
        public static let formatTimerWhenSecondsOrLess: Int = 5
    }
    
    public static let maxIdentifierLength: Int = 128
    
    public static let maxSyncPasswordLength = 32
    public static let minSyncPasswordLength = 9

    public static let minQRCodeSize: CGFloat = 280    
    public static let twofasAuthOldScheme = "twofas"
    public static let twofasAuthNewScheme = "twofasauth"
    public static let twofasPassCheckLink = URL(string: "twofaspass://")!
    public static let twofasPassOpenLink = URL(string: "twofaspass://open")!
    public static let twofasPassAppStoreLink = URL(string: "itms-apps://itunes.apple.com/app/id6504464955")!
    
    public static let vaultV1 = "Vault1"
    public static let vaultV2 = "Vault2"
    public static let containerIdentifier = "iCloud.com.twofas.org.Vault"
    
    public enum PasswordCharacterSet {
        private static let space = [String(UnicodeScalar(32)!)]
        private static let digits = (48...57).map { String(UnicodeScalar($0)!) }
        private static let uppercase = (65...90).map { String(UnicodeScalar($0)!) }
        private static let special = ["!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "_"]
        private static let lowercase = (97...122).map { String(UnicodeScalar($0)!) }
        private static let letters = uppercase + lowercase
        private static let complete = digits + special + letters + space
        public static let characterSet = CharacterSet(charactersIn: complete.joined())
    }
}
