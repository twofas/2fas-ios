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

import UIKit

// swiftlint:disable all
final class ServiceDefinitionDatabaseGenerated {
    lazy var services: [ServiceDefinition] = {[            .init(
                serviceTypeID: UUID(uuidString: "0001F2BD-6892-4766-91CA-BC15F61062AA")!,
                name: "Hatch",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Hatch", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Hatch", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D7943718-D16E-4086-9A45-39F3EE555776")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "000DEE19-E7ED-4888-AC9E-A38C1CFFCAA6")!,
                name: "Etana Custody",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Etana Custody", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Etana Custody", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BF300482-59DA-4D69-8860-A7A72C48BC3C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "002FD04D-4046-4629-952B-EE92F17E2E09")!,
                name: "IONOS",
                issuer: ["IONOS"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A70BEA5A-EA3A-46C0-BAAF-E837A66AAC19")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "00576EC3-12AB-4A5D-A024-762C5C394D57")!,
                name: "IO Zoom",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "IO Zoom", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "IO Zoom", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B64D17AB-F1CA-4BA1-8E61-AF8133EE3F88")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0149357F-7F61-424C-ADF7-5DAFC8E077C4")!,
                name: "Airtable",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Airtable", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Airtable", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F100A5CA-C5E7-4336-9AF6-C9BE4CE44641")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0217BFA3-C811-41AB-82AF-E82E3519E7DA")!,
                name: "Nutmeg",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Nutmeg", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Nutmeg", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3FFF0081-BCF7-4E48-8D91-7F942713DC6D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "022B8E24-46BD-4236-B522-F48007A6F736")!,
                name: "ANY.RUN",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ANY.RUN", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ANY.RUN", matcher: .contains, ignoreCase: true),
.init(field: .issuer, text: "ANYRUN", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ANYRUN", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "15A6D950-7998-412D-B7DA-9EA09BEAE210")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "02C27503-888F-4A86-BD1C-FF1142822F7A")!,
                name: "OzBargain",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "OzBargain", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "OzBargain", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C2DB9410-6053-4D52-96F3-4ACD16B7CF6A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "02DFCFE3-B403-4130-A26B-3FC4C83FC4BA")!,
                name: "Airbrake",
                issuer: ["Airbrake"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "9F4E3AC3-C09F-4229-9F99-27B94E6E3372")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "032C2FD7-14AB-4D22-8B9F-F7B77BDF1146")!,
                name: "HappyFox",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "HappyFox", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "HappyFox", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5D91D726-72C8-425B-BBE7-41A1EB6C1346")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "032ECEA7-6FFD-4A28-BD8F-38D583C645CE")!,
                name: "Egnyte",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Egnyte", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Egnyte", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C62C308C-926E-4B54-BFCC-241C4F384758")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0336ADDA-650E-4082-A24B-4A2165C3A043")!,
                name: "USPTO",
                issuer: ["MyUSPTO"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "13838D86-6882-4851-81C1-272B128FEB5D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "033DF8C3-8160-4B6A-8CE0-C2BE0460797E")!,
                name: "X-Plane.org",
                issuer: ["X-Plane.Org Forum"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A2D05CD0-6C88-45EE-9997-B77ADB726BFA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "036733DC-870C-4A5E-B0DF-F4DDE5CC2A4A")!,
                name: "Trading 212",
                issuer: ["Trading 212"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "90AE4DBD-22CD-491D-9211-347DF50AABE2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "038191EA-9F3A-4B83-BC04-C2E55B9B08CA")!,
                name: "WEDOS",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "WEDOS", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "WEDOS", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8858B30F-9416-47B9-8EB1-AFEF063F3203")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0390AC2B-31BF-4179-AAF5-2E59C16F6DD8")!,
                name: "Toshl",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Toshl", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Toshl", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DBAE7C12-FE87-4979-838B-50E0C77D6E55")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "03BC1020-723F-445E-B9A8-530B8C37CC71")!,
                name: "Stackhero",
                issuer: ["Stackhero"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "236F8CE2-36D4-4C65-A7DB-645B2BE0261E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "03CE228C-BDE7-4AB6-BBE2-94B85EF4B3CD")!,
                name: "Outlook",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Outlook.com", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Outlook.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "775511EC-6424-401E-AF3D-5AF729E575A7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "03E91FC4-2C54-45ED-8756-290D9E4F8C2B")!,
                name: "Finnair",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Finnair", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Finnair", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A79B0811-48C9-4D26-817C-796A88FD9278")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "04246E03-1BF2-430B-9BEB-8820A57CAEAB")!,
                name: "Blacknight",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Blacknight", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Blacknight", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EEFC1A8D-1C82-44D3-89D4-5C114B40FA37")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "042B2E57-DC5E-41EE-BC5A-9482AF8A2C84")!,
                name: "Swyftx",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Swyftx", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Swyftx", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "064AEEC9-3B93-4491-AC6B-5BB621C0B668")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "043D0156-95AC-4D35-B9EA-7CA2CD8EA8AF")!,
                name: "Aternos",
                issuer: ["Aternos"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "F5B2DDE6-8F5D-4CA3-9B19-D10EF552D8B1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "044D1095-EDE6-4033-938C-4A409AB3A2C6")!,
                name: "Ring",
                issuer: ["Ring.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "97F2C094-5A55-4406-B06A-3229B0E08DB5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "04E370DD-B2D5-4998-8A21-02B65261355C")!,
                name: "Customer.io",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Customer.io", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Customer.io", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E76EDE36-B83C-4840-A822-6B1DE8058EBB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "04E4AC3D-E993-4D93-BFCA-BAA38A534698")!,
                name: "Barmenia",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Barmenia", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Barmenia", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E5D554BF-F48B-46D5-B108-FAB3CA86392C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "04E7F038-8903-484C-B4A6-2943E39B5625")!,
                name: "Black Desert",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Black Desert", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Black Desert", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3586A32D-147F-4221-9EEF-9D981485B118")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "05F01A81-966D-4B44-A264-1E8E76E58011")!,
                name: "ProBit",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ProBit", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ProBit", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7E33E824-FB2C-4A67-ACF6-A0F857915342")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0642640D-52F8-4D2A-BA7F-B2E98DCC4760")!,
                name: "Tibia",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Tibia", matcher: .equals, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "9A59764B-6E14-469C-AA17-D78652774DBE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "06458FC0-2115-4693-B92D-7E0456C115DF")!,
                name: "Plesk 360",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Plesk 360", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Plesk 360", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "62DD1965-0868-4B7B-9E36-FE7170643ED7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0658227C-EF86-4948-B737-EC1BFC11CBBB")!,
                name: "MailChimp",
                issuer: nil,
                tags: ["INTUIT"],
                matchingRules: [.init(field: .label, text: ".mailchimp.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "236DAD43-1697-46FC-AD86-761702F14307")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "06748548-0A16-4215-964A-20135E373CFA")!,
                name: "Cobalt",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Cobalt", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Cobalt", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "484CFFD9-3295-4BD5-A344-FEC8BE73D53A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0680591A-0464-44CC-8546-D61666088DBC")!,
                name: "Home Assistant",
                issuer: ["Home Assistant"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7DB360BB-425B-49C5-AA23-C0CDB2129A77")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0755B13F-D3D1-43B0-B6A8-4348519CBDC7")!,
                name: "AdGuard",
                issuer: ["AdGuard"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "FE37E55D-3A49-4B40-B974-76B89DD97D9A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0777BBC7-AC7F-4EF0-AB3A-A5A3D8D29168")!,
                name: "T-Mobile",
                issuer: ["T-Mobile ID"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "C73AFE02-0141-4165-8583-3BB5C0C5D039")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "07874658-2A42-4532-B98B-CF1A407B5834")!,
                name: "Guild Wars 2",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Guild Wars 2", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Guild Wars 2", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "330DC006-2763-4A76-8A0F-BA8CE55D6DD5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "07DF90D4-BBA5-4A31-B62D-08B04D631132")!,
                name: "Digitec",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Digitec", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Digitec", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "71B1D34A-1332-4786-8974-431EE10F06A6")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0828DA95-C0E5-4CBD-BB98-D4AF8E471E44")!,
                name: "LocalBitcoins",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "LocalBitcoins", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "LocalBitcoins", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "40DF2129-55B8-459C-9658-7B45B4C6EEA7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0847B922-D5EE-478D-8705-FC661DC2E83A")!,
                name: "Upwork",
                issuer: ["Upwork"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "890AD18D-FF18-4AAC-BEB4-9311D9941019")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "086A9365-1929-4938-B3FF-5641B81DEF32")!,
                name: "Nutstore",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Nutstore", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Nutstore", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D1DBBC95-4FC5-4B12-8462-7D3C99BA6EC1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "089BDE79-35B1-45DD-826D-660DB6AFDB24")!,
                name: "Whois",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Whois", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Whois", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F235E969-15E7-47AA-BB7F-8A60FDD5DA7D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0913D3CB-D3B3-4657-B948-3407855DA776")!,
                name: "DataRobot",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "DataRobot", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "DataRobot", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B3FF4913-A424-4F3B-9B19-8753D2DCF8C8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "092783FE-18E3-4CFA-900D-DE5C135CAFB1")!,
                name: "Dmarket",
                issuer: ["Dmarket"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5247C96D-2383-4016-AA5D-119B251F94C3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "096B26F8-E5C9-467B-ACA7-E2FDB63C7E36")!,
                name: "Jamf",
                issuer: ["Jamf+Now", "Jamf Now"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "AE357171-6E23-456C-950A-E792B0EA53B3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "09B903B7-E980-4099-955E-DCD421232870")!,
                name: "SatoshiTango",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SatoshiTango", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SatoshiTango", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FEFA43E1-CE67-49D3-9A20-8C88D5AC5FA5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "09EDFEC0-C3CC-4C8B-8135-AC5779708019")!,
                name: "GreenGeeks",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "GreenGeeks", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "GreenGeeks", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B5B9EDDC-6C44-44DB-901E-F2FD5483B7A2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0A48F587-2D81-494A-BCDB-A01569F81453")!,
                name: "SimpleLogin",
                issuer: ["SimpleLogin"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2ED9942B-DAEC-491A-871E-0C01E77E0722")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0A534123-CCF1-4948-B85E-414FC8883643")!,
                name: "Mailfence",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Mailfence", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Mailfence", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D0DBEBE6-C08A-4F80-A83C-4956883D204C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0A908E25-0591-4AB5-9999-FD4D2FF9DC89")!,
                name: "DMM",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "DMM", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "DMM", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7256C39B-2D44-46E2-8FE0-3DE4EDC17DCD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0ABBA2A9-B06F-4BEA-8767-74AA8F719147")!,
                name: "CoD Mobile",
                issuer: nil,
                tags: ["CALL OF DUTY", "CALL", "DUTY", "ACTIVISION", "MOBILE"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7FDA4F3A-B307-47A7-BEBE-373EB738785E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0AFC71A2-F1E0-4EA1-9E1C-05D5FFF2A66A")!,
                name: "Masaryk University",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Masaryk University", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Masaryk University", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "39EEBD39-2A8C-46FE-9E5A-1E2217888B0B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0C4E2E05-A8DD-405F-9FFF-FFBC2B052444")!,
                name: "Onehub",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Onehub", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Onehub", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "68D9C9C8-487E-4496-A40A-46412E6C4187")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0C7FFAF6-FA79-47B5-9FB1-1FC4D97541E4")!,
                name: "Cfx.re Community",
                issuer: ["Cfx.re Community"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "685D98ED-CA33-470C-82B8-6AE671C2EC15")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0C954246-0285-4E39-ACA4-E37BC4DF083A")!,
                name: "BookStack",
                issuer: ["BookStack"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E65EEE11-1129-447D-BFE5-C91512540EAF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0C9BC1B5-147A-41AF-A9AC-68687275A9D7")!,
                name: "Hypixel",
                issuer: ["Hypixel - Minecraft Server and Maps"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "942FDE6E-E260-4C0A-8C60-3EBAE7251352")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0D0049FB-3F6B-4F18-8D74-63DCAA928EB8")!,
                name: "McGill University",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "McGill University", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "McGill University", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "04DB2FC7-09C8-4B81-A4B5-703A3E0E348C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0D096E23-0594-47AF-ABAC-51AAAE14F19C")!,
                name: "QNAP",
                issuer: ["QNAP"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "1A68E6D4-0610-4763-A6A7-83F5FB66EB5E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0E0ACA8B-0901-4A9F-87AE-655407C6B719")!,
                name: "Scalefusion",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Scalefusion", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Scalefusion", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F627BD28-2647-449E-8C42-2EC569F4F3AA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0E479FCD-6A38-4431-9605-8A3D8B260E29")!,
                name: "HMRC",
                issuer: ["Government Gateway", "HMRC", "GovernmentGateway"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E176C886-93FE-44F9-B6D8-A22BD522A396")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0E6522DD-EB84-4B58-96D9-DE67618F8DD0")!,
                name: "Brigham Young University",
                issuer: nil,
                tags: ["BYU"],
                matchingRules: [.init(field: .issuer, text: "Brigham Young University", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Brigham Young University", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F4D27EE1-957F-4820-A58E-3B89DB515F01")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0E79BA5E-36A3-4847-96D5-E1DCFE879874")!,
                name: "FogBugz",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "FogBugz", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "FogBugz", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F57361FF-F86D-4314-90DD-73A77E975562")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0EAC11F5-2407-4642-89A0-6C734C164C83")!,
                name: "Teleport",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Teleport", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Teleport", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "77B0824C-E6A3-4EDC-96DD-80F4BEA412B4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0EAC9826-637B-4E1C-B73E-33B08CB4D8EE")!,
                name: "Nulab",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Nulab", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Nulab", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E16D1E0F-E22C-4896-98DC-82C0923A165B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0F41D2CD-C5AD-4503-B0AB-5644E5D570A4")!,
                name: "Paddle",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Paddle", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Paddle", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "492CFDB1-B046-49C4-B8C8-0232FD3F4675")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0F5D448C-117F-4D9C-988B-6A5913A6BF89")!,
                name: "ISL Online",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ISL Online", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ISL Online", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "36CA071A-0422-4157-9C08-78C4C0D86028")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0F79F016-6BEA-42A7-88D3-B7F44B14F02F")!,
                name: "Buddy",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Buddy", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Buddy", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E0224A23-CDD2-44BE-B691-290806B67926")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0F80C3FB-86D2-42CD-8C59-059A35B5083D")!,
                name: "SoFi",
                issuer: ["SoFi"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "DA353611-99CC-41A0-B01C-280843D9C9B8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0F92D0C5-2B96-4F8E-91EF-9A026E048B80")!,
                name: "TikTok",
                issuer: ["TikTok"],
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "TikTok", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C1478A28-C2A3-4993-BE6E-1F826BE2D5C9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "0FBF7A9F-F82A-447E-84E1-3D000164798D")!,
                name: "Postmarkapp",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Postmarkapp", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Postmarkapp", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "82C1B55F-28E0-4BC8-B225-4029C1A8EF1D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "103E3001-AECE-493D-9F90-9A5AB4520ADA")!,
                name: "Masterworks",
                issuer: ["Masterworks"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "687CB980-6C6F-4E16-94DF-6CA45CD71E33")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "104C80C0-5FF6-41D9-8C05-76C1860BD36B")!,
                name: "Bethesda",
                issuer: ["Bethesda.net"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7E238B3C-9833-4D0B-ACC2-36396ECCB0FE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "10CF2464-641C-4310-8D7E-4AB77E7D0228")!,
                name: "Haru",
                issuer: ["Haruinvest.com"],
                tags: ["INVEST"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3440CD67-8D23-4D35-BD85-6AB1E8A6F409")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "111B5DB0-2844-40A2-9A76-D65250AF89F4")!,
                name: "Practice Better",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Practice Better", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Practice Better", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4B0DC695-B65D-4BF0-8B59-A18FE69F5EBD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "112F7052-CDF0-4851-A562-C0754D001E80")!,
                name: "Dwolla",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Dwolla", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Dwolla", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "183C86E4-D062-4AFC-89E2-05ACAEF54CA6")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1141A948-D87C-43E3-8B21-CC95CA9703E5")!,
                name: "SmartSurvey",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SmartSurvey", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SmartSurvey", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "089D988F-65B4-4ACF-A3F7-FC044B7A4181")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "115AAA5C-3867-41B8-B668-B193F795D232")!,
                name: "Hiveon",
                issuer: ["HiveOS"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "1E5C1655-57E3-44F3-BCF6-EF46B3C699C7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1174FB7D-CB22-4855-B454-D1D25ACB3753")!,
                name: "Proton",
                issuer: ["ProtonMail", "Proton"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "114D2106-4E3D-4AE4-B559-DC598F2FDA3C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "11CDF742-25E2-4915-BD71-4F7C11272B27")!,
                name: "Short.io",
                issuer: ["Short.io"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "FC4833DD-7151-4AB4-A9CE-AA45DE5B710A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "121ACF58-0E10-4E0D-A967-2DAD5F8E5929")!,
                name: "UptimeRobot",
                issuer: ["UptimeRobot"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "CB646018-2B9C-471C-B033-CC932A767520")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "12AF652E-0C2F-48C8-8EBD-DD8B0FE60F83")!,
                name: "Phrase",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Phrase", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Phrase", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F9EF0672-FAEA-4223-A8CB-69B4718330D7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "131392A5-C598-4A0E-BB80-4A0B2A724AE7")!,
                name: "Rebrandly",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Rebrandly", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Rebrandly", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "26F2C4C6-39D2-4F8A-8D61-7F2E39424F4E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1338C029-1AA4-4A61-A1BE-57C1C393F898")!,
                name: "Contentful",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Contentful", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Contentful", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1EAAD0B3-4079-4157-B3BE-90124CC6FEAF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1356DB6E-A3F7-436A-8584-BE00A7D6FF43")!,
                name: "Brex",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Brex", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Brex", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "25855B19-BDA8-4875-B182-3960456F16A7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1366F931-A503-46CC-9E86-3C1B2528B548")!,
                name: "Firmex VDR",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Firmex VDR", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Firmex VDR", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "391201F1-7D01-4C5C-9523-2C8E54E4CEA2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "137459FD-0F05-489A-95AF-FD0245C3FA0E")!,
                name: "Bitpay",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "[bitpay]", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D85626DD-C037-44CF-B841-425AF012457C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "13CD6950-FEA9-478D-9204-6CE9883BBDD1")!,
                name: "NairaEx",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "NairaEx", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "NairaEx", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A575F293-030A-47E9-A813-EE011F85689E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "142F6389-D0DE-4BF6-BD90-B9171E66561D")!,
                name: "Verpex",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Verpex", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Verpex", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "185F645A-1743-4DC5-B2E5-BF5F5D114186")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "14426FF2-A34B-45C7-B849-4E89EF1EA285")!,
                name: "No Starch Press",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "No Starch Press", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "No Starch Press", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "131ACD15-D175-4C4F-A3CF-CECC9A3A7CF2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "145FCF19-0226-4CA1-8457-69D778A3808F")!,
                name: "Coinigy",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Coinigy", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Coinigy", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0059E395-F954-47A0-A8E4-4BC800A4A0F8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "148AEE0B-5B58-4A72-A9D2-E93184B6E398")!,
                name: "Karlsruher Institut für Technologie",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Karlsruher Institut für Technologie", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Karlsruher Institut für Technologie", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A038B1B2-FF3B-4DFA-9CA2-11FB7952A39D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "14B0712A-B660-4550-AC94-BC0EA75E3228")!,
                name: "Slack",
                issuer: ["Slack"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "DC0D1BF9-DC12-4936-8441-CD54F433BE09")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "14BF925D-A0E8-45D0-9EE2-BFF317C244E4")!,
                name: "Coinjar",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Coinjar", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Coinjar", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2752300D-8FDA-423A-A5A9-CDA0690DDFA1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "14C8DD5D-8982-409D-A2E2-DAB2983EB020")!,
                name: "Fauna",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Fauna", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Fauna", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "57883BD7-EC1C-458F-AEB8-5A8D52595B75")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "14DDDA49-0A2D-46CF-B46E-BF236A355EE1")!,
                name: "Favro",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Favro", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Favro", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A8D8D8B5-AB15-4531-BB19-9D5EA7100CB9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "14E45151-0724-48C1-8D71-F262202307C7")!,
                name: "ISC2",
                issuer: nil,
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E80AF02C-1616-42F1-AC93-89D8AAEC29C8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "15733414-0160-4DD9-9FC1-187369CBB288")!,
                name: "Above.com",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Above", matcher: .startsWith, ignoreCase: true),
.init(field: .label, text: "Above", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6D0C4064-6096-46BB-92FD-584ECB64733C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "15ABC44C-E519-488B-98F2-3A75AAF270AF")!,
                name: "Reddit",
                issuer: ["Reddit"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "F0FBC3B5-3725-494F-8EBC-4F3D80B2FCFE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "15AECBE2-7315-4FC1-AB7C-14C49B45DAC0")!,
                name: "Tori",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Tori", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Tori", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "70C730A8-79C7-41A3-8444-AD2EB1B9192C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "15B2D968-B472-483D-93E4-35891557E215")!,
                name: "Scryfall",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Scryfall", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Scryfall", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4D101F07-8841-4DB1-9EF3-43B705B2EAB0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "15E30EFE-AEB1-441A-916C-AE4EB1787F27")!,
                name: "Cryptology",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "cryptology.com", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1FF6314F-90CB-40D6-BA16-B0AB8746BF5A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "15FC4637-25C0-416E-9FCC-AFE99DAB8ABE")!,
                name: "Drupal",
                issuer: ["drupal"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "07F84AB8-8A93-4F0B-BC3B-00C20A3DFEC9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "16006518-3005-4F92-8232-D5B69A777A8F")!,
                name: "Web Hosting Canada",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Web Hosting Canada", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Web Hosting Canada", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "30DF36AA-2DE4-45F8-9B6A-A83EFA91838C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "165C70A7-D28C-4B7F-A92D-EAB8E66DFCB5")!,
                name: "SouthXchange",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SouthXchange", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SouthXchange", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5226962C-4F84-469D-9D64-1A0A466C3C5E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "16B5168C-D5BF-468A-B795-3A1B87570445")!,
                name: "Monday.com",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Monday.com", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Monday.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B02D2F47-CFD4-40B8-AF98-0B9838FF46A5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "16E92D20-B1B4-4E23-BA0A-224D79B0A02A")!,
                name: "CurseForge",
                issuer: ["CurseForge"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "4F9313C6-FAB1-48EF-A642-4FB13007C82C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "170388D7-479C-40D6-B624-B72D22ECF552")!,
                name: "Kayako",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "kayako.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F0359E70-4297-4693-AA8D-BA5FCA0668E8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "17D05262-546D-407B-A481-C130535B3A73")!,
                name: "myPay",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "myPay", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "51CDDF69-C85C-4A24-9790-209680D296E3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "180C5928-9206-4984-92CC-72B136601B7D")!,
                name: "Mercado Bitcoin",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Mercado Bitcoin", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Mercado Bitcoin", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0B187FE8-13A2-4CEC-A254-C2A807DD40B4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1818B58D-1A0E-48BC-B122-33CB8F48F248")!,
                name: "Packagist.com",
                issuer: ["Private Packagist"],
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Packagist", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Packagist", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "53CBAF51-A4B3-45F9-832E-31EC7E38EE91")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "181AD340-0B3E-4F27-A472-D9AD3FE0F10F")!,
                name: "RestoreCord",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "RestoreCord", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "RestoreCord", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2C349A9C-AEB3-4AD4-94E2-682C3CFBD7D8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "18242DD5-AD83-4840-B7D3-2AA84B988E94")!,
                name: "Sketch",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Sketch", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Sketch", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "CE8F1736-65A6-42E1-A4D5-48A90CBFA032")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "18393734-A876-41C2-8CAE-D4B86B955587")!,
                name: "Rackspace",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Rackspace", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Rackspace", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "CC566EF8-F92B-47D7-99A9-A280ECD3CFA0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "184D3779-9204-4C22-BD8C-B1F681350D1E")!,
                name: "Launchpad",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Launchpad", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Launchpad", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1DF3A7FA-AC7D-42BA-94F7-118A01E40D26")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1889446C-21AE-40EA-A6C2-639368BE9732")!,
                name: "Imperva",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Imperva", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Imperva", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EEEC2C17-C57D-4B6D-9D71-E8790B04BB2E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "19A5F44C-BC4A-4F80-9903-2C61668C5A0A")!,
                name: "ONET Konto",
                issuer: ["OKONTO"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2A35DFE5-89B6-4607-AC2E-2583DDCD7978")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "19CAC7CF-5548-4869-A33F-6A13A4AE5E6F")!,
                name: "NiceHash Login",
                issuer: ["NiceHash - login"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "C8019718-56B2-406F-BF21-2ADDDA6B21FD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "19D66171-A705-419B-BFAE-68FA91483130")!,
                name: "Call of Duty Mobile",
                issuer: nil,
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3FB39B5B-027D-45EC-AC61-A59841CC8282")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1A113323-CC17-4184-8816-B687EA65B0B7")!,
                name: "CoinPayU",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CoinPayU", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CoinPayU", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DB199EBC-BAC9-4A00-BFAD-5C4A017C853B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1A2BD621-38FE-4143-94B7-516A4BCECA9C")!,
                name: "FAX.PLUS",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "FAX.PLUS", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "FAX.PLUS", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6DA226A8-F1A7-47F3-93A9-89F1689C2533")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1A433D91-F6CC-4347-B4EB-29E98BD193BA")!,
                name: "Campaign Monitor",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Campaign Monitor", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Campaign Monitor", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "682AEA05-0544-473D-A5C2-9B4764348C2D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1A8546AD-903D-4F3D-9589-F7282D426007")!,
                name: "ID.me",
                issuer: ["ID.me"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "EDB6040C-FFBE-441F-80C1-95FC09601B4A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1AEDAFD0-B21E-4220-A276-D3001BFA9702")!,
                name: "Humble Bundle",
                issuer: ["HumbleBundle"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "4112E85E-09CB-4E9F-960B-2E2C00B8929E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1B19BE9E-FEC0-4C64-929B-01FCC0172B74")!,
                name: "MxToolbox",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "MxToolbox", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "MxToolbox", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4BEBE475-8430-476B-920F-3FD94F859382")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1B35B8EE-DE08-4623-8BE9-9A52D3606A08")!,
                name: "Activision",
                issuer: ["Activision"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D4FEF7D5-65CF-4156-BC04-98F9767B78BF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1B404CBA-9661-42E6-BAE4-1420C4FFE855")!,
                name: "Domeneshop",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Domeneshop", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Domeneshop", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "46A1D96B-AC97-4FA8-926C-5B2641E06B5E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1B4C2400-7366-4B33-9419-440E188A6748")!,
                name: "Private Internet Access",
                issuer: ["Private Internet Access"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D3262B45-4011-46CE-9A3D-FCE9FCCF3D79")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1B58F132-4F96-4E3D-80C7-B087F367CEA1")!,
                name: "Files.com",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Files.com", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Files.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "517D055E-D2EB-40DC-BE4B-5777E0E08F55")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1BAA0FAB-1A1A-495B-82EC-A2AAE7DE4C04")!,
                name: "cyon",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "cyon", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "cyon", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A54D0235-47BD-4BF5-B295-9CD86DD7FB4A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1BC36494-7DFF-4EFC-9B76-F6006DBBAFFE")!,
                name: "KnownHost",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "KnownHost", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "KnownHost", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "150FCAE8-49EF-4595-A855-BBD6B2C1DB91")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1BC47966-4272-4EF2-BFD2-4F619070343F")!,
                name: "Northwestern Mutual",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Northwestern Mutual", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Northwestern Mutual", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D1BAD917-1FC3-4C34-8CF7-8089143D8DC4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1C4C489E-E743-4E71-A956-B353A70A8245")!,
                name: "Prusa",
                issuer: ["Prusa"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "C595ED6B-E331-4139-9183-49D1353635A4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1C6EF27D-7D4B-4827-9D8F-8AECCE460008")!,
                name: "Docker",
                issuer: ["hub.docker.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "8D3B0A32-4A3E-445C-B1C3-0529BDE24AA5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1CB281F3-095E-419D-A4C9-A48923D05E72")!,
                name: "my529",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "my529.org", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A3DB825D-B56E-42DA-82B4-33D75214C472")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1CB370B8-3681-4D7A-B43B-0B3A3D2CB132")!,
                name: "Independer",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Independer", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Independer", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B7852AC0-B4ED-4873-B1E0-5595092A2D9C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1CFBA37C-40BC-4ADF-A38A-7EB89848A1F0")!,
                name: "Faceit",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Faceit", matcher: .equals, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "418660A6-21DA-4D5A-8D25-AC5F98938236")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1D1285F4-EA50-46AB-A490-33BB9380E752")!,
                name: "SelfWealth",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SelfWealth", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SelfWealth", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "64DBA057-D740-49B1-9688-5BE5AAC2F720")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1D3774AA-BD1A-4D57-B453-5EF78943233B")!,
                name: "Arbeitsagentur",
                issuer: ["arbeitsagentur.de"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "323F26E2-52A2-438D-89C7-8318133499BB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1D62DDA1-9EA0-4B58-B99D-E626340F02F6")!,
                name: "Posteo",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Posteo", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Posteo", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2921F379-9B35-492D-8ED3-FDFEB2CA75BF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1D6A7518-AF3A-4436-82C8-095FF9B1BE13")!,
                name: "Esri",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Esri", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Esri", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "41198B5F-6773-4A9F-88E1-98F254158792")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1D8FF8E6-0148-49B0-B0F7-20669B813C13")!,
                name: "Earth Class Mail",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Earth Class Mail", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Earth Class Mail", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F46F357A-272F-4467-8C2B-A49F99CE22DC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1DD3612B-BA8D-43D9-987E-461F1F3F6D51")!,
                name: "iLovePDF",
                issuer: ["iLovePDF"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "0E2C86E0-1815-4C89-9DF6-C145364127DE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1E62A22D-11E6-4EBA-BE19-B5C43637FF0D")!,
                name: "Weclapp",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Weclapp", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Weclapp", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "245252F6-77B2-46F6-A4AB-74298597F300")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1EA76FE3-1BCA-46DA-B08E-DBBB8FC78CEF")!,
                name: "WeTransfer",
                issuer: ["wetransfer-prod"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "87364362-31CA-4E7D-B04C-0B7EB4D8CF3B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1EAC7D7D-C6CD-46F4-8D47-BB6E70163BBC")!,
                name: "Guilded",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Guilded", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Guilded", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0D3BC1CC-73C7-4A58-A0FD-3B6293E0EEF6")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1EAFB2B3-17D9-417F-8D1D-AFB6D9ACA878")!,
                name: "Pulseway",
                issuer: ["Pulseway"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "12A96D37-ECC7-4DCE-B36E-9249A89D343C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1EFC3706-B0DF-43AA-B5D5-2ECFDA6901E0")!,
                name: "ThriveCart",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ThriveCart", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ThriveCart", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "17368174-958D-4087-AFAF-9F6925C52D8D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1F1A8F7B-4B21-4E9D-ABB6-31BA668B51AB")!,
                name: "Rev",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Rev", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Rev", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "AAD50BEE-DFF6-4E2E-9D39-0814615CB406")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1F732634-E6CC-4219-83D4-9E78D41372F8")!,
                name: "Hootsuite",
                issuer: ["Hootsuite"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "74F2A271-9922-4483-94D1-95E117C17D8A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1FA205A8-DC73-450F-A488-311EAA5825B6")!,
                name: "Nexcess",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Nexcess", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Nexcess", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3C6147C2-3FC5-4603-8871-9DBC130E821F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1FB22909-B458-4CAF-B104-22403B6560B2")!,
                name: "Fastly",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Fastly", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Fastly", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A7962D66-ED64-45EC-A940-EB1734F61DC2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1FBB656A-53A2-4FA1-AA1C-3D04E8A7A122")!,
                name: "Hostinger",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Hostinger", matcher: .contains, ignoreCase: true),
.init(field: .issuer, text: "Hostinger", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6BC04722-2A84-4320-BB7A-B2FEE8C8368E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1FC76F0A-2D9B-4628-8174-F81113E74375")!,
                name: "Twilio",
                issuer: ["Twilio"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "F7F34153-2231-4494-80A6-2817BE0BEAE9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "1FF74E4D-CA1D-4128-A20B-6C9FACF952A4")!,
                name: "Webroot",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Webroot", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Webroot", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "94936FD1-025C-4288-A083-BA2603AD335C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "207FB994-0828-4C1A-855E-41C4D52CFA70")!,
                name: "Hexonet",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Hexonet", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Hexonet", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "326DDCBA-9CB9-4483-AA63-D1E65D280DB5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "20A519D7-AAA2-4F6D-A013-703BC6895B3E")!,
                name: "FragDenStaat",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "FragDenStaat", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "FragDenStaat", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "009DCB53-A8A5-421F-8621-75D32E9E72F2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "215ACEE1-36B6-4597-BFFC-8CD403EC2614")!,
                name: "Netim",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Netim", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Netim", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "44126549-B0B5-4211-8F1B-4CB988148AE7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "21701630-A5D2-457C-A983-BFBF4EFA801C")!,
                name: "Epic Games",
                issuer: ["Epic Games"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2006F387-1BC7-4E9B-8EA7-0A8C3A9924F8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "21B12EDA-626E-4173-B12A-66EE9B5A73FE")!,
                name: "Semaphore",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Semaphore", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Semaphore", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BDFA4333-CCA6-40AE-B173-92E0079B66C9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "21D066CF-C0D6-4DD0-8D00-3DD627548550")!,
                name: "OneSignal",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "OneSignal", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "OneSignal", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7EC2CEC8-107B-4A84-91D1-9E3D601F52CF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "21D5DCC4-4C1B-4D90-99D0-5CD35C815526")!,
                name: "Zoho",
                issuer: ["Zoho"],
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Zoho", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DF531F5B-5488-4AA9-87F6-D950B3CA04EB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "21D63430-4977-43D5-A1E4-00CD3C390165")!,
                name: "Advcash",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Advcash", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "03641FA7-F680-4F99-AC15-4954061E237C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "21EF7A69-F366-4DFD-ADA6-663BC67D2E8C")!,
                name: "Fastmail",
                issuer: ["Fastmail"],
                tags: ["MAIL", "EMAIL", "E-MAIL"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "4D15F4F2-0C7E-41B1-A9AF-BE07644246C1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "232AF909-986F-4BA7-BCFA-8C8FE05C1A14")!,
                name: "AppFolio",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "AppFolio", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "AppFolio", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6A5E50E5-EE56-4202-B25B-817591F7CC0A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "234BE581-45E1-41D5-98FB-D8EC4201B33E")!,
                name: "WIX",
                issuer: ["WIX"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "386356BA-0FEB-4ACA-8074-DD9B38E0E664")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "235A2434-4157-4A43-B5A4-EC75190F2891")!,
                name: "mail.de",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "mail.de", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "mail.de", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3A48FD2B-0EC9-4A9A-AD63-643A389B4AFA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "23842093-C49F-4DB6-A353-D561534E0F10")!,
                name: "Awin",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Awin", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Awin", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "9DECECD7-D941-4EAA-8B9E-DE7A4C46993C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "23D4F93D-C982-49E6-9E31-AA5EDA593931")!,
                name: "WhaleFin",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "WhaleFin", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "WhaleFin", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "47F571F7-D7C1-4F10-9ECA-7434A4F8A5AF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "23DA4E5E-905A-42BF-9F57-421CA0028CCF")!,
                name: "Spreedly",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Spreedly", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Spreedly", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "95DD928B-9CCB-4E5C-B661-3FF2686A7BBE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "23EEA0CA-0AC4-459E-8782-F2A8DFA632DE")!,
                name: "CoinDCX",
                issuer: ["CoinDCX"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "8BC3DE93-53C3-42BF-8791-6249A7F8A718")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "249073BD-77DE-455B-9158-5126DC689E35")!,
                name: "Xink",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Xink", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Xink", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "08EFBF4C-FC53-47E1-B222-73CC56B700D3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "24C038C9-41B6-46B2-BAFD-046FC074EF54")!,
                name: "Karatbit",
                issuer: ["Karatbit"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "B887CA8F-06DC-4D85-9990-03C1DEA2060F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2523A652-BBDB-4D9F-81C0-11D48AC4C227")!,
                name: "Getscreen.me",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Getscreen.me", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Getscreen.me", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "970A7AF5-A2E0-4420-80B4-43A13913D373")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "25F3C15E-335A-44A3-973E-B468581DB19E")!,
                name: "Newegg",
                issuer: ["Newegg"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "F68A6DD7-04AF-4BB4-861E-BFECC996FA0F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "261606E8-1535-454D-B762-DBE5F20F3A17")!,
                name: "Braintree",
                issuer: ["Braintree Production"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "CC6D4C9D-7AB8-4CDA-BA17-7289D6A1261B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "26455F8E-9672-438E-814C-47B4A438115F")!,
                name: "University of Oxford",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "University of Oxford", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "University of Oxford", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F4263E6C-9DA8-4595-A766-4A1E27708201")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "26482EB4-EFC5-4EFD-9EC7-D133634E64D0")!,
                name: "SSLTrust",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SSLTrust", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SSLTrust", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "47B4796A-B294-4F8B-95E4-D01DA8820523")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2671591E-DDFB-4077-BF6F-5422B902E8E5")!,
                name: "Cloud 66",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Cloud 66", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Cloud 66", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0CBC497A-1247-48BA-BB12-EC187E98B27F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "26AC0A8E-28AB-43E0-B93A-C728DF165800")!,
                name: "Telderi",
                issuer: ["Telderi"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "C5981A81-FF16-4D3F-ABB2-E297140DB537")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "27232A1D-BE11-4189-B56B-78826C35B981")!,
                name: "Digital Surge",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Digital Surge", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Digital Surge", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "CDB8A648-F731-487F-88FA-FD3CEDD58D77")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2726439F-7B21-45F0-805E-D8ACFA1EB84C")!,
                name: "AVG",
                issuer: ["AVG"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "4FCD28CA-176D-441A-BD66-E10D5F9E40A1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2759ACA5-50DE-47BF-8BAA-776A4F781347")!,
                name: "Everlaw",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Everlaw", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Everlaw", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "08FFDA58-BCAB-4B42-A8AA-8F2E1FDC13E5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "27A1FA34-4649-4FDA-844F-DBF23D43EED8")!,
                name: "Rippling",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Rippling", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Rippling", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DDBD79E3-8288-40EB-BD2B-3AFEDBA111C9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "27A6E1B8-42FC-4AE9-B277-542B45E3862F")!,
                name: "Coda",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Coda", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Coda", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A7D645E3-28BB-4E7B-8283-EC5E8B899423")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "280053BA-084F-4F1F-A672-524DC7BA09D9")!,
                name: "TrueNAS Core",
                issuer: ["iXsystems"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3D17C742-2A60-44FC-931A-60537102D17C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2820A93A-F4D4-484A-ADAA-F46B186709C4")!,
                name: "Yahoo",
                issuer: ["Yahoo"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "888F5964-F793-43FC-A635-3CDCA36BA68E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "28990AB3-2A7D-47BE-83DA-6A3D3FAAF822")!,
                name: "CharlieHR",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CharlieHR", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CharlieHR", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E63A3CF7-E7E6-48DC-B230-1DA4C28E04C1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "29266734-6296-49CE-BF2E-B346762B5B42")!,
                name: "Mercado Livre",
                issuer: ["Mercado Livre"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5CB7030D-45E2-45A4-B8C6-2B5D61A3783E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2954285F-BB31-4666-89AA-0192F8633D8F")!,
                name: "Pobox",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Pobox", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Pobox", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8FAADA07-7203-4745-A0A0-3E0C8AB2A761")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "29661992-71DD-42BA-9D45-2AF7BDBA4276")!,
                name: "SalesForce",
                issuer: nil,
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "8573CA05-5712-4043-B243-0D01E40C7B42")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "296ED6D3-2A00-4188-A6FB-65A7FA61FFB3")!,
                name: "BtcTurk",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BtcTurk", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BtcTurk", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4613A6C0-9326-46AD-BC7F-76567CD98116")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "29A9BB30-C40F-4B43-8877-2460915178C5")!,
                name: "1Password",
                issuer: ["1Password"],
                tags: ["ONE", "PASSWORD"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E8C7B9FD-94BE-4015-A6BE-FFBD626AAA8B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "29C7ACDB-AB9F-4775-B09A-CEFA18A95C12")!,
                name: "ACTIVE 24",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "active 24", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "active 24", matcher: .contains, ignoreCase: true),
.init(field: .issuer, text: "active24", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "active24", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7ECEAB5B-04FC-4231-A766-70DDEF0EB4FE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "29D3AA37-993E-4ED1-84B1-534A6A64E4F0")!,
                name: "LCN.com",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "LCN.com", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "LCN.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B128FE49-EE56-43B3-BF6C-C8F4FABFB247")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2A92A644-DECD-4275-AE71-927E988D905C")!,
                name: "Openprovider",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Openprovider", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Openprovider", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FCF0A204-9A58-4383-848B-FC1E677E0E4C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2AA05DE2-85D1-4895-B404-4A472827A777")!,
                name: "bunny.net",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "bunny.net", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "bunny.net", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3F20AB01-3DB6-436A-9F43-219EFD1EDF6B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2AD8DCB5-8EAC-43C8-A440-324CA8472F9F")!,
                name: "TruckersMP",
                issuer: ["TruckersMP.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "EDDDABB5-5986-4BD2-B7A7-DEC4AD3CF0EF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2AEF430D-017C-4ACF-88DF-E1526E7AE4D3")!,
                name: "Registro.br",
                issuer: ["Registro.br"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7797B564-FED5-418E-B9A3-705C953C16E2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2B17D1BD-04EA-4E46-81DA-3D553735984C")!,
                name: "intigriti",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "intigriti", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "intigriti", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "78605A70-0AF7-475F-89CE-A8208B7299E9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2B226D30-BD12-4663-A80B-95EAB7A5CA6A")!,
                name: "Formspree",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Formspree", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Formspree", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0D10E7F6-6A46-4AD2-95B0-555433510DB6")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2B825A32-934A-4282-B1EC-586CAE44C590")!,
                name: "InVision",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "InVision", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "InVision", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E3FAA1C3-D5BE-4C8A-9413-54690BE1EA53")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2BBA5977-2AD5-4F10-A576-9B536FFDB99B")!,
                name: "ARIN",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "arin", matcher: .startsWith, ignoreCase: true),
.init(field: .label, text: "arin", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BB32B5EA-54FB-4D7F-AE6A-85FC5D319EB9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2BEFB349-E59F-4898-A6C3-18021B29BAD5")!,
                name: "PC Case Gear",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "PC Case Gear", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "PC Case Gear", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "654C43E2-5C18-481F-8728-03EF64A471E4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2C03108B-354F-4FEA-A348-22106B09892D")!,
                name: "Bitflyer",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "BitFlyer", matcher: .contains, ignoreCase: true),
.init(field: .issuer, text: "BitFlyer", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5C66B6D2-748A-49D3-89AE-A350F0AD6199")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2C406558-A7FB-4C0A-BFE1-9287CFD6EEE4")!,
                name: "Wargaming",
                issuer: ["wargaming.net"],
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "wargaming.net", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6A6F2199-7CEF-41EA-9294-EC735000F369")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2C41B3D7-8911-4FE5-A4AD-269C584AF59E")!,
                name: "Nitrado",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Nitrado", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Nitrado", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F428CD5B-6CB5-46D0-B01A-27730F941DCC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2D27E715-0B4F-4F98-9A1B-CAB5FEB56061")!,
                name: "Looker",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Looker", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Looker", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EB8DB1AE-0516-40CB-AE5A-7196303E5AF5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2DBA5C39-8C5A-4DD1-9080-1615D2AB9930")!,
                name: "GREE",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "GREE", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "GREE", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "769E6C9B-B138-42E7-975F-4059A26467D6")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2DC6E938-D911-4BED-AB56-725CFCB64DB7")!,
                name: "Sumo Logic",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Sumo Logic", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Sumo Logic", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0DD4FF02-9548-4DE3-A208-0E36E4623E6C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2DDBB46E-64B8-42EC-9E69-18FD494CB67C")!,
                name: "Wellfound",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Wellfound", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Wellfound", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "AC84478A-8890-4E8A-AB7D-667A5F9D95AC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2E6C3119-1640-4107-BFA9-8FA653526712")!,
                name: "Addiko Bank",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Addiko", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Addiko", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4C0DC113-103F-44BC-BC2A-68CC75B8D77E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2EB3A952-7E2D-4088-88F0-0B0C2BDDE135")!,
                name: "phpMyAdmin",
                issuer: ["phpMyAdmin"],
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "phpMyAdmin", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3A742037-5520-4679-AD2F-E74F8CAB7E25")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2ED97493-8E5A-4B96-8E85-36D67C92C40A")!,
                name: "Sophos SFOS",
                issuer: ["Sophos SFOS"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "50AA288D-7F37-4A68-A110-EF9F460C972B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2EE903FF-A9FD-44CE-970E-47FEA122A860")!,
                name: "Nord Account",
                issuer: ["Nord+Account", "Nord Account"],
                tags: ["VPN"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "F7A9CBE9-7A5D-42BC-9B2F-93A8254A2660")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2F17C720-647E-48AC-A306-B680954F545C")!,
                name: "Nuclino",
                issuer: ["Nuclino"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "65608700-0814-41EA-BCC7-7BA73E00DCE8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "2F866D69-C41D-4916-9EAA-ED81C7E913F5")!,
                name: "Epik",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Epik", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Epik", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B7E54BBB-A382-4E91-84A3-BEB58369D64E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3044F4AD-0FDF-4371-A6A3-57917794BA0B")!,
                name: "CoinTiger",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CoinTiger", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CoinTiger", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0E0072BB-EA10-461D-8474-44682A7BCEFC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3065177B-4D4C-4D13-AAA6-C2F2CB5EDABD")!,
                name: "University of Pennsylvania",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "University of Pennsylvania", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "University of Pennsylvania", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "ADBDAF63-9247-4218-BC2B-B0F27A863454")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3080917E-B830-4692-8043-27B75B765E35")!,
                name: "Onet",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Onet", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Onet", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8FEF4E7F-3D12-4EDE-ABEB-D2BDBF6B3D14")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "31282F76-FABC-4CF0-9BB3-7F0FF4A31B81")!,
                name: "Directnic",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Directnic", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Directnic", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F8158AC8-D2EE-48A3-BA12-F0F9F7530A48")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3146EBFD-4D2F-4DCA-83AA-699D01D2EC9A")!,
                name: "SparkPost",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SparkPost", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SparkPost", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3C0870F3-16BF-4651-A21D-9DC781A234FB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "314CA83B-73ED-432B-B6AB-EE00FAE0A44D")!,
                name: "StartMail",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "StartMail", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "StartMail", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "9123BAD4-5110-4D36-BEBA-B4B661EF1ED7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "316212F6-5086-4BB2-8CA1-FDD411280A23")!,
                name: "Intuit",
                issuer: ["Intuit"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A9DAC0DA-53EF-4C0D-B4D0-B7A23666BE93")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "31AA8C45-8C81-4039-A617-22FAD52486AF")!,
                name: "Jottacloud",
                issuer: ["Jottacloud"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5847170F-EF51-49EF-A349-72874DC4AFE7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "31E746DA-D4D7-400B-AC87-006CF7F77E39")!,
                name: "Rec Room",
                issuer: ["RecRoom"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "C924F5D5-DC50-4121-B96F-B61DC8364EA6")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "31EA7562-18B7-410F-8023-657CBD65B077")!,
                name: "RubyGems.org",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "RubyGems.org", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "RubyGems.org", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A0D0C753-2B51-48BF-946C-E7FE3FC08DBF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "320FF1B5-1956-49D7-B842-42E996FB5F31")!,
                name: "Equinix Metal",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Equinix Metal", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Equinix Metal", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "95753570-0885-46B9-AC29-D653476C97C5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "321C0893-AAA0-487F-8C0A-5099543378D2")!,
                name: "BitSight",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BitSight", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BitSight", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A00A4A57-FE95-4BC1-BD9D-1E20319E0525")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "323A5859-1DA6-4FA8-8EC9-E90E44575F6D")!,
                name: "USCIS",
                issuer: ["USCIS+myAccount", "USCIS myAccount"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "55A7126C-C74B-4030-BE46-33BAF1D41794")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3299E7F3-8231-45E4-8837-3277574F2368")!,
                name: "Glassdoor",
                issuer: ["mfa.glassdoor.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E2383048-3CED-4F07-B637-22AC5781ED75")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "33234BA7-E70E-434F-8FC0-79E64C9A9C5B")!,
                name: "DATEV",
                issuer: ["Datev"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "4BBF45EA-7EB1-4AB8-A2C8-CD130C5F922E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "33368632-D426-425B-9C0E-FF8CABAA0C07")!,
                name: "Fritzbox",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "fritz", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "fritz", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "780EE78B-A61B-46F3-9FAA-0B6CF3F7479D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "33B29957-E237-4EEB-B89E-069EBC6D3201")!,
                name: "ConnectWise",
                issuer: nil,
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5FABB7C6-F73C-45E1-8CD2-AEA9A3923719")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "34044CAC-65FC-42A5-9705-3A098F9A7822")!,
                name: "Buildium",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Buildium", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Buildium", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "034A9D9C-E124-4FE3-AB27-14A8EC6151FD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "348A8FEF-66EB-43E5-BA64-FCD02CA2BA58")!,
                name: "BitForex",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BitForex", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BitForex", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DD8AA2C7-7155-4AE4-8568-8165DBE948B3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "34DAB018-33D1-4677-B728-25AA9357FF29")!,
                name: "Samsung Account",
                issuer: ["Samsung Account"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "F01F2F69-0B38-45BF-92B8-3594D61280EF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "35403E84-DEC1-49A1-8633-5DA2C9E9E5C0")!,
                name: "RedShelf",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "RedShelf", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "RedShelf", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1E96A88A-6ADD-45CF-91C3-D8830488D652")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "35498C4E-19AE-4E2B-92DE-B110BAACE547")!,
                name: "WhiteBIT",
                issuer: ["WhiteBIT"],
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "WhiteBIT", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DF2FF12E-CE9B-4F16-842E-7D1C33960E89")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "35646E51-C710-4F22-846E-AA87EE5E4B9E")!,
                name: "Txbit",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Txbit", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Txbit", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A114F79D-8E7E-4BF3-B3FF-B777151AA322")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "35EA48B5-450C-42F5-BF05-68C3998A7169")!,
                name: "Fathom Analytics",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Fathom Analytics", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Fathom Analytics", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C78530D9-9EA5-4861-BABC-F6186512A1D5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "362FA93B-4DC3-43C8-A666-BDE335BA5EDD")!,
                name: "HP",
                issuer: ["HP"],
                tags: ["HEWLETT", "PACKARD", "HEWLETT-PACKARD"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "B4D61A75-27F5-4B12-9C3D-04D3E1C28729")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "364A192F-39EF-4F2F-A419-D35F5CCCB3CD")!,
                name: "manitu",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "mein.manitu.de", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "AF6E7769-CEF5-481C-878D-45E188B840EC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3680799B-8F4A-4711-8159-D8537F49DB77")!,
                name: "ProfitWell",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ProfitWell", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ProfitWell", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DA090FE5-454B-4A44-8900-A78780133578")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "368C435D-445C-427C-B39C-8BAC7179E105")!,
                name: "VoIP.ms",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "VoIP.ms", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "VoIP.ms", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8C88ABE6-224E-4AB4-B560-AE79E1D00993")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "376E354B-4DAA-4D4E-A285-0D6BD3372AB0")!,
                name: "XING",
                issuer: ["XING"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "335C07EE-CC81-4C4D-9583-FBE4CE962901")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "37C35AA1-970C-4271-A4E1-5A0C49B66708")!,
                name: "Porkbun",
                issuer: ["Porkbun"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "1A9ACD1F-6265-4ED9-8DE6-BFCC356617B5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "380C5643-1F0A-43A0-AFD9-D764A67829BB")!,
                name: "pair Domains",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "pair Domains", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "pair Domains", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "AC419C2B-78D2-4910-8E21-FBE8B8D5C187")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3842FBA8-47C3-45BB-9700-932E86721063")!,
                name: "Norton",
                issuer: ["NortonLifeLock"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A659E300-C8B3-4DB3-8D11-2DDB1C46CEB8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "386AA376-6657-47B9-A81F-65E33C2CC266")!,
                name: "ClearScore",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ClearScore", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ClearScore", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2AE40C6D-F9D0-40C3-9B74-9F7897FF5349")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "38C1B9BC-9040-49AE-8551-0B0166B75708")!,
                name: "Ko-fi",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Ko-fi", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Ko-fi", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "039D5DE3-40FA-44DB-8751-D18EA4647055")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3974A4FD-722F-4512-A636-310FDB59719A")!,
                name: "Actionstep",
                issuer: ["Actionstep+MFA", "Actionstep MFA"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "B69ADDB0-C23F-4BEE-A210-FDB1DFDABA1E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "39AB5009-A9F4-44E2-90E8-BECFBECFDBBA")!,
                name: "Atera",
                issuer: ["Atera"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "CE141608-0221-422F-8A07-33D6BCA77F1F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "39D9501E-B910-4911-996F-A05972767CE9")!,
                name: "Unraid",
                issuer: ["Unraid"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "F391FCEB-2FF9-4F12-984D-EE59E91E157C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "39FBE7D1-12AB-40CE-9994-5C351EA21420")!,
                name: "Voyager",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Voyager", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Voyager", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2C1FF9A8-BB21-4E12-AC45-CDE148D7847F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3A1B611C-599A-4664-960D-E60A941C1971")!,
                name: "PolySwarm",
                issuer: ["PolySwarm"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "9EC3A35F-B09D-42FD-A1DF-354ACCF630AC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3A26C02C-1C6E-49BA-B282-C640F6C05804")!,
                name: "WEB.DE",
                issuer: ["WEB.DE"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3AF6D11F-D879-4649-B183-20C5742F20DD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3A299053-0618-4490-B4E4-CFBF1F77AE2F")!,
                name: "netcup",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "netcup", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "netcup", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5636B7B1-26B8-441D-877C-97AA0B1B2B34")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3A38D56B-A576-4EB9-84C9-2652087547DF")!,
                name: "Philips Hue",
                issuer: ["Philips Hue"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "1F762812-C7BC-4425-AAFA-DA4482812F1D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3A535461-59AD-451D-91F2-14EC42B34E89")!,
                name: "Wykop",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Wykop", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Wykop", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "42CCC3A5-7F2B-4147-B2B3-91C6C875FEA5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3A641CA4-6F57-49A6-9DDC-434168915803")!,
                name: "HitBTC",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "HitBTC", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "HitBTC", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7F9EC53C-61E8-4DCC-A8E5-D5DF6E6139F3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3A997C2D-CC2E-4E14-9BE6-B764351896E9")!,
                name: "Replicon",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Replicon", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Replicon", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "651012FA-1F43-45D3-B916-27959C7C09A9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3AC1C4D9-EE84-449C-AD7F-A42D7FAB9AEB")!,
                name: "RMIT University",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "RMIT University", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "RMIT University", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A053CAA4-006A-482C-81B0-DCB2D99BAC82")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3AF83D66-ABCB-4996-87B3-EA3AF6811980")!,
                name: "Cal Poly Pomona",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Cal Poly Pomona", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Cal Poly Pomona", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "200D1A5A-4D17-477F-8DCE-F5AC5F07A774")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3B0C488C-BD30-4EDF-9441-8A6F97791124")!,
                name: "Proxmox",
                issuer: ["Proxmox"],
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Proxmox", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EF5373E1-D53A-44C2-8DF8-FDB35BD76CCC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3B37043E-2B0A-45CF-9892-2FC264598FC8")!,
                name: "Union Bank & Trust",
                issuer: nil,
                tags: ["UBT"],
                matchingRules: [.init(field: .issuer, text: "Union Bank & Trust", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Union Bank & Trust", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "42D6669A-4FD1-4445-928F-E254072F5AD7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3B394024-5225-410D-86C3-A503206526CC")!,
                name: "Independent Reserve",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Independent Reserve", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Independent Reserve", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "91DC5E46-5BC1-4AA2-A342-24517E7BD941")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3B69751D-D00B-45F2-B48B-391CE10BD1F0")!,
                name: "Segment",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Segment", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Segment", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1C7F0CD9-23F6-4E4A-BEBC-75A1ECFC3121")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3B71EF51-FAAB-4A56-9CB8-11FBE41F2510")!,
                name: "authentik",
                issuer: nil,
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "9C9EA2D0-EAE8-421F-AFD6-70585D7D959D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3BDCC16A-88C6-43B1-A68F-839711B04378")!,
                name: "AwardWallet",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "AwardWallet", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "AwardWallet", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6E0B0B5E-F43A-44C1-9569-6FE8C5D926D3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3BF2E877-D6BA-47B5-BA9D-EED2A288EC38")!,
                name: "HiDrive (STRATO)",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "HiDrive (STRATO)", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "HiDrive (STRATO)", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "72541E1B-29B4-43E9-AC18-24E7BFB67BEA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3BF3C372-753B-4A6A-B6EC-B92637FCF1DD")!,
                name: "Grammarly",
                issuer: ["Grammarly"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "4569F593-1E3B-4F41-9F13-C905D45F277F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3C1BF001-F071-4209-A36C-7B3BDF5A2021")!,
                name: "Cloudinary",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Cloudinary", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Cloudinary", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BE9FCB9F-459B-404D-A523-B74AFBBB6952")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3C657EDD-7759-43C1-820C-6AE75EB20CBA")!,
                name: "Tweakers",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Tweakers", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Tweakers", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D1A868A1-1B51-4834-8C80-817FCDE0C581")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3C6BC6C5-75A3-425E-84D1-DF8C562D8869")!,
                name: "Usabilla",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Usabilla", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Usabilla", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6AFF8A26-1D30-4D78-8215-ECE1F57015C3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3C9FB79F-A473-47EB-AA75-F5EF5B35829B")!,
                name: "Ubisoft",
                issuer: ["Ubisoft"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "EAC7EF2F-0DB9-4227-9D59-2745DC99ADB5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3CA4A205-70C1-4E62-ABBC-ACEEC59FA614")!,
                name: "ThreatX",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ThreatX", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ThreatX", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FD44856A-EA04-4CF0-A826-0240FC8B6E8F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3D0938BB-3863-472C-B28C-967274018AA1")!,
                name: "Liquid",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Liquid", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Liquid", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "176CE24F-F580-4B7E-8013-959C8B62DF26")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3D2E931B-A5C1-4BF6-BEC8-64D823A85680")!,
                name: "Surfshark VPN",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Surfshark", matcher: .equals, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "25759A33-666D-44EA-8185-616EA36E9DB4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3D516EA8-A8B7-4687-82F7-A3B8E9DF68D1")!,
                name: "Gitlab",
                issuer: ["gitlab.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "28FC05D0-A329-4A0A-A0EC-066FD278577E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3E03CE4D-97FF-4740-838A-3ADA751D2C38")!,
                name: "Constellix",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Constellix", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Constellix", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D78B0FA6-4F29-4227-AB83-280AC34DF01E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3E09CAAE-2C07-4281-8B7C-EA76C88D6C87")!,
                name: "Mint",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Mint", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Mint", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "59942DB5-FA3A-4A64-9B24-B3FBE2ED92F1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3EC08D85-D803-4B6A-A2F4-F5D24C9BBA67")!,
                name: "GitHub",
                issuer: ["GitHub"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "FFF32440-F5BE-4B9C-B471-F37D421F10C3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3ED94A08-7DE6-4137-89D4-B8C4805482D6")!,
                name: "Webcentral",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Webcentral", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Webcentral", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6B614D5D-B4CA-41D9-8A20-2839F42CCAFE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3EE94C0D-4C2C-4B59-A35E-9251BED8D7CE")!,
                name: "VK",
                issuer: ["VK"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "1E13DD25-50BD-4766-8B7F-937AE487B803")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3EEA282C-11EE-4CDC-9F8C-B3262E3BA5D3")!,
                name: "Simon Fraser University",
                issuer: nil,
                tags: ["SFU"],
                matchingRules: [.init(field: .issuer, text: "Simon Fraser University", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Simon Fraser University", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "CEC464D3-1EEE-4781-BA8F-128F7962CE36")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3EEE1A70-692E-4105-8DB8-3628A7B6A590")!,
                name: "Todoist",
                issuer: ["Todoist"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D45EAD47-367B-44C0-B258-69D73FF7443C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3FB70080-E145-4691-AE07-2C7FB665A55E")!,
                name: "POEditor",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "POEditor", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "POEditor", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5C26E978-B591-41B0-BE5A-D71D1D0FB529")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3FD6917B-0EB2-4306-B4B1-000256F61977")!,
                name: "Onelogin",
                issuer: ["Onelogin"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "03233892-479F-4F72-BEAA-653B53C3EC03")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "3FF93C0F-1021-4BEC-B9CE-16DAED01097F")!,
                name: "Internet.bs",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Internet.bs", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Internet.bs", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1BEF4744-BE54-4818-9F13-7A8C2B8B27F5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "400F455C-9803-4762-B738-A3A8D5D4AAE6")!,
                name: "Automater",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Automater", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Automater", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7B12A076-9692-4602-A1F9-CAF422BD8D17")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "40A839EA-9C44-4959-9E31-DE18B01001A5")!,
                name: "SmartSimple",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SmartSimple", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SmartSimple", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "9139058A-0705-45F6-8D2D-5063523D8574")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "40FF4402-35BB-44A3-A17F-5C947C6D6F61")!,
                name: "IronVest",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "IronVest", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "IronVest", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7624B4A3-3D4E-4C5D-AA04-E203C6570258")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "413A4CC5-BA05-4004-BC54-06DF1A671926")!,
                name: "Matomo",
                issuer: nil,
                tags: ["ANALYTICS"],
                matchingRules: [.init(field: .issuer, text: "Matomo Analytics", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C5D27BFB-74AC-4459-9C73-2E58A106ADE3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "41C87975-A000-4E3A-81CF-AC9E4804D015")!,
                name: "Galaxus",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Galaxus", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Galaxus", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "41F92F5A-9934-4D4C-AA09-2B7FD4927A79")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "41CE1D02-78B1-4BB6-8B80-C1B76B694F19")!,
                name: "Freewallet",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Freewallet", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Freewallet", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "654F8E2E-6C24-4F05-9E93-B7C1DF97815F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "427B8A65-DE62-4FF4-8D75-9895148D4617")!,
                name: "Logi ID",
                issuer: ["Logi ID"],
                tags: ["LOGITECH"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "208506A6-F088-4349-83DE-AA0B61D3F995")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "42822F00-E91F-400C-9693-24A9FAA52A58")!,
                name: "Stessa",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Stessa", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Stessa", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6BACE99A-BFB9-4236-BDF9-2429249B206E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "42BDF635-F73F-467F-AB80-A8FF816D1847")!,
                name: "Substack",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Substack", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Substack", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "76EF4741-F056-4B68-8E1E-2B9FF467CBBF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "42F378B1-6821-42BA-8B6E-6A1CF60BB958")!,
                name: "Acronis",
                issuer: nil,
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "CA81AE1F-20F6-45D2-BBEF-24BA47ADAB79")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "433319C3-646F-498C-924D-28FD952C0904")!,
                name: "Republic",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Republic", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Republic", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6FCED2F9-550E-4E85-B98D-A26DD1D2768D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "43DC2D2C-B446-498E-9DAA-7B1BD398EB23")!,
                name: "Discogs",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Discogs", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Discogs", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BDB9C5A2-7F48-4CB9-851F-B4B970CE48E7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "43FCC22A-8688-4AE7-9155-2BF49D532439")!,
                name: "Newgrounds",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Newgrounds", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Newgrounds", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "77872E40-DCDB-40FC-89B0-C2FD645CA495")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "442122C4-836C-447A-A781-F4AB137AF75C")!,
                name: "hellostake.com",
                issuer: ["Stake"],
                tags: ["STAKE"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "04E3C048-1F30-45F6-9E83-2A44602A1D0A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "44236C0B-5CC4-4AAC-AB01-30CAB1EC276D")!,
                name: "Planning Center",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Planning Center", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Planning Center", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7380FF3E-A922-4ACB-A989-C0B22E43D500")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "445140B7-D5C0-49D6-9C30-CB24E580058B")!,
                name: "Icedrive",
                issuer: ["Icedrive"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7FFFE036-01B2-4C2D-B739-BCDBB76395C7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "44525AC7-0E28-4CD7-896F-7D9DE3CDC2A7")!,
                name: "RealMe",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "RealMe", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "RealMe", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2CC80AC1-879E-43DB-90F9-12A3A97B5151")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "44E15D6C-665F-4C6A-A1A4-B5A34B292A85")!,
                name: "Too Lost",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "toolost.com", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D8AF5AFE-0F77-4675-81ED-EA3C27ECB14B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "450CAB07-490E-4645-A336-126A798314AE")!,
                name: "Kraken",
                issuer: ["kraken.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "96D6723E-B5D2-4B90-9CE3-BCCB3F919642")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4540CDF9-CE81-48BC-B57E-9EB508D69E8D")!,
                name: "Plurk",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Plurk", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Plurk", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "68824E4C-A24A-4507-9D48-9B22EC882E96")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "454C421A-FAA8-4C01-BECE-36F876D36067")!,
                name: "Panther",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Panther", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Panther", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A428F16F-9BD9-4EC4-B303-201B96F63B5D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "454F77F3-C3B6-421B-8BB2-F2F0D627139F")!,
                name: "Cash App",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Cash App", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CashApp", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F2BC2C98-A5BF-4BE8-948C-28693D1600EA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "45741EB0-3388-4D54-8816-20A4BBA036EB")!,
                name: "Zoom",
                issuer: ["Zoom"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "8E3326A2-13C9-49BB-B28D-C4465B0CE62D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "45947C40-6A26-4CE1-B820-4DCBB65AE9CD")!,
                name: "Piwik PRO",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Piwik PRO", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Piwik PRO", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FE503092-F163-4640-AE33-EC10F8172C3F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "45A393E8-7A18-4734-9689-3D9A55ACD8AF")!,
                name: "Gaijin Entertainment",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Gaijin Entertainment", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Gaijin Entertainment", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "9F0CBEBA-A09D-42D1-B9D2-79881CC95E45")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "45C3B05A-F0D2-462B-B910-C3DC6E3DB303")!,
                name: "Rebel.com",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Rebel.com", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Rebel.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3DCC63AD-04A8-4259-8641-E96082BCE459")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "466E78FA-B2BA-4142-A757-78B040F54759")!,
                name: "Audiense",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Audiense", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Audiense", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8D9F31DA-549D-44D6-83BB-2D2FB6446C47")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "469C0889-1239-493D-91CF-FD4EB360D27A")!,
                name: "Line 6",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Line 6", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Line 6", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "82B80C69-8E1D-4509-8F40-501754838A00")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "46D677EA-9678-4D03-A737-D53750C97F91")!,
                name: "Ubuntu",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "UbuntuSSO", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DBF20573-1304-4D12-BE11-13C590FF1FC1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "46F76AD5-2539-45A8-A765-0648251C4D8F")!,
                name: "MacStadium",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "MacStadium", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "MacStadium", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F31A67F1-59F7-4F7B-859A-671101DF8103")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4711736B-490B-4EBD-B793-F16A3AD6FBDA")!,
                name: "Adyen",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Adyen", matcher: .contains, ignoreCase: true),
.init(field: .issuer, text: "Adyen", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "85C74031-9BC7-40C2-98F1-A7F0E5242AF6")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4729495C-003A-40C2-A879-16DC1A770137")!,
                name: "Coinzilla",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Coinzilla", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Coinzilla", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F5CBF46B-7412-4CBB-87C3-7098D3DAE6C2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "473B0856-B105-4F77-B7EF-F5BF4529837C")!,
                name: "NiceHash Withdraw",
                issuer: ["NiceHash - withdraw"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "C8019718-56B2-406F-BF21-2ADDDA6B21FD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "47D060C2-2CE2-444A-95D1-4DBED7D0DAFF")!,
                name: "RU-CENTER",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "RU-CENTER", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "RU-CENTER", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3FAF2674-15DC-4035-8113-F60AA7164C9D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "47F41598-2809-4BFE-B3E2-03CD0D5F754A")!,
                name: "OneDrive",
                issuer: nil,
                tags: ["MICROSOFT", "MS"],
                matchingRules: [.init(field: .issuer, text: "OneDrive", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "OneDrive", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C505749D-8A09-4C96-88B0-996BAF250924")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "481437E0-6B0C-4289-98EA-ED30AC4D5A0F")!,
                name: "Mathworks",
                issuer: ["Mathworks"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "69123308-C433-4ACB-A876-D5045D25CC83")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "48223642-089D-4E35-97DA-4FBC4BA81C35")!,
                name: "PyPI",
                issuer: ["PyPI"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "ECCAFCDF-9E15-47D8-84C9-7DA00D236135")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "486FBB7B-FF24-46DF-9365-A2332EDAB0B4")!,
                name: "Elastic Cloud",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Elastic Cloud", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Elastic Cloud", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "9EAC4DE4-8D10-4F4E-8795-2571F828FC0B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "48BF9F6A-F64C-40F5-9429-D41325D2304F")!,
                name: "IT Glue",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "IT Glue", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "IT Glue", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2874A11C-BEB5-452E-9B4F-156876168E87")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "48E8F3CE-2EFD-4E4B-82FD-3D638B01F600")!,
                name: "Kuna",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Kuna", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Kuna", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0B00B2F7-00A1-4FBD-9335-CE625DD6403F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "48FEC849-1D85-4FC3-A956-140D07B00406")!,
                name: "Migros",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Migros", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Migros", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C8F93BDC-9FB4-4CA7-A8DA-0C66E07F2E25")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "490203BB-8A1B-48F6-8150-1667071489BF")!,
                name: "Hostek",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Hostek", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Hostek", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DB5959BC-E851-467F-8131-DD5F61EBE31A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4925503B-CABB-4367-BBF7-152E866D28E2")!,
                name: "Laravel Vapor",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Laravel Vapor", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Laravel Vapor", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EECF3530-B758-4680-A8D4-D4A857C472B5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "49489E88-B233-4A79-8069-E41B55036F29")!,
                name: "Travala",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Travala", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Travala", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DB974D03-37C0-4BB0-A3E1-C662FC8FBA3A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "494FA111-CCD8-4EEF-8D4F-47B490EF363C")!,
                name: "Okta",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Okta", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Okta", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F67E6179-6184-4DDF-959B-A2FE39432BCC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "49A043D8-9EC6-4866-B338-E0D73B26ECD4")!,
                name: "Splashtop",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Splashtop", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Splashtop", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B59DD6F5-9532-4C84-B303-01E2941F9970")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "49B24DC4-2520-4BAC-A7D7-F2095ED6C815")!,
                name: "FanDuel",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "FanDuel", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "FanDuel", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BA1C5E3F-7F33-4417-9156-2E581D63DD68")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "49B75004-2EE0-46DE-934E-F62E9271BD02")!,
                name: "Synology",
                issuer: ["Synology DSM", "Synology Account"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "1287CDAB-814B-469F-A718-8C7775643099")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "49D3AED6-6EF9-4E9B-A9DB-95E767145274")!,
                name: "Honeybadger",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Honeybadger", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Honeybadger", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F27D50A0-5B21-40EA-8B59-A1CA1DAAE30F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4A1F455E-CEF7-443F-B1C0-3C50527CC068")!,
                name: "SpectroCoin",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SpectroCoin", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SpectroCoin", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F9E47D2E-344A-4F63-A2CA-FC93FCA70D59")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4A2B1FB8-6DE0-469B-A751-DC44EA1DFB20")!,
                name: "Exmo",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Exmo", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Exmo", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "24FB2716-711E-485D-8857-CC3A882C95E1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4A397626-7137-4AA7-85BA-79515B8ED0D3")!,
                name: "Particle",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Particle", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Particle", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A7FBA7AF-35D1-486C-B664-C38211C10E53")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4A3F552C-99FB-42C8-B1BF-57628B2FDB57")!,
                name: "Sipgate",
                issuer: ["sipgate"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "0A1BCFE8-C98D-48EF-9450-731E34343EE5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4A476833-3773-43D3-94A6-4556E0A776AC")!,
                name: "Vysoká škola ekonomická v Praze",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Vysoká škola ekonomická v Praze", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Vysoká škola ekonomická v Praze", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "248A84E0-5B72-4B81-BB4E-32D4698EB4EA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4AB1A935-47B2-4655-A807-6B925DE0E77E")!,
                name: "Mint Mobile",
                issuer: nil,
                tags: ["RYAN", "REYNOLDS"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "BCA2B91D-A005-40E5-803C-B38012995F6C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4AD7CE16-C64D-4F18-B009-30A270DC782A")!,
                name: "OVH",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Ovh", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DF17680C-B7E9-461B-820D-C62C2C8073DF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4AE6BFEF-0003-446C-9FC8-E0A03DD84163")!,
                name: "WazirX",
                issuer: ["WazirX"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "FD806401-613D-44D2-B170-79B9DEE2C024")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4B418E68-2FA3-4818-8609-66E1E403568B")!,
                name: "Assembla",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Assembla", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Assembla", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "16BC63B0-96B8-44D2-A502-E96C8E81329B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4B45316D-AFF6-4653-B089-BCBF553D9649")!,
                name: "ReelCrafter",
                issuer: ["ReelCrafter"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A5C7A549-CBDB-43DF-BBFD-95B3867AAF2C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4BCFDE28-D843-4592-BB3E-251BB8C4AE08")!,
                name: "Netcore Cloud Email API",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Netcore Cloud Email API", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Netcore Cloud Email API", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B7C7550A-F6D7-4204-929C-6006AD8207D9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4BF34A65-2279-4DA0-980D-0D1BB5A383B2")!,
                name: "Airship",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Airship", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Airship", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D7B81ED8-7B51-40BC-BB4E-4B465E6EBB73")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4C1FAA51-FEFB-4AB5-9201-C54B794D32BA")!,
                name: "Zendesk",
                issuer: ["Zendesk"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "96F65174-F24D-4A85-A89E-89FCF4CC7EE3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4C30FD57-21B4-4D16-88F8-97738DA0339D")!,
                name: "AppSignal",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "AppSignal", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "AppSignal", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "42135C3A-A24E-48F9-9BBD-1F1428EC2BC8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4C9652F3-131C-4C3D-82FB-AC491D8BC843")!,
                name: "Greenhost",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Greenhost", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Greenhost", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8510864A-B571-4414-9248-F76BCEDE8C0C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4CB1849D-650C-48FF-BD99-420859F3D1C8")!,
                name: "EA",
                issuer: ["Electronic Arts"],
                tags: ["ELECTRONIC", "ARTS", "ELECTRONICARTS"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "0B032D00-41C4-4821-90A9-B18B8C27074A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4CFADD11-C568-4C3A-B9E1-41903C45FC92")!,
                name: "Zerodha Kite",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Zerodha Kite", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Zerodha Kite", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "9B6BD9E2-8EA7-4931-B662-6B3C0EB1970F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4D04199D-70D2-41EE-BCD3-6196A01AAEBC")!,
                name: "Remitano",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Remitano", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Remitano", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B082AA72-3B6D-461F-966C-02FC2FD3D1BD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4D0E1409-8C94-40D5-AB71-1BBA22BBDBA1")!,
                name: "Premier League",
                issuer: ["Premier League"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "FBFC34B3-E267-42F9-A970-701C68AD217A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4D1078F9-C4E1-40E8-BD7C-E8320F6094DC")!,
                name: "Niconico",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Niconico", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Niconico", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "27B1435D-3069-458E-A359-8FC67DB876D8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4D44D162-CBD1-4B7E-84E1-A4E8ABD6C55D")!,
                name: "ICDSoft",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ICDSoft", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ICDSoft", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "17FF04DD-3DB1-4F51-B18B-28B102B175E5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4D4C7696-1A84-4C2F-9656-5ABD6E66F3C2")!,
                name: "Delinea",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Delinea", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Delinea", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6D18FD7F-1B69-42AB-89D9-B803236B96D7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4D678469-1333-487C-9D06-6AAB13081670")!,
                name: "Shrimpy",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Shrimpy", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Shrimpy", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FB6EA39B-A1CA-41AB-9126-BF449DC83B2E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4D6F4A49-5C21-4870-A4DF-B85A70BA3FF9")!,
                name: "Bonusly",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Bonusly", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Bonusly", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0E74ED64-5615-4E75-95B5-2661CF3243E4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4D7F651D-7036-42E3-85ED-5559A0E3D11A")!,
                name: "RevenueCat",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "RevenueCat", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "RevenueCat", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0FFD72A6-1921-4787-8210-B695F943EB28")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4D921FE7-DAD4-4657-86B3-5241123D624B")!,
                name: "Taxact",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Taxact", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Taxact", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "84CA5690-5ED7-437E-A6CF-457526190654")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4D9DE830-F4CC-4469-8D1C-3D710E918693")!,
                name: "Panic Sync",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Panic Sync", matcher: .equals, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F5CA216C-23B7-4CF0-A3F0-4C0006439B5F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4DE72DF8-7A74-45C3-B243-D21C70ED838B")!,
                name: "SignRequest",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SignRequest", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SignRequest", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "98972C4B-0DD8-4E22-8316-7767F2788A6A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4E0DA46D-51AE-40B0-9F3F-FA9CA9D80464")!,
                name: "DMOJ",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "DMOJ", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "DMOJ", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A57256E1-8FAD-4E25-B499-157FC3C38986")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4E16E9E4-55BE-433E-922A-A13286096CE9")!,
                name: "OnlyFans",
                issuer: nil,
                tags: ["OF"],
                matchingRules: [.init(field: .label, text: "onlyfans.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DC72A1A9-6DFA-4AFA-8147-6C579F11C277")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4E7A1659-0A8A-42D5-A699-30837AAC73C4")!,
                name: "Bitpanda",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Bitpanda", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C20236ED-2E95-476C-B29C-F425D29826EF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4E82C347-7AD9-4B73-BB4D-C6301EED0004")!,
                name: "FreshDesk",
                issuer: ["freshworks.com"],
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "freshworks.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "05C680D8-BB2F-4EF0-840A-6504FCFDACB5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4EA34B28-FB91-4DCE-827A-DBB07D3EF7C3")!,
                name: "IVPN",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "IVPN", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "IVPN", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "62A15DD7-FA76-40E6-A82C-EDFF4BDF8449")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4EE59893-9BA4-411C-A9FB-5906E1EBAD8E")!,
                name: "23andMe",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "23andMe", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "23andMe", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "CD8D168F-8AD3-4817-8099-794D4F7F45B2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4F0726CF-418E-402D-8400-AFBFD772DA7B")!,
                name: "Bluehost",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "bluehost", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5E8235D7-D208-4C9C-8E3B-974D3149A682")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4F2A249A-EB12-48E7-BFFC-A78BF7888D73")!,
                name: "Box",
                issuer: ["Box"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "9AF46EE0-475D-41D6-A729-A8D930D16810")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4FC36F56-15BD-4724-8C9F-32E7D6C37610")!,
                name: "Capsule",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Capsule", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Capsule", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2A8076DC-B3D1-4B26-81A4-6E199C45ED43")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4FCA7FF1-CBF0-464C-9A37-E2CC5351EEC6")!,
                name: "Wiggle",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Wiggle", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Wiggle", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FA2529C4-598D-479D-AA3B-54CF2177A8CD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5014E45A-94C4-4DE7-8FA2-32D8B159A5C3")!,
                name: "Clover",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Clover", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Clover", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1FCC8CB6-813D-4E91-A65F-FB15F4FC7C0D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "501BA935-3F40-48B0-B512-8E6333E0F753")!,
                name: "VirusTotal",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "VirusTotal", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "VirusTotal", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BA03CB07-C2E8-4A8E-A7F6-039444870B70")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "50547632-724E-4ED9-A552-E5C3BC9BAC8D")!,
                name: "Doppler",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Doppler", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Doppler", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0C28C47D-6BC2-4534-A99B-3D6FDC1ED88A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "50E27ADC-00FE-4D9D-A8B5-323EAE43E8F8")!,
                name: "San Francisco Fire Credit Union",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "San Francisco Fire Credit Union", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "San Francisco Fire Credit Union", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7E4420D5-62DE-45D2-A86D-CE14B017064F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "510E06DE-8861-44A0-A4B4-831F8392B097")!,
                name: "Hostpoint",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Hostpoint", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F70FF97E-E4B1-46AE-B8DE-69795CD9EF04")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "51251986-E6C3-438B-9C05-2362CC53BA2B")!,
                name: "WoltLab",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "WoltLab", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "WoltLab", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "85BDF4F1-ABBB-4FCA-9209-E182D43E489A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "513A463D-0A51-4CBC-B531-6E2C69AA7A76")!,
                name: "AscendEX",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "AscendEX", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "540FBCEF-8030-4BC0-AEA9-5B8D9DD6C3D1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "51CED224-0DC2-4A46-BE4F-3F6FEFC7C48F")!,
                name: "Bitfinex",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Bitfinex", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "24D139A7-9783-4668-BB22-59696C118069")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "51F6194C-93D1-41F4-B65F-F80136CE2FB7")!,
                name: "Nuki",
                issuer: ["Nuki"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "824651BB-1696-4A86-9C8A-A0AD50D15BA2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "51FB583D-61D0-4BFE-8F6E-5E44ADC233BF")!,
                name: "Healthchecks",
                issuer: ["Healthchecks.io"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "28703409-A58E-473D-9690-BA490C139F34")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "520878DF-F9C0-45C2-813B-8918C4C5F94B")!,
                name: "NinjaRMM",
                issuer: ["NinjaRMM"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "46DFC67B-6FA3-45F0-A1E9-58982EB56031")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "524512BC-9262-41CD-BABB-1193DCD07066")!,
                name: "Telzio",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Telzio", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Telzio", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "01D0DE55-64F4-477F-8EA4-A28A81A1666C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5309D9DA-1916-40A9-8D91-18FCCA147BD4")!,
                name: "Open Science Framework (OSF)",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Open Science Framework (OSF)", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Open Science Framework (OSF)", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E922D67D-12B5-492D-ADEC-BC7474BF37AF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5318083F-0330-4384-869F-8C76AD862337")!,
                name: "Chargebee",
                issuer: ["Chargebee"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "400FCED8-6FAC-488A-8154-85BE47D84ABE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "532C2415-76DB-4372-967B-52CC45925219")!,
                name: "LATOKEN",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "LATOKEN", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "LATOKEN", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D4BFD844-4A05-4FEC-982A-BEFE2B1C6924")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "533125D2-0AAA-428D-970C-2556CF8714E6")!,
                name: "Bugzilla@Mozilla",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Bugzilla@Mozilla", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Bugzilla@Mozilla", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "185D6E0E-12D5-4E2B-AA46-3C68B7FEB4AA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5335E427-584E-4F93-962C-A7A50011FE69")!,
                name: "Remote Desktop Manager",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Remote Desktop Manager", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Remote Desktop Manager", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "42BF1357-F9A4-468A-8516-6DE803AF8E03")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "537300D9-2587-4A58-8788-CD1369D150A1")!,
                name: "Pennsylvania Dept of Revenue myPATH",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Pennsylvania Dept of Revenue myPATH", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Pennsylvania Dept of Revenue myPATH", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B361765F-A29C-44E1-9A72-EAFF6F8826AC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "53F88A7F-547D-437E-B702-BAB47F68D069")!,
                name: "DNSimple",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "DNSimple", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "DNSimple", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "169F08A5-6BE2-4230-932A-5C2701E3E74D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "53FBA8F1-DF0B-4EFC-82B0-68B60A5BE8AF")!,
                name: "fortrabbit",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "fortrabbit", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "fortrabbit", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EFE89B5D-CF7D-4620-A7EC-3D6D775B4D8F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "53FC964A-17D5-40B6-A274-19578701609D")!,
                name: "ESET",
                issuer: nil,
                tags: ["HOMR"],
                matchingRules: [.init(field: .issuer, text: "ESET", matcher: .startsWith, ignoreCase: true),
.init(field: .label, text: "ESET", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0C8F14A4-D69D-4021-BDAA-5A7821E3F0B4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "54145E0D-6005-4961-B61B-9D39BB21ABEF")!,
                name: "Scalr",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Scalr", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Scalr", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "95433532-C1B3-45CD-8A78-24E0297EAF7B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "54202EDD-B74C-42A8-992C-6F6CCADB6A63")!,
                name: "Shareworks",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Shareworks", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Shareworks", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "59BCBC4D-3727-4430-AB39-885B0677D1C1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "549A306A-F8CA-444C-96E6-1B832491B443")!,
                name: "NDAX",
                issuer: ["NDAX"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2FB7A45B-7E61-40A8-A258-3C7E5172F355")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "54E07A74-BA7B-43AA-BC8D-AAB70BE10469")!,
                name: "State Employees Federal Credit Union",
                issuer: nil,
                tags: ["SEFCU"],
                matchingRules: [.init(field: .issuer, text: "State Employees Federal Credit Union", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "State Employees Federal Credit Union", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "56D5C3F4-BC20-4960-8D60-F38CEC78B1F8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "54F6272F-E6C1-4A88-8E2C-A1B0A490C55D")!,
                name: "BackBlaze",
                issuer: ["Backblaze"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D92BDE37-A6D6-475E-B71E-ADB362EFA18A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "55A63BBA-71BD-4064-A7D4-EC1122E27B81")!,
                name: "World4You",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "World4You", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "World4You", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B2B1AED3-C166-44A7-826C-F15C20642CB7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "55B8E8B9-3367-4365-A341-F2E9064EEE91")!,
                name: "Logitech G",
                issuer: nil,
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A8A6625D-121C-4762-8199-03525DC511C7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "55D34ACD-3022-4AD9-BC87-06C075D5DD15")!,
                name: "Dashlane",
                issuer: ["Dashlane"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "FED7D171-3D84-430C-91D5-4378EB83DEDC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "564E69CD-B099-46E0-B4C2-BDC102BA99C2")!,
                name: "KeyCDN",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "KeyCDN", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "KeyCDN", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B8A56771-28DD-40F9-8E84-DAB5D2039B97")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "565551D7-CD9B-4800-BC14-279129FAC83C")!,
                name: "CMG",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CMG", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CMG", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6810950A-EB0C-46FD-9A02-273A81952689")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "56CC9FC0-0F57-4777-A3E0-CCAAD03234A8")!,
                name: "Mercado Libre",
                issuer: ["Mercado Libre"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5CB7030D-45E2-45A4-B8C6-2B5D61A3783E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "56F87638-E0B8-4059-B82C-0CA3A840D927")!,
                name: "Huobi",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Huobi", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Huobi", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6B94DC16-5D8A-499C-8F7F-3C0C34E443A8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5702306F-F354-4325-A35E-287079C31607")!,
                name: "POST Luxembourg",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "POST Luxembourg", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "POST Luxembourg", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D16C75C4-6E08-4CC7-8D1D-FF58309D44E4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "571BD879-7E0A-49B8-9B24-929BCFAFF519")!,
                name: "Buildkite",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Buildkite", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Buildkite", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "47701D40-8581-4789-8CD1-B1CF9B191FF3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "573B2787-4AAF-4EAA-A065-A1F8D2672B30")!,
                name: "CEX.IO",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CEX.IO", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CEX.IO", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4EA5519A-AA34-45D3-9878-F357E5E23154")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "57D20BE7-1935-45C1-A19A-790C23DDB220")!,
                name: "Republic Wireless",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Republic Wireless", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Republic Wireless", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "74C21844-BCC2-4725-8838-1BC865EAECB3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "58041C53-2CA3-47DA-AB53-F17FBE7F954E")!,
                name: "Nexus Mods",
                issuer: ["Nexus Mods"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "6EC7D249-30AA-4164-9BA6-87AAD37692D8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "58799998-A711-4EB6-8755-838CFAC65C5F")!,
                name: "OpenAI",
                issuer: ["OpenAI"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "0775DB30-2BDC-42B6-AAF8-439AAF276C49")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "588921BF-6DF7-4D92-A881-9AF92E15642B")!,
                name: "Instagram",
                issuer: ["Instagram"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "F4CAD0B9-00D5-420C-804C-D41CE8825EED")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "58DB05DE-2CEB-42DA-97B5-00C9EF845C8F")!,
                name: "StatusCake",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "StatusCake", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "StatusCake", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C5975680-E3AF-4E36-A108-717908865909")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "58E275D6-8398-4956-B703-64CF9F408CA1")!,
                name: "Adafruit",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Adafruit", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Adafruit", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A47DB328-5E4C-4F98-A37C-742990FE8B60")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "58F88DD4-B0B3-432E-B75B-CA4D030F8A5A")!,
                name: "Freehostia",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Freehostia", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Freehostia", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "77846B2D-BFF4-496E-A5E5-2C73EEB383EE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5918BEFE-69A1-4CBF-8291-D616F39D392D")!,
                name: "Textlocal",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Textlocal", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Textlocal", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "AA53FFFB-8AED-4B63-B904-BE3A72F93C25")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5929E53B-95F3-426B-A380-8220D1E37E9E")!,
                name: "G2A",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "g2a", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B20EF2CE-2235-4309-A02E-DCA07E946505")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "59337F47-8ED5-455B-BC06-81EC692EFC24")!,
                name: "INWX",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "INWX", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "INWX", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1311CE99-EF79-4606-8E6E-ABC93D54CBE5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "593DD333-B586-4FF7-B573-D30277D82789")!,
                name: "Chevrolet",
                issuer: nil,
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A1043452-67BF-4EFC-A160-ACA21A92B1C9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5A4EB6E0-0EA7-4B20-8D3E-A480BDD9CB02")!,
                name: "Best Buy",
                issuer: ["Best Buy"],
                tags: ["BUY"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "FCCBEDA3-F69F-4A45-9F83-66BF887D3002")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5A775BBC-B371-4232-8A8E-B38FD6A36B15")!,
                name: "AOL",
                issuer: ["AOL"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "AB1DE355-E0F4-464A-9913-9357401D5E57")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5ABB0AAD-8F88-4051-A363-2D25219832F9")!,
                name: "DigiCert",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "DigiCert", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "DigiCert", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C80C921A-BDCF-408B-983C-18E5C236B071")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5B290D3A-DADF-411B-A183-761E68C53520")!,
                name: "ReadMe",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ReadMe", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ReadMe", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "9E5EF08D-C36C-4B7A-82C4-CF00A3EBFD95")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5B52736C-5D52-4195-873D-A8EC606DADE9")!,
                name: "StackPath",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "StackPath", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "StackPath", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7DB726C4-4803-4E71-98DF-8A0D2C0BE989")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5B52F3E4-4CC6-49A1-9639-EC676DC78E00")!,
                name: "Protolabs",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Protolabs", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Protolabs", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D05F53F7-BBD7-4B9C-BF8A-EA008C9D40A8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5B545E9A-9F41-4296-93A7-10B5336B8845")!,
                name: "Call of Duty",
                issuer: nil,
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3A70FCC1-A406-4212-BD0C-440DBE6AE824")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5B986CA0-C5CA-4F7E-9A97-424B9B2E6655")!,
                name: "Moneybird",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Moneybird", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Moneybird", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "14E21FBC-61AD-4BB7-AF20-341714CAA161")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5BA2C9CD-CCA9-4330-A09D-7ADF5AFD0184")!,
                name: "Atlassian",
                issuer: ["Atlassian", "Confluence"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "CD70F801-5EE2-41FF-8AD5-40C9C1E9CACB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5BC5B82C-47E2-411A-9911-D25FBE464324")!,
                name: "Vultr",
                issuer: ["Vultr"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "F733981B-6D51-4B1F-AB45-D52624E0362B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5C9EFDDE-CB62-4304-9F04-D120084A53DD")!,
                name: "Discord",
                issuer: ["Discord"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "F260FFA4-F41F-408A-AA2A-03D943EFE371")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5CC08262-6E24-4EB7-88D4-3511276AB5F9")!,
                name: "Alibaba Cloud",
                issuer: ["Aliyun"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "67AEE011-7509-41B7-8ABB-584F529B9E70")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5CC7A323-72C3-4E18-AC71-6E99A3F1AB21")!,
                name: "ORCID",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ORCID", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ORCID", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "529AC5A2-27DE-4C74-9673-5E6CBB382AC7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5CCE9662-946C-4E04-8CB4-F4276DA76875")!,
                name: "TinyURL",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "TinyURL", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "TinyURL", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DC9F7D29-A661-4DBF-8DE2-1EDB853CAC21")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5CECE28E-0C32-4242-AD2C-FF0864A6C6F7")!,
                name: "ImprovMX",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ImprovMX", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ImprovMX", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DC3B4243-717B-477D-B5E9-042572CD9F8D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5CF8BE69-25F5-4D43-AA51-2D54930D247A")!,
                name: "PayPal",
                issuer: ["PayPal"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "FF415E4A-32F1-47BE-9274-44AB42F79720")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5D2778B3-E293-49E7-A39E-66D86C21DD96")!,
                name: "Dropbox",
                issuer: ["Dropbox"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3C82E6EE-906C-4D6A-9992-01AB376614DB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5D3857D5-C819-4FC2-9CBB-14572BBE0BD3")!,
                name: "BeyondTrust",
                issuer: nil,
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5D8C1875-0D39-4178-94DB-1F3BA3BBACA1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5D4710E6-1EB7-4D29-B1AA-1C416A20773D")!,
                name: "ClouDNS",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ClouDNS", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E4CA9FB2-281D-4146-9DD3-083899D1515D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5D4A5EFD-F4C8-4B0B-845E-B502DF23C341")!,
                name: "NetEase Mail",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "NetEase Mail", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "NetEase Mail", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0AB0D45E-340F-433A-B205-2D1A2DE951AD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5D4C1AD0-35E7-4205-811B-52D596651CA2")!,
                name: "AngelList",
                issuer: ["AngelList"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "6900249F-744B-43DF-86BD-8AD8FB51965A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5D95F8ED-E678-4CEA-A700-BCA526EE0891")!,
                name: "BitMEX",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BitMEX", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BitMEX", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "54CBBF87-362A-4CCE-A614-C11844631E51")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5DA3A886-876E-485E-9A37-5C5D1C258ECD")!,
                name: "ENEBA",
                issuer: ["ENEBA"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D0239931-F1FB-4D08-AD44-06104A85C83C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5DFA53B5-48C3-48EB-A134-DB9AC58E8D34")!,
                name: "Privacy",
                issuer: ["Privacy.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "4FE59FFA-9851-47DF-88A2-15104EA2985A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5E62A68A-88F4-4F3F-AD60-DF8EA34BDC57")!,
                name: "MongoDB",
                issuer: ["auth.mongodb.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E082188E-0759-4827-96FF-ACFB35702A52")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5F6CF4BF-E408-41BB-A520-4C27417BA474")!,
                name: "Infomaniak",
                issuer: ["Infomaniak"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5FAF5121-0161-4B23-A875-B347574B891B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5FA52BA1-3B2A-4998-90BE-B89DC850BE9D")!,
                name: "BTCPOP",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BTCPOP", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BTCPOP", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4B58BFB1-12FB-4361-986B-A4A1B7777553")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5FAC27E0-E0E4-4E5C-BA7C-54CA0C5F1482")!,
                name: "Coinbase",
                issuer: ["Coinbase"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5BD3CBD6-32B6-41F0-BAA3-3FCCAF624269")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "5FCD18AF-731D-402E-8DA8-69BEBA902BB3")!,
                name: "Aussie Broadband",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Aussie Broadband", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Aussie Broadband", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "63AABEAE-81B0-4F97-A802-9ED78F96E288")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6007631C-69F9-4613-B6B3-C90E2DD0AB44")!,
                name: "Cloudways",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Cloudways", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Cloudways", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F8E7EB20-5387-4EFD-A903-585698E53CDB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "60453565-C595-450B-BD3D-62180F8044B2")!,
                name: "Localize",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Localize", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Localize", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "34E67FB2-9608-4C3F-B357-7EF2C702CDFA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "609517DD-C33F-4AF9-8679-B8B9B2D96A98")!,
                name: "Skype",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Skype", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Skype", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "39B080C5-0D73-4B8D-8A05-D258D3C69F0A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "60975B64-7A9D-4226-AE20-9D6BC2762E47")!,
                name: "Expensify",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Expensify", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Expensify", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BE6564D9-BFA8-498D-9020-0373C7317AA1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "60C8159A-CF70-4375-9473-EC98A11C1C75")!,
                name: "LocalMonero",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "LocalMonero", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "LocalMonero", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4BE367E8-B77F-4BF3-B8A5-E93E5D451F9E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "60C8875D-2845-4C81-841F-918E5E1A7298")!,
                name: "Shortcut",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Shortcut", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Shortcut", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4817E758-BCF3-404B-95F9-65292F4D3483")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "60CEFB59-BC28-4490-B5F5-546641D3A561")!,
                name: "Sailthru",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Sailthru", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Sailthru", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "85952097-0EAF-47FF-9744-8BDDCE53FC26")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "60F81C6D-B3C1-4FBF-BF86-F28DF7376815")!,
                name: "CrashPlan",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CrashPlan", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CrashPlan", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "37B3876F-62F5-4DCF-A24E-13C18AB36111")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6157EF8E-EBDA-443C-9602-02B7E1A531A6")!,
                name: "Outbrain",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Outbrain", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Outbrain", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BAD851A0-3907-4A7F-AA45-96F70A3F688B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "61650469-DC5D-4FB7-85E3-B5D4F277377A")!,
                name: "Restream",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Restream", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Restream", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "46879A21-13B9-4125-8530-35100A992AD8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "61C0C1E1-B2B5-4DEE-AB0C-735F1B70A5B5")!,
                name: "Maropost Commerce Cloud",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Maropost Commerce Cloud", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Maropost Commerce Cloud", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FA5F4A79-9C2A-4060-BFCC-259778DE34CF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "61F58F09-CAD4-4AB3-8417-40C0E49FF717")!,
                name: "VicRoads",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "VicRoads", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "VicRoads", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "888FDDF1-10D6-41F1-B17A-1F49844EE543")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "621298E1-9F5C-4CA8-87E2-632D8CB8397E")!,
                name: "Tresorit",
                issuer: ["Tresorit"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "AB897D14-54A5-4B0F-AD81-60F5F55A6841")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "62224345-10EA-4616-95EB-4DC3688CF7C0")!,
                name: "Jitbit Helpdesk",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Jitbit Helpdesk", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Jitbit Helpdesk", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "972B593E-A13D-4C5C-8365-16069984E894")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "62615CA7-6E59-4074-8F58-2FE516885860")!,
                name: "H&R Block",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "H&R Block", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "H&R Block", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "47F0A7A1-CE69-4356-88D2-D83B8B49BEFB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "62D46581-9F65-4B34-B415-214726BD4E86")!,
                name: "Invictus Capital",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Invictus Capital", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Invictus Capital", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0CE28E8B-C2D8-4976-9F4D-7EFFF0C47757")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "62E56D6C-C438-4949-A033-C7588B92E403")!,
                name: "Trello",
                issuer: ["Trello"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "AF39F910-F20F-4210-9F02-4D91AE108FC7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "63751C07-45A7-470A-9CE0-22968FBCB53C")!,
                name: "Gandi",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Gandi", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Gandi", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "51332A22-9137-4FDE-93E0-2ECF87F544C4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "63AC70C3-A0B7-42EA-B638-39B685F0780F")!,
                name: "500px.com",
                issuer: ["500px"],
                tags: ["PX"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "4362CE74-062F-4794-8E3C-08B39EE0B8E5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "63CBF7E9-87B0-41D1-B242-C90AD2783A63")!,
                name: "LiteBit",
                issuer: ["litebit.eu"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "F4F47EAB-E255-48EF-9BE8-558F3C6AF045")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "63D68C75-4211-459C-94C1-9774B81AD290")!,
                name: "Close",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Close", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Close", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "99477AAD-AEED-4726-8E7D-6254D594006E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "63DC4E18-61E3-4874-96A5-A5A47B490A8E")!,
                name: "SproutSocial",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SproutSocial", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SproutSocial", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EC17BE6C-A282-45AF-A4EE-8468CD761FC8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "63F0BDAF-94FE-4B4C-983F-90442877F0EC")!,
                name: "Uber",
                issuer: ["Uber"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "B73CC164-8763-4826-8603-0C79F08A1EB5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6440ABAF-A8CC-4BFA-A859-6915A6AA6EA2")!,
                name: "ServerPilot",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ServerPilot", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ServerPilot", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "09759620-55C0-415E-ADBD-BB158266D437")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "64586867-B4B4-493A-80C5-DECC332C24E1")!,
                name: "Bubble",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Bubble", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Bubble", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "70B18229-CCD0-466C-8779-FC67AB6F6D97")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6481DFA9-0BB0-4A14-A431-0E1A3AC8CEAB")!,
                name: "CosmicPvP",
                issuer: ["CosmicPvP"],
                tags: nil,
                matchingRules: [.init(field: .label, text: "cosmicpvp", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A3E24799-F3F1-4DAA-B5D2-244BFE53A19F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "64C56626-9E78-433D-AAE4-6ADEEB7BDEE0")!,
                name: "Justworks",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Justworks", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Justworks", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DCCFB638-397F-4EEF-805A-3BA0EAA5858A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "652BAED8-FD89-4599-A474-187BB1FC1915")!,
                name: "Ting",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Ting", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Ting", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6A138FC7-DCB6-41C2-AE93-08944E969BC4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "658E12D3-50E5-4321-A388-764188D77143")!,
                name: "Bitbns",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Bitbns", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Bitbns", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F9FD1CF1-C231-429F-A13C-6BD08D46D07F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "65C4DD13-37FE-400B-9240-2AE7C136D6D6")!,
                name: "KickEX",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "KickEX", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "KickEX", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F601BE29-045E-46D4-BFAA-7995CFBDE28E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "66133DB9-164C-4C39-9EDE-F909C667FE1C")!,
                name: "BuiltByBit",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "builtbybit.com", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0F20B30C-1147-485C-B839-2A44A29DEFA2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "66917FB1-38A9-4AE7-95E6-F0EC44746D05")!,
                name: "Storj",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "STORJ", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C6360125-33FE-492A-A2CD-57DD72C18CD3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6696008C-5FF3-437A-A80D-665A3776A21B")!,
                name: "Migadu",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Migadu", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Migadu", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "941EADA5-6FBF-4C78-8096-E51536EC4CE2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "66E3C12A-D465-427A-8561-1289D6E5BFC5")!,
                name: "Rapid",
                issuer: nil,
                tags: ["API"],
                matchingRules: [.init(field: .label, text: "RapidAPI", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A713516C-1656-40B8-91BA-85E986805575")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "66E82703-80A8-41FF-885C-1E677BCC9DB8")!,
                name: "N-able",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "N-able", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "N-able", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EBDA71A0-A384-48DE-A3CC-BDB3E92C539B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "671C86CA-8EBD-4DD3-88FF-0A4906B2CC63")!,
                name: "BitcoinTrade",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BitcoinTrade", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BitcoinTrade", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "506C2D5E-3DD1-4B9D-B863-468AA1760204")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "678BF6BE-C919-49C4-AD4E-3FF5D2141803")!,
                name: "Dr. Windows",
                issuer: ["Dr. Windows"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "B92626FE-68FF-449E-BA64-3E92D55AC2D2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "67DD0749-99E2-405A-9D35-160A1439B1CE")!,
                name: "Carrd",
                issuer: ["Carrd"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "40577F08-9491-47AB-8D7A-DD9E4E0061B7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6825A24C-6E3A-4E0C-B0CF-8DE9A1294459")!,
                name: "EasySendy",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "EasySendy", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "EasySendy", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C9B4B55A-AD1D-40E0-A8B6-7E47AE3D79EE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "689E8B6B-63D2-41E3-A7BB-6F935260D0CF")!,
                name: "WeVPN",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "WeVPN", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BF159C1F-31B1-4DB3-A8BD-802345EC8A4D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "68C47A3B-5A05-4F56-8096-078A5B9B8E1F")!,
                name: "itch.io",
                issuer: ["itch.io"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3CE6BB6A-A1D6-4AC3-8125-A556DEEE362A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "690233B0-1E1D-4E7A-A89B-375862CC4666")!,
                name: "BitSkins",
                issuer: ["BitSkins"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "CD08463B-4344-4269-8561-60029F98BA5B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6902E7BD-1CF1-4AD2-8151-B7966680B7BF")!,
                name: "Hurricane Electric",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Hurricane Electric", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Hurricane Electric", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "85C3CF65-87C1-432E-A867-628FC706F86F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "699C584E-79CF-414B-94D5-64784459F7ED")!,
                name: "Bitrise",
                issuer: ["bitrise.io"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7EB65E52-5408-4F85-8500-1DA6AECAC467")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6A2FDE3A-B8B2-4321-8A68-D8D2E4BA2AD7")!,
                name: "Onshape",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Onshape", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Onshape", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3014F069-0E58-4015-AFCD-5224DB4BFF96")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6AB00AEB-5F0E-4E29-BB8C-E5B4AE76774C")!,
                name: "Packagist.org",
                issuer: ["Packagist"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "C3F63528-EECE-438A-A74D-AE7AC8C74BFB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6AB5F6F1-40F4-41E4-82FF-0DD11F9B676C")!,
                name: "Bitkub",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "BitKub.com", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "995DB454-F44B-4F16-BABF-9E7435DD64C9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6B4613C9-B31F-44D7-B498-DB0813243983")!,
                name: "Payworks",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Payworks", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Payworks", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2B16924D-BB0F-453E-A2F0-03C5B0877467")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6B563B30-0251-4F4D-BAD5-BAD41C04273B")!,
                name: "ActiveState",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ActiveState", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ActiveState", matcher: .contains, ignoreCase: true),
.init(field: .issuer, text: "Active State", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Active State", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7B8823BA-F7FD-4D17-B9AD-D5AE5DA25C46")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6B67B5C1-4824-4038-A875-58CB18EF5D55")!,
                name: "Namesco",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Namesco", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Namesco", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F50C4529-0EE0-42CC-BEDA-64E0425F9242")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6BA3148A-C0A2-4E2F-9EE5-40DBDE6130BA")!,
                name: "AppVeyor",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "AppVeyor", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "AppVeyor", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "11B81890-F35A-4779-8268-98C62618BED4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6BDDAF34-C512-477B-AC4C-2AB953546F9F")!,
                name: "Korbit",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Korbit", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Korbit", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FC184076-506E-499F-8A9D-0A618C5DB0B9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6BE22AFD-1D40-4375-B5DA-5581B886EDB8")!,
                name: "Bitvavo",
                issuer: ["Bitvavo"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D0785C6F-C7B9-4F15-8521-2162F44F645C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6BF484C8-E094-42F3-8767-23621B953453")!,
                name: "Circle",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Circle", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Circle", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7D59072A-B3E2-4D85-A22A-2F99C3795F61")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6C473443-8455-46E9-8534-10F2F8CA09F4")!,
                name: "Bitcoin.de",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Bitcoin.de", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Bitcoin.de", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "69BFAAEC-2CE9-4CC3-B632-318F87407434")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6C72507C-2C2B-491F-9AAB-44BA42CF2F36")!,
                name: "Woodforest National Bank",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Woodforest National Bank", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Woodforest National Bank", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4B70A8DC-5839-4BBD-80F3-EDC7EB31233A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6CFDC4BD-9803-465F-9D17-13806162019C")!,
                name: "Gusto",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "gusto", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BF35E203-8367-4EB4-A9EA-D6B22319B761")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6D03B06B-BBB7-4CBA-829C-9EABEAA9A0AB")!,
                name: "The Good Cloud",
                issuer: ["The Good Cloud"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "61022FE4-5B24-452C-8085-81BF30CC6DEC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6D1BFC32-C7EF-4E4B-A975-0D0E2642721F")!,
                name: "TP-Link",
                issuer: ["TP-Link"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "C0559E31-612C-4A18-B030-65AC6B60E950")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6D3B671F-4A61-410C-824D-3EE6AF5B180A")!,
                name: "Dynadot",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Dynadot", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Dynadot", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8405FBA4-A4C1-49BF-B7E9-87479E2D17E8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6DADC18B-D1BC-44F9-A046-B72DE56A0808")!,
                name: "DNSFilter",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "DNSFilter", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "DNSFilter", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B700E46E-FDD7-44E7-A0EB-20D3F5228926")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6DC6C359-75A2-48CA-82E7-CF6AC8D98A68")!,
                name: "Poloniex",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "@poloniex.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BB70EE48-AE34-40C2-BF4C-E941ED9E04F1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6DD72222-A13A-480B-9F02-7137D5604AB3")!,
                name: "Flourish",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Flourish", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Flourish", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8A5C7008-131A-495F-A8CA-71D775EB42B8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6DF2AE22-C09E-436A-9B4F-34F2B0E0F814")!,
                name: "Uber Eats",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Uber Eats", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Uber Eats", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F2900828-1B1E-47FF-8A72-276F8E9A6E20")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6DFB21F3-D658-47D8-9A36-0F3C4336DE6B")!,
                name: "Prey",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Prey", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Prey", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "404F2D53-F0A9-4420-AD92-0C7FCF23FFD7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6E7521E9-5B52-44F0-B1C0-A3222EDD1E7F")!,
                name: "myPrimobox",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "myPrimobox", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "myPrimobox", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C1351145-F405-44EF-809F-82E373C19653")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6EA011DF-4A59-47A0-A839-3A4B94FEE389")!,
                name: "Demio",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Demio", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Demio", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F9C7A591-2AB8-4B6F-9653-CEE4370BA2CA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6EC20803-2859-460A-9A76-939E9F092F08")!,
                name: "Sellix",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Sellix", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Sellix", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E1F5907E-B856-4E39-A4F4-4E6AEA7CFBE4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6EEAB7E7-197D-47D1-A18F-7CADA1793DA4")!,
                name: "Intercom",
                issuer: ["Intercom"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "08148E29-EA43-456A-9CBB-25B40172428F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6EFD7B62-E065-4A91-AA32-0144F76B9A5B")!,
                name: "Report URI",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Report URI", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Report URI", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "73754151-9AFE-412D-937E-29F530FB6C69")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6F493F40-3C26-4CB0-A4BA-3563C91C38DE")!,
                name: "Пачка",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Пачка", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Пачка", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5A9DBC0C-ED8C-445E-A5E1-1F55D21C6A33")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6FA66106-36F1-4DC1-AA1A-9BDE97EE3756")!,
                name: "Joyent",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Joyent", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Joyent", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D19F6BDB-9893-4CCA-B71C-18E8EEEEFB04")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "6FF5D06A-2EBB-431C-8466-B1750C1B1AA8")!,
                name: "SeatGeek",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SeatGeek", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SeatGeek", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "34B82477-092E-4699-89FF-F6EF734BBBE0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7000B3FC-B371-4348-BAEA-9FC1DA426F9D")!,
                name: "Lichess",
                issuer: ["lichess.org"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A7262F92-F8F6-46E4-B0D8-E0A11B4C251E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7003A9BC-4B97-4DAE-9D3C-0570B60D0C70")!,
                name: "Hover",
                issuer: ["Hover"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A2533A1D-3F07-4F86-AAE6-5555A35CCE0B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7014974D-2B62-4420-8240-B7A3B64E775C")!,
                name: "Square",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Square", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Square", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "659A1800-4CFC-432B-A7B7-60A826CBB97B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "702292DF-58D9-4C69-807C-B3E62DFB942F")!,
                name: "Metorik",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Metorik", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Metorik", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B8DF9139-8AC4-40EE-A842-8B14B979E974")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "70657302-3333-4F5B-8B12-4D61C6A0F141")!,
                name: "Hostwinds",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Hostwinds", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Hostwinds", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A4307423-93B2-4729-A594-9483B7974C4A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "70A46EC0-3965-4138-89CE-C05555281CC8")!,
                name: "Zoolz",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Zoolz", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Zoolz", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "341014C7-6CDA-4FD8-A355-D4FA1C7EF7AE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "70DC642B-ED96-4BD4-89EC-9A18A6CF7E1F")!,
                name: "Redis Enterprise Cloud",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Redis Enterprise Cloud", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Redis Enterprise Cloud", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D94215C9-CA7C-4306-9F49-AA5DB850DB2A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "71426A98-E772-416A-B691-0C5630AED184")!,
                name: "ZAP-Hosting",
                issuer: ["ZAP-Hosting"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "AADF5A54-895B-401D-8A2D-608D26F037BB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7143FD13-09A8-4256-9BEF-B1055689A8B5")!,
                name: "Neeva",
                issuer: ["login.neeva.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5D6912B0-60C3-4794-848C-A15EED8BAA65")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7167B7DC-8D8E-4053-9479-26D649BA05A5")!,
                name: "ThreatConnect",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ThreatConnect", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ThreatConnect", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D83B6C20-FB9B-43DC-817F-56D9183DE14D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7179D190-041E-4CC9-BCEF-C8A15C25384C")!,
                name: "Philipps-Universität Marburg",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Philipps-Universität Marburg", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Philipps-Universität Marburg", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "13FCD46B-0788-418A-8A4C-D8AEF91C40B8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "726E45B9-E811-428C-8BE4-F52CFB810578")!,
                name: "Synergy Wholesale",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Synergy Wholesale", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Synergy Wholesale", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D684C953-C5C7-4241-AD0B-631EA0D07242")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7282FE22-16C4-4102-AB7B-6960DEA69951")!,
                name: "SecurityTrails",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SecurityTrails", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SecurityTrails", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1AEDEA4A-554C-4193-A930-21E5425A7873")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "730F2DAD-0D7D-4574-A714-BD0FB9292BA5")!,
                name: "Fanatical",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Fanatical", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Fanatical", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "38136B6D-CDFF-44E5-9FF0-C1A478CCA5E0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "734CB24B-5965-4544-8FDA-54132B887E8C")!,
                name: "Ramp",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Ramp", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Ramp", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "83A5D693-864D-41ED-BAF0-C366A3A53D9C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "73693D82-3DFD-4778-B6A4-359BD8B9E024")!,
                name: "Survicate",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Survicate", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Survicate", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "AF641748-6C97-4133-8248-390F34A90EC9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "736E2AA2-AEE3-46A0-BC69-E3377FD4CF83")!,
                name: "Basecamp",
                issuer: ["Basecamp\'s Launchpad"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "C343B6B4-3626-48F5-81C2-84033B5B48B5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "73EC635A-EAF4-4BEF-99DD-4A7B154D8451")!,
                name: "Iterable",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Iterable", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Iterable", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "47A686D8-58ED-4BD8-A286-2C7A8C66F009")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7412393C-BC2B-4C7A-B21B-EB9F48673635")!,
                name: "FollowMyHealth",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "FollowMyHealth", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "FollowMyHealth", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "94E5A921-26DD-4B78-8C78-4071F3FC745B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "743215A7-3115-4E48-A8F9-E87B103428AE")!,
                name: "Unity",
                issuer: ["id.unity.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "770731DE-F13B-4D38-9079-999A869E6389")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7432959F-6958-4529-8149-F6F071B3D21D")!,
                name: "Nintendo",
                issuer: ["Nintendo Account"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3FC48E21-AFBC-4A85-AA27-D07130D0C7F2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7433835D-C9D1-4074-8E84-A3AA33AC3994")!,
                name: "Plaid",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Plaid", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Plaid", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "9B47D1E8-9118-45EB-8C90-E2EA3B7B174E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "744E788D-3975-43AC-8166-0029C9A0871C")!,
                name: "Facebook",
                issuer: ["Facebook"],
                tags: ["FB"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2100A131-7869-4CA6-B476-F1FC0EF103BF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "74771336-6BF1-4E7F-8331-3B59FEEC4710")!,
                name: "Paycor",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Paycor", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Paycor", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F3B7BDD9-9F8E-4450-BAF8-3A8AD24DC1A8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7540657A-7D4F-4ABE-970C-A8267F68E92D")!,
                name: "The Ohio State University",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "The Ohio State University", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "The Ohio State University", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3C4E0DEC-21FD-4A72-B9EB-8CDC12F9114C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7763054C-B3F6-41B9-9EBC-508E0ABA3E27")!,
                name: "Wasabi",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Wasabi", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Wasabi", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "CB2E0939-87C3-49B5-B727-3DEA0F888149")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7773DCEB-DFDA-4FF7-8A43-F1E8B3F155B4")!,
                name: "Joker.com",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Joker.com", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Joker.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "19A99019-E536-4AFD-9308-178113C287B2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "77967BDD-6EDC-4CD7-961F-ACD8A1DD276A")!,
                name: "BGL Corporate Solutions",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BGL Corporate Solutions", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BGL Corporate Solutions", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2415E851-D60B-42E2-8C3E-5E173F141329")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "783CD328-E505-426F-821B-E281FB8E9EDA")!,
                name: "Render",
                issuer: ["render.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "20C994FC-BFC4-4FFA-A2ED-B469E03451F1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "784D131B-3688-40D5-A24F-39101716823A")!,
                name: "AJ Bell Youinvest",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ajbell", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ajbell", matcher: .contains, ignoreCase: true),
.init(field: .issuer, text: "aj bell", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "aj bell", matcher: .contains, ignoreCase: true),
.init(field: .issuer, text: "youinvest", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "youinvest", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C132E76A-5792-4B93-9E4E-E6220ADF5CC0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "78651111-6963-4A5E-A5DE-77FEC9B16139")!,
                name: "OpenDNS",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "OpenDNS", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "OpenDNS", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0653F8BB-4659-474C-B353-7003B85EE86D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "78DDEE53-9480-4C1D-BC58-5983549C25E3")!,
                name: "Time4VPS",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Time4VPS", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Time4VPS", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "04931659-0F20-42E6-B51B-6F31F6825210")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "78E11F50-C9F2-457C-B7A1-7620D5F28AB9")!,
                name: "Veracode",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Veracode", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Veracode", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7AECF7E7-FD85-49B4-8112-85E42E0E5370")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "78E779CC-4926-4B0E-A58D-056D04ACD8E9")!,
                name: "Tito",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Tito", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Tito", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "93491C63-EB9E-4BF0-9FCD-0181B1324329")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "79549405-BA55-4C7B-9D48-3B15002B5B30")!,
                name: "EnZona",
                issuer: ["ENZONA"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D506BFDD-D5CA-4AB4-A4C1-960B445226F4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "797D7590-B2DB-4CB2-970A-B709282F9C7A")!,
                name: "TryHackMe",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "TryHackMe", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "TryHackMe", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7D49FDC0-F3F8-486A-A7ED-8784C7566616")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "79A770C9-D58A-4D10-8832-42E548430D1A")!,
                name: "Chatwork",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Chatwork", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Chatwork", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "29798D06-C48D-4343-B844-C22A07E62CE3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "79B01A50-6FCD-4B2F-8B18-CDFA989226FA")!,
                name: "Capital.com",
                issuer: ["Capital"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "74E8BF33-83D5-444D-8162-352DE6F997B9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "79E9C420-16A7-406D-8A57-B904FEA4EDAF")!,
                name: "Databox",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Databox", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Databox", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C498FF0B-4787-4FDD-B036-98E17F660479")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7A3A1048-3B40-4118-BC07-842F1E7E4135")!,
                name: "PayKassa",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "PayKassa", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "PayKassa", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7A561902-AFC2-4F28-A8D0-52BFA97557E7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7A57C8A2-5E90-4E8C-A431-1EEE05627EDA")!,
                name: "ecobee",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ecobee", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D7ECAA85-888E-4CB0-9988-C1F736776CC1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7A6118E3-B7F5-4DD7-866C-B11292704DF1")!,
                name: "Keeper Security",
                issuer: ["Keeper"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E1C6AA97-CF83-4655-B32E-FDA3D3594B27")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7A7C167A-1EB9-4733-85FA-6C1553EBCE94")!,
                name: "npm",
                issuer: ["npm"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "B5D5A209-73C3-4A9F-AB39-16F8361A2513")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7A7EA44C-B7D3-4BFD-86C5-D8D9AE76FA8B")!,
                name: "HashiCorp Vagrant Cloud",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "HashiCorp Vagrant Cloud", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "HashiCorp Vagrant Cloud", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C9DA77BD-34C1-4097-92CA-1986F677F9D5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7A864A3B-356E-4D79-B316-10FA4FACBDA6")!,
                name: "BnkToTheFuture",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BnkToTheFuture", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BnkToTheFuture", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2681B1E2-9748-4E8D-8367-D471B3F4BBEA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7AFEC234-26E4-43D6-97BC-CCB2024C180C")!,
                name: "University of Colorado Boulder",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "University of Colorado Boulder", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "University of Colorado Boulder", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "60EDA106-9A16-4E73-BE93-54E83C878983")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7B198B67-F1C5-495D-B294-5D28D3ABF0E8")!,
                name: "Kick",
                issuer: ["kick"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E78FB201-6932-4E6D-A4E5-01A42005822D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7BD710EA-F376-48D8-AD1F-A0C02ECC3037")!,
                name: "NeoGAF",
                issuer: ["NeoGAF"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "50B56493-7D97-48BF-AE85-CAFB69265FE5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7C140D3E-D5C6-4B02-BF3F-B2361A9E5AEB")!,
                name: "Codebase",
                issuer: nil,
                tags: ["ATECHMEDIA"],
                matchingRules: [.init(field: .issuer, text: "Codebase", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Codebase", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "atechmedia", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "36041399-3C58-4C4F-842F-9D65F2D25187")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7C373102-9D13-489E-9BAA-325903B550E5")!,
                name: "NiceHash Buying",
                issuer: ["NiceHash - buying"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "C8019718-56B2-406F-BF21-2ADDDA6B21FD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7C839F74-7DF8-4EA8-9E45-E9AD8AC37197")!,
                name: "Jagex",
                issuer: ["Jagex"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "BBA6E836-305E-4AB5-B02E-40E8587A10D5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7C9F6330-0A27-4367-8607-52D39B582559")!,
                name: "RealVNC",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "RealVNC", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "RealVNC", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BE585F09-751C-4874-A428-43CC0279C7F0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7CDE0945-9FEA-4ACC-9A35-58086A5379CC")!,
                name: "SocketLabs",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SocketLabs", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SocketLabs", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "CF7BDAB2-C559-4EB3-8C1B-6D4FA3F68623")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7CEA4661-C2DA-4A71-AAD2-9A3A0F236455")!,
                name: "SentinelOne",
                issuer: ["SentinelOne"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "365045B9-7D72-4DBC-A6B0-95505891E195")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7CF2DB15-6995-4629-A586-05CF8022C5E4")!,
                name: "Gatehub",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Gatehub", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Gatehub", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B8E9D5DF-6831-44B5-92B4-154FF2A66538")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7D012425-7019-4320-90A5-38963E4A022E")!,
                name: "Brave",
                issuer: ["Brave+Rewards", "Brave Rewards"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E4E7DA2F-3D8B-4686-8C2C-FD94A23864AD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7D186CCB-3417-4849-BFAB-763D8A89AA10")!,
                name: "Bill",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Bill", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Bill", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "04C5DD16-8C1D-4F7A-96DC-A83FB398F7D3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7D63FFE6-7804-435F-88FC-0ADB0E159D06")!,
                name: "Sisense Cloud Data Teams",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Sisense", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Sisense", matcher: .contains, ignoreCase: true),
.init(field: .issuer, text: "PeriscopeData", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E8AB1466-8AA3-46A2-8F20-AB2C32EA3C3A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7D64FC42-384F-44B8-B4CB-A017AFF60AE2")!,
                name: "Cronometer",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Cronometer", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Cronometer", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6DEBB665-618E-4ACA-8B2A-8DE9689C8556")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7D6C3DB8-9CA5-4AF5-99B5-1647ED525020")!,
                name: "HostUS",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "HostUS", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "HostUS", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "360D761B-6082-4C15-9370-822183A0D228")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7DC0CB8A-5B3D-43B7-8100-FC402521260C")!,
                name: "Baremetrics",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Baremetrics", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Baremetrics", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "488B76E6-FE7A-4819-8341-94B3AFA0EA35")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7DD75BC6-36A8-4ABB-B4CC-EA0C565039EF")!,
                name: "DMARC Analyzer",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "DMARC Analyzer", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "DMARC Analyzer", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "70A19F89-28F6-4A5B-B10C-91639E7BE36F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7DFA2136-3DCB-4B38-9038-7E7A39612FC3")!,
                name: "Sync",
                issuer: ["Sync"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3AA1B5AA-0F1D-41A1-8CE2-A3E76741EBB8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7E3248AB-9CC7-4213-8E46-DB814BCD98B7")!,
                name: "Squarespace",
                issuer: ["Squarespace"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "614E0E97-27E3-4DB2-9F6B-34D6027FA9D2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7E827A70-D3CE-4F09-9CE0-0B5DC5DF12DE")!,
                name: "Ravelin",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Ravelin", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Ravelin", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "93D26A7D-EFA2-477D-A995-7A78702B2836")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7E92BF90-BC72-4554-A2F4-149F3BB68D84")!,
                name: "Visual Studio Codespaces",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Visual Studio Codespaces", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Visual Studio Codespaces", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "481FC356-0C8D-4F57-AC44-3EC23338A726")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7EA96DE6-94C4-47AB-B9E0-6C96975104CA")!,
                name: "Talkdesk",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Talkdesk", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Talkdesk", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DC95D230-017F-4F27-AF4D-9916CC0C6EBA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7EC6284A-152F-4AC6-A702-95A21BFB7E02")!,
                name: "IFTTT",
                issuer: ["IFTTT"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "C5879187-E23D-4700-93F3-A6F868ACABAC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7ECDD454-63E2-4BD1-88BE-84C968D6042A")!,
                name: "Morgan Stanley",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Morgan Stanley", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Morgan Stanley", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "51790EF4-C45A-44DE-B604-BABAC395B878")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7EDD95CF-A6C3-4A4E-8D9B-90C94DE52E52")!,
                name: "Codeberg",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Codeberg", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Codeberg", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5B504195-1FAB-40AD-9892-3B90A4D94CDD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7F0CFB06-F9C4-4618-926C-924071E92D73")!,
                name: "Buda",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Buda", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Buda", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8CFA9803-BEAA-4ADC-A75A-E676F8219ADB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7F1B59E5-FD1D-4E2F-A6C3-C38C44C53C6E")!,
                name: "Digital Ocean",
                issuer: ["DigitalOcean"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "BEDB3C09-C11E-4A34-9C30-1855A5B546B8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7F5AA6CE-925C-460F-BAEA-93E027F77FE4")!,
                name: "Coinberry",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Coinberry", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Coinberry", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "210B98A2-2EFC-4562-986C-B50A7CC7C29A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7FC06C13-D09B-40DA-A740-099CC0743DA8")!,
                name: "Help Scout",
                issuer: ["Help Scout"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "DBEDB8F2-02A7-48C5-A41F-A009B989430C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "7FED7497-7F8C-47B3-80A7-BB11EE7297F3")!,
                name: "Dyn",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Dyn", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Dyn", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "00F64F47-9C10-4646-AE64-1199ABAC1727")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8003377C-5F86-441F-9CA7-0865D55A4EFE")!,
                name: "LIHKG",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "LIHKG", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "LIHKG", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "ACB4F3CF-DED5-4CD4-A351-E233E7F938BA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "802B7E13-9F6C-4546-B188-38B7ADE15B67")!,
                name: "Unstoppable Domains",
                issuer: ["unstoppabledomains.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "07A242E2-8F53-4A02-86D2-BD3D1589F0BC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "80F023AF-B7E2-4395-A700-769BF968DCF6")!,
                name: "JetBrains",
                issuer: ["JetBrains+Account", "JetBrains Account"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2143B701-156B-4D92-919F-00FA12423913")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "80FFDC39-F0BA-40A1-826A-0AFB5084F8A0")!,
                name: "Ubiquiti",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Ubiquiti", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D4933CE4-1942-416A-AEA0-97E802B741CC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "81243EC1-475C-4D34-960C-18AB2EA3F112")!,
                name: "CoinTracker",
                issuer: ["CoinTracker"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "16A18DA2-F83A-4AF4-989D-BEF141971C43")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "81893F05-1E77-4928-961D-7D14886C43DF")!,
                name: "Spotify",
                issuer: ["Spotify"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D3A469CA-8067-4E22-A044-96F15A12B5C1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "81CA01BD-B056-4693-A02F-C013E3B2A3FA")!,
                name: "Perimeter 81",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Perimeter 81", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Perimeter 81", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7065A988-32FF-4EF1-8F0E-3753CED7B739")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "81D7CA73-6785-49EC-AA3C-E2A6335A3E62")!,
                name: "Bitstamp",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Bitstamp", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Bitstamp", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "04052A42-41DE-4C1A-95C1-D4EC0867A849")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8238CD36-074E-4DAE-8FC5-C808A6C5F7B2")!,
                name: "Rewind",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Rewind", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Rewind", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D5FB7FF7-DF36-419A-BF2D-3735594AE27A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "82577EDC-F9B1-4B6F-9FB8-C242A35E2408")!,
                name: "HS Fulda",
                issuer: ["horstl"],
                tags: ["HOCHSCHULE", "FULDA"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "EC2DF1EC-7B6E-4BB7-A220-37DCCA841030")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8294B3AE-906D-48BB-8755-17A1B86CD306")!,
                name: "Refersion",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Refersion", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Refersion", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "83088ECB-4ABC-4F2F-A57F-189B43654925")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "82ADEEDE-E575-4C1B-A926-39FB6A00D1F2")!,
                name: "RamNode",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "RamNode", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "RamNode", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "28EBD542-DD92-4AD7-92F6-C25242BAA90B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "82BB2FA6-A87A-4894-9717-B1D521DBD6B1")!,
                name: "MB Connect Line",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "MB Connect Line", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "MB Connect Line", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C8208957-94DF-4511-8F53-4500EC1336ED")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "82C10485-6384-4EF9-9D41-F19FAB950B6B")!,
                name: "Rocket Beans TV",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Rocket Beans TV", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Rocket Beans TV", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7A3B7A57-3EF8-46A0-B8BA-70BC43E14329")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "82D90864-A1F7-4CB1-B258-E610EBFEB13F")!,
                name: "SpaceHey",
                issuer: ["SpaceHey"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "98CEC66B-0047-4A4F-B948-DFAA94005891")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "82DFFA18-98AB-469B-A585-0F5ED9990B9B")!,
                name: "NVIDIA",
                issuer: ["NVIDIA"],
                tags: ["GEFORCE"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "8B295BB2-91CC-4F19-B173-16DF95E228C3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "82FD1BFE-64CF-446D-ACEA-5876D821C5D0")!,
                name: "Open Collective",
                issuer: ["Open Collective"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "15A8549B-2AC7-497E-A6AE-11378AE18119")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "830020A7-2513-488C-8A7C-7E20AA9578D2")!,
                name: "Alterdice",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Alterdice", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Alterdice", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "CD165431-53B8-4936-B8EA-CBD8FA1E8C96")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8393C2BD-D496-4432-890D-A7477F176E08")!,
                name: "CoinRemitter",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CoinRemitter", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CoinRemitter", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F9E1ED47-E280-4BA5-A00C-4D017A124D78")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "83A6DF63-B742-4675-AFDA-9D230C192E10")!,
                name: "Frontify",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Frontify", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Frontify", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D5A42783-5007-453D-B27C-18BEDE240CEA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "840D21E0-D20D-4067-B6C7-2B96AAE85579")!,
                name: "Docusign",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Docusign", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Docusign", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6C5884C0-7C72-4C2B-896D-3481CFF57CC8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "84662035-1E65-4CDE-9741-EFB1E83A5EF2")!,
                name: "Unleashed Inventory",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Unleashed Inventory", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Unleashed Inventory", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "305B1E9C-2FD3-4B84-B302-8C1BEC2138A9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "84EDAEAF-9168-45FF-96D9-003228D3DD8C")!,
                name: "Formstack",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Formstack", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Formstack", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "785C2B05-B748-468D-A125-241260F12AC8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "84F63808-CFB8-4AE5-A830-E6F70AB02DAE")!,
                name: "EuroDNS",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "EuroDNS", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "EuroDNS", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "98FEFB13-BEB0-4E1C-B2D3-E6ACC0EC5AEC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "85296295-6A06-4E0C-BD60-937C805A6C1F")!,
                name: "HashiCorp Cloud Platform",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "hashicorp-cloud", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "hashicorp-cloud", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DC569788-3DEF-4FBC-8238-F5BC61084A5B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8545BF3B-1BBE-4ECB-A623-CFDFE5F3FC38")!,
                name: "Firefox",
                issuer: ["Firefox"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "ABE5DDB6-80C8-4B31-8FBB-345E0D81160B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "85AD45BE-DA07-4B6D-B373-8ACBE7148C37")!,
                name: "Buffer",
                issuer: ["Buffer"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2C9EE610-C4D6-4457-8834-F7C538A7F163")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "86006813-EE18-4AE6-A87B-5347820B0519")!,
                name: "SeaTable",
                issuer: ["seatable.io"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "028279C4-92E4-47D1-AC5D-66E1618BD244")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "868894D6-32E4-45EC-9C9E-10D8806C76F3")!,
                name: "Veem",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Veem", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Veem", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2093372C-4F33-4CB3-8133-B8F1CA9E098E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "868F0D51-8916-4807-ACC0-8D4EE45F7DB1")!,
                name: "Hostiso",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Hostiso", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Hostiso", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FBD1485B-CA8C-41E7-92E1-7EF469B99E93")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8698B2B9-A7E0-4BC7-8FFE-AD28EE0F7F08")!,
                name: "IBM Cloud",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "IBM Cloud", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "IBM Cloud", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7D447F66-7E02-428B-9E36-68F7C958580C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "87243AA3-1FA8-4263-B6B1-DC4659BB5AEF")!,
                name: "GM",
                issuer: ["General Motors Security Team"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A2B78D57-46C7-49F9-9D28-0F3C58E35BE5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "873024AD-7FF9-4C17-B359-D741B8E6BBD5")!,
                name: "Ripe NCC",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Ripe NCC", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Ripe NCC", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0DD85AEB-012F-4D86-9EC5-80789EF60055")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "87628E28-8D71-4D26-9A81-84DA98F3C128")!,
                name: "Wise",
                issuer: ["Wise"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "B489E126-7964-4D8F-B3B9-8FC5E740710D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "87B50366-EEBF-4F21-A268-1A1758E33C13")!,
                name: "StubHub",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "StubHub", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "StubHub", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3156E052-2C4A-409F-969F-3B2A0A8DEA23")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "881E237F-37A2-41E7-87EF-9C21684618F3")!,
                name: "AutoTask",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "AutoTask", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "AutoTask", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7D8C75FF-A63E-49FD-B225-E3290549F4ED")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "882C9046-B11F-4F4F-9F66-7095202A03A7")!,
                name: "RoboForm",
                issuer: ["RoboForm"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "B541B6BB-1921-418B-91C8-AD911062B736")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "882C9D00-FBD8-48B7-930D-41F503966A4F")!,
                name: "Zimbra",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Zimbra", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Zimbra", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "884CF569-FB14-4C47-828C-2F9F88377CB7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "886B5652-AD19-4F60-AE39-B5FA1A540794")!,
                name: "UW Credit Union",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "UW Credit Union", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "UW Credit Union", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "732E06EF-1BC9-48DC-9CD7-4F0EE9B0D1D4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "889BB777-71EE-45D8-9C95-4253EEE6BB89")!,
                name: "BKEX",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BKEX", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BKEX", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C167C7D1-EAA7-4578-AB63-1541330A3137")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "88A53CDC-9701-4441-9AFA-03E1E23CC9EF")!,
                name: "Plutus",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Plutus", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Plutus", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E4241DFF-21A0-4990-9561-174DB4BAB356")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8952184D-8267-4BBA-9643-8519DE01B3DA")!,
                name: "When I Work",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "When I Work", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "When I Work", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "58535F61-5B07-44E5-B2C6-62C45D6B484B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "89706ECC-AF41-42AB-9D05-98CE63EF4184")!,
                name: "Bohemia Interactive",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Bohemia", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Bohemia", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5B7648E2-C203-4054-AC9F-2B2BEC0590B1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "897A4125-1656-4E2F-A6EC-90294AA7D59E")!,
                name: "Fasthosts",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Fasthosts", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Fasthosts", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F3E7BDEE-DBD0-40E8-A65A-789F3962D417")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "89D4DA87-F110-4A4F-862A-051032180536")!,
                name: "Tesla",
                issuer: ["Tesla"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7221BAD0-F0DE-431F-9C16-81ACC5049D6D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "89E6EA49-A9AD-46E8-85A3-391B5829109D")!,
                name: "Hostens",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Hostens", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Hostens", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0F84823E-E705-427A-B0C2-EE9315BFD1A2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "89EFCC2D-52F4-4AC3-988D-5D7F3B3CD0A7")!,
                name: "2FAS",
                issuer: ["2FAS", "Estadoz"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A5B3FB65-4EC5-43E6-8EC1-49E24CA9E7AD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8A6E8DDE-9546-4E62-A30A-143DEE285D79")!,
                name: "WordPress",
                issuer: ["WordPress.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "708DF726-FB8B-4C01-8990-F2DA0CD33839")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8AB8494B-E553-46DE-B3E2-60B3B888C51F")!,
                name: "Quidax",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Quidax", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Quidax", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "99F0DA7E-0EA7-4845-9A79-D319B2D574C6")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8ABDB27C-6727-44EC-88B3-CB155D383334")!,
                name: "Versio",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Versio", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Versio", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "85AE1A2B-5E4A-4ED7-87A6-58346E6894AA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8B2853FD-5CBD-4239-904E-B48153969B64")!,
                name: "River Financial",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "River Financial", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "River Financial", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "92C353CA-A0A3-4D99-AA67-5579D14B70F8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8B2CD893-4A24-4AAF-89B6-6E22B2C9EE6F")!,
                name: "TransIP",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "TransIP", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "TransIP", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C19027DA-45A2-4E12-81F9-A7CD7E848F31")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8B3611E7-1C7B-459E-8FC5-97522ED4DDD2")!,
                name: "Wyre",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Wyre", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Wyre", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "ECB3323C-FA3B-4901-A334-F714309B5EAB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8BA7B1EB-C080-444D-815F-BF05CB909D00")!,
                name: "Termius",
                issuer: ["Termius"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "4436B171-7E38-4AD8-9E5F-D0D5CE411EB4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8BF276FA-695E-4B11-BD27-42DB60A8B074")!,
                name: "Laravel Forge",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Laravel Forge", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Laravel Forge", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "75314CBA-050F-4427-B70C-4DF66B568D7E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8BF52F46-80C9-45B2-B29D-C6CA8C08EEA8")!,
                name: "Evernote",
                issuer: ["Evernote"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3B34F154-62DB-45D5-A668-1FC7524FC06A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8C7591C7-C5B1-48AD-9B63-3ED394D48280")!,
                name: "TaxBit",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "TaxBit", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "TaxBit", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "49AC9022-B8ED-4911-B7A2-8D49712C935B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8C956E25-5890-4625-8599-C478AABF8857")!,
                name: "Workplace",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Workplace", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Workplace", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "CC95AE95-5773-4BCF-83D2-DCCAC6EBCC02")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8CAD6C46-8DFB-4ACE-88D3-F3F231DCEC7B")!,
                name: "Capcom ID",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Capcom ID", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Capcom ID", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3832C307-800C-42C5-A32F-8DCE33A46EEF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8CCD201D-A371-4123-A84F-70348CA9336C")!,
                name: "Toronto Metropolitan University",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Toronto Metropolitan University", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Toronto Metropolitan University", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "757EA6CD-4B92-4548-ACB7-E0B94D659F38")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8CD97A5C-E890-47EE-8597-8095BBA4D400")!,
                name: "Bittrex",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Bittrex", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "672C798A-3C40-4EB3-B489-DE0BC52D20A9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8CDA437E-8759-4571-B0C9-9BEE964FBD64")!,
                name: "Standard Notes",
                issuer: ["Standard Notes"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "37799941-A47D-4B12-86F1-FDDDDA28A05F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8CF11E76-9989-41A4-B623-0C6BAD678645")!,
                name: "HEY",
                issuer: ["HEY"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "FBC8DA17-9128-430F-B86B-8AA5E735A299")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8D21146D-684E-47FE-8658-3B11CFD11138")!,
                name: "Bitdefender",
                issuer: ["Bitdefender"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "394AA3FC-2818-45F2-8F0F-612856B2AB82")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8D28C57C-2344-45E4-AA5B-FC41D0D8578C")!,
                name: "Unfuddle STACK",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Unfuddle STACK", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Unfuddle STACK", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "184C88AE-3399-4432-B895-5A461111F6CD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8D2B7CFD-2D6E-4A82-AF14-4D60924ABF84")!,
                name: "Skrill",
                issuer: ["Skrill"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "6F8B55B6-D7BB-4691-BDA2-2B1DE39FB448")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8D54EA9F-0471-4AE1-90CD-B819AECF5C74")!,
                name: "Recruitee",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Recruitee", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Recruitee", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4AEA03E2-9AF0-41C4-A85B-EEE56EF8F912")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8D8CD023-32C3-41D7-AFA2-1434B7B81A68")!,
                name: "Discourse",
                issuer: ["Discourse"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2F5845BF-7788-4B08-9BC8-A889D38FA6F6")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8DAA3100-D368-422B-92E4-11F305D23B20")!,
                name: "eclincher",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "eclincher", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "eclincher", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F9A595CF-0937-43BD-99B5-0911D742DA2E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8DE8285E-B2BC-44ED-86B9-9EFD3C58A2B6")!,
                name: "Bitso",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Bitso", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Bitso", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C75ACE06-CCAE-4C43-A58A-BAECF0E1EF4F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8E341159-38CE-434D-928A-D76637C9B827")!,
                name: "Terraform",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Terraform", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "439CA1BC-C64A-4BC6-85C2-296815BA76F3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8E344EE0-9350-45E4-B6EF-4F7C06BA3798")!,
                name: "OPSkins",
                issuer: ["OPSkins"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "0A557467-29DE-4967-A905-2351F074D3D8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8E426C3B-4AD0-4ED7-8520-CC0BB4120BB1")!,
                name: "Algolia",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Algolia", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Algolia", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F40B252A-106C-4353-A4DA-5D861DC657DD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8E6B9EEA-CE00-4371-884A-B540B3467950")!,
                name: "Figma",
                issuer: ["Figma"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3F24378A-AB65-4034-AE7F-B13F624DE766")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8E806660-1246-4BEB-BCA4-46B2A1254A58")!,
                name: "Guideline",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Guideline", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Guideline", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "428E7DFB-928C-46D3-95D1-A32B28A8B62B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8F097659-0B9C-4209-9C47-9F9A64BA510A")!,
                name: "Register365",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Register365", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Register365", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D96EDB81-4E1A-433F-9304-30C145391D40")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8F3BE8B1-BDD9-407A-8AD1-E169E291927E")!,
                name: "Mos.ru",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Mos.ru", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Mos.ru", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2DA45F6A-9DEF-458B-8FFD-0F9E97481A40")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8F4C7951-526E-49B9-8996-28D65D15ED47")!,
                name: "Wyze",
                issuer: ["Wyze"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "233AF9EA-D8CB-4586-863E-819CA7C46EAE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8F9FC051-5D1E-42D5-929D-1E72A9F85855")!,
                name: "Tauros",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Tauros", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Tauros", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "557F8079-C3D4-429C-8FE2-1C126557EC3C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "8FFD524B-2986-4FD6-B7F7-418DCC3D8F9F")!,
                name: "Caspio",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Caspio", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Caspio", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A5FCAEE7-01C4-4ACE-AA62-D8D94E6823C7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9017AD1F-3D41-4CF9-A4F1-CBE4B3D9AB68")!,
                name: "Teamwork",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Teamwork", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Teamwork", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "368EA9B5-46B2-46DB-9440-EDDB84C65449")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "901DB5C9-A04B-4FD9-B4B2-40809967A777")!,
                name: "Statuspage",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Statuspage", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Statuspage", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5258781D-F346-437C-A72F-C4F9D4ABDC06")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "903C215E-CB1D-448B-AB92-7CDEF3361C1B")!,
                name: "Mattermost",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Mattermost", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Mattermost", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4AB1A53F-7CA6-45BC-9DB9-141A88F2A6AD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "90660E86-1B56-47AE-B89E-B8EE6F544AD9")!,
                name: "Pocketsmith",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Pocketsmith", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Pocketsmith", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "86DB4634-C7D0-4D75-AD4D-24F74464EB57")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "906CDFCD-6C92-4EB1-A0CA-963EBC867489")!,
                name: "eUKhost",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "eUKhost", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "eUKhost", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "92200B10-A81B-4D42-92AA-5B5855A89BD5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "90A4ED41-A143-4681-A324-B57F21683061")!,
                name: "Quickbooks Online",
                issuer: nil,
                tags: ["INTUIT"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "DBCCF2F4-2073-479C-A655-FE19DAF4AC2C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "912FC163-7EFD-4D1E-8795-F380A12C2C71")!,
                name: "StormGain",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "StormGain", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "StormGain", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "CDCA2DF5-EF53-4EB1-BB47-D9D3CC9CFFDA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "921C218F-9AA4-4191-A638-DD5CB1A5A19A")!,
                name: "TorGuard",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "TorGuard", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "TorGuard", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D31B0911-28CE-4F5F-9D38-A9A0757548A4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "923C55FC-7ECA-4027-B853-C97955B356CC")!,
                name: "Atlantiss",
                issuer: ["Atlantiss"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3DB5E1E5-6DCC-427C-91A7-08B31ED3D3BE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "924F8361-2435-41FE-8070-B2F6B105B042")!,
                name: "LinkedIn",
                issuer: ["LinkedIn"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "843DA9A7-A44A-42C6-9FDD-2A723A7D05D7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "925C70CA-5442-4411-939E-D0AE4775C182")!,
                name: "Nozbe Teams",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Nozbe Teams", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Nozbe Teams", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C49414B9-783E-4B67-9521-4CE8A5A36D48")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "927E82A1-CF11-4C5B-AB11-B76B56681FA7")!,
                name: "VRChat",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "VRChat", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "VRChat", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6EBBF091-D242-4155-BF89-4DF4A4B37175")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "928F0793-73AB-4C92-A4C1-FDECE77F7091")!,
                name: "TaxDome",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "TaxDome", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "TaxDome", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4FB91386-8652-421D-A63E-8593D28F72E1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "92ACFFB9-C266-4117-BFBE-1678642B6DBB")!,
                name: "InterServer",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "InterServer", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "InterServer", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F89517FE-02F5-4AA0-9545-E932B978C22A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "92DB112E-82E3-4890-AC4B-922B498BF65D")!,
                name: "DeployHQ",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "DeployHQ", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "DeployHQ", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6F182AB5-DCA8-4D55-8504-EDCBA30B3F88")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "93EB1618-49E2-415D-82B6-269CF16DC1E0")!,
                name: "One.com",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "One.com", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "One.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F3015BB9-58BB-4FBD-BC27-E9A9C134117F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9459690A-8958-4FD9-AE4C-D9B34869682B")!,
                name: "ScaleGrid",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ScaleGrid", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ScaleGrid", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "307FFB85-AE45-4C00-A954-C12AF9EF46F3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "945F09B7-B3AC-46D2-8E35-88CF8637B17C")!,
                name: "omg.lol",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "omg.lol", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "omg.lol", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "66E5C2D4-6186-42DC-9EC8-B33BA7D7789E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "946154C5-1BB5-4896-80BA-527F58E48034")!,
                name: "Pleo",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Pleo", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Pleo", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "96CB4B6F-8F6F-4E23-9C61-CE21EAE487E0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "946CF1E6-DEDB-4994-922B-62B0D73B17C1")!,
                name: "Parimatch",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Parimatch", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Parimatch", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0AB73B7F-939E-4660-B619-8C50E3AD8CF5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "94712FF8-BBE1-41BC-8B81-0F0395463E88")!,
                name: "Login.gov",
                issuer: ["Login.gov"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "8AD7697B-6782-47E4-A9FB-8E07499825BA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9478A1E5-5FDB-4E1F-B3AD-787A32528FF0")!,
                name: "BTC BOX",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BTC BOX", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BTC BOX", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A770E5E7-7920-4D7B-92D8-2BA9594F3B5E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "950BC870-769C-4610-9B38-6AD6222F0E88")!,
                name: "T. Rowe Price",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "T. Rowe Price", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "T. Rowe Price", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4A45ADA8-CC81-40E0-A277-C692EFB0326D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9570B3FB-6DE9-4A2B-9375-CB9338F19CF2")!,
                name: "BitGo",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BitGo", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BitGo", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "ED1E3140-E59C-4606-AD92-5271397D2CDA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "95FEC776-13F1-4315-B66E-4880BA15E7B4")!,
                name: "Moniker",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Moniker", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Moniker", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "320BC9A4-D685-43F0-A9DF-CD7865763CAC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "96234B0E-7412-4D26-BBB5-1A00D0DE1E1F")!,
                name: "Mastodon",
                issuer: nil,
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "BD364131-1FEC-4597-B606-1746DED21B09")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "964358CA-60E7-4613-8A33-9B31C53B79A6")!,
                name: "CryptoMKT",
                issuer: ["www.cryptomkt.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "0D065BBA-9C80-4E7F-8AF2-F7D3E31477CE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "96DB7CBA-3226-45D6-8B34-2D081B860CD6")!,
                name: "Asana",
                issuer: ["Asana"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2388F03A-9E91-4462-917F-70D86678B002")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9703B1B3-9942-4789-80E3-A8EF8C52DAAD")!,
                name: "Autodesk",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Autodesk", matcher: .equals, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EE3F948D-DE04-4D92-9899-949B0B193A1D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9746650C-0DC6-438B-982F-5C38DC72CCE1")!,
                name: "Binance",
                issuer: ["Binance.com", "BinanceUS"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E547C093-2B09-4196-B69B-72E77EF1ED9C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "97657A82-03B2-4267-9D75-90FACB792666")!,
                name: "123 Form Builder",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "123 Form Builder", matcher: .contains, ignoreCase: true),
.init(field: .issuer, text: "123FormBuilder", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "123 Form Builder", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "123FormBuilder", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DFB1C4BF-9AD6-4CB9-A284-68C9DCD34645")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9785C37B-1D7A-477B-AB22-65E3CCD50608")!,
                name: "Contabo",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Contabo", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Contabo", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5199F3AE-DD15-457F-A14A-A9533DB1C1E4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "97999CA3-977B-47A6-AD23-442640E8AA52")!,
                name: "CloudAMQP",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CloudAMQP", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CloudAMQP", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4B418342-0985-4CDA-915F-56AA6107C7A1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "97B7C609-EDCE-400D-B0CE-A1894AC4305B")!,
                name: "OpenVPN",
                issuer: ["OpenVPN"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "91A3EDA0-5906-4BA9-BA03-5C6C584C55AB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "97DAC6D8-F6E9-467A-8341-44514A7A04B6")!,
                name: "Studio Ninja",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Studio Ninja", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Studio Ninja", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "67378F92-09C0-4113-8C7E-958BDA6EA387")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "97DCDED8-02B9-42A4-AF3B-F5D414B45D05")!,
                name: "Linus Tech Tips",
                issuer: ["Linus Tech Tips"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "C9A5CA56-05D0-4F2A-A572-DA373E953301")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "97FF87F6-F264-449B-A946-CEDA22CB7CFA")!,
                name: "OPNsense",
                issuer: nil,
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "6A0FB3A0-7CB3-4C8E-8EF2-14D6AE162B85")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "98C9B128-D065-4946-A838-07DFA68F1669")!,
                name: "DeinServerHost",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "DeinServerHost", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "94159DE2-2211-4F21-AE47-221CC364A31E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "98CB606B-1B2E-4DF5-B46D-50DA2184D925")!,
                name: "PlanetHoster",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "PlanetHoster", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "PlanetHoster", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3C9C902E-8B4D-4187-A340-1C7C82E34144")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "992BE346-7BD6-4389-9EFD-8DFAB6018452")!,
                name: "Dropbox Sign",
                issuer: ["HelloSign"],
                tags: ["HELLO"],
                matchingRules: [.init(field: .issuer, text: "Dropbox Sign", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Dropbox Sign", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BE69EEEB-4DF0-47C8-804A-B8808552F592")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9A12CC0D-36F0-4570-8DD3-F193D0A1E286")!,
                name: "HostMonster",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "HostMonster", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "HostMonster", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2BB2F1A6-F9E8-4297-A35E-B83D1D58E98A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9A24D1CA-DA74-4F81-88AE-D3D174300E30")!,
                name: "AWS",
                issuer: ["Amazon Web Services"],
                tags: ["AMAZON", "WEB", "SERVICES"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D3B86FF6-7DDA-40CC-A63E-C3DB426460B7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9A6E29D3-54BE-4793-AF01-7D9F1CA4F941")!,
                name: "Allegro",
                issuer: ["Allegro"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "163F6301-123D-4925-8058-07B04146B750")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9AA4D939-3FD7-4F4F-A046-58A5662A018E")!,
                name: "EasyDMARC",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "EasyDMARC", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "EasyDMARC", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5B447E9E-E23F-4B60-BC6D-888B7574EF40")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9B50CB0F-8A65-44EF-B36E-94F3A8BF6E9A")!,
                name: "Shift4Shop",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Shift4Shop", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Shift4Shop", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "42D488E0-F71C-4A69-B375-614C53955583")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9BB3D16F-9D15-4DE4-90AF-A61233D7E799")!,
                name: "MS To-Do",
                issuer: nil,
                tags: ["MICROSOFT"],
                matchingRules: [.init(field: .issuer, text: "Microsoft To-Do", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Microsoft To-Do", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BD965E39-9884-4880-8E5A-A200A8B461C1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9BBFEEA9-6B58-4E8A-A00D-B1468519E21D")!,
                name: "Workato",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Workato", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Workato", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "68AD5E41-8A75-46F6-B359-47475B8A6038")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9BCC287D-63BA-48EF-81F2-DD011019EDBA")!,
                name: "TicketSource",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "TicketSource", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "TicketSource", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4F464DB6-401C-446A-B7D5-9F58A9C8A4C1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9BEF67A1-D622-4748-AB5B-E96E90F7998C")!,
                name: "Avanza",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Avanza", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Avanza", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DE2EAD78-ADD8-450B-A2FF-B7A84070C66B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9C1CB88F-2444-4F0D-9822-F6D2AFDC88E8")!,
                name: "GrowingIO",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "GrowingIO", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "GrowingIO", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DF2E67AF-C0D4-4DF7-9D14-69126C64B63B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9C533EF6-9F9A-485C-8809-3BF908C52AA4")!,
                name: "bugcrowd",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "bugcrowd", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "bugcrowd", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EC70005A-F837-48BA-9117-0FE03E7BB81F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9C5D6C41-D71E-4A0D-84AB-831AD87E2C5A")!,
                name: "Unbounce",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Unbounce", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Unbounce", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "376A6BD3-1449-4244-840D-D08D5C3ACAAE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9CA2CE09-7ED9-4C96-88E7-33274EAC15BB")!,
                name: "Leaseweb",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Leaseweb", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Leaseweb", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FCDC5AD7-184B-4332-8E15-53315D459519")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9CEFB4C2-714C-4270-ACF9-7E48BF8A890C")!,
                name: "Moqups",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Moqups", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Moqups", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E37A7BED-C7E7-40FD-99EF-4D2D214DA6A8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9D099211-C570-47B6-9D18-E6B72D250CD2")!,
                name: "CoinGate",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CoinGate", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CoinGate", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4F1C6AAB-1F7C-4D17-914C-75998B04BEAD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9DA37985-6D4E-4E30-A2CC-449BA401D8CF")!,
                name: "Opera",
                issuer: ["auth.opera.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7D835694-5335-41C1-985D-EEC3A1836FEE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9DC2A1FD-7A2F-4E9E-8141-16D343F09009")!,
                name: "UKFast",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "UKFast", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "UKFast", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "423805D9-A642-4B2F-BF9A-7720449F5A10")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9DEBD9D2-1FCF-4912-ABDF-EF2F641806A0")!,
                name: "Nominet",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Nominet", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Nominet", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C103676D-9CB5-4D54-86C2-341C2651ED5B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9DF06E77-CCC5-4B90-9486-C5F849807410")!,
                name: "Uniregistry",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Uniregistry", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Uniregistry", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0153A9B6-BD72-4984-82A3-37C7B540B166")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9DF3F288-9201-477C-9B6F-6A8163F5B980")!,
                name: "Bitbucket",
                issuer: ["Bitbucket"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "B2B3F344-5CBD-439F-B0C0-CEFCAD6A21F5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9E13F24A-774D-4D11-B3EA-B688CF3FF82C")!,
                name: "Gamdom",
                issuer: ["gamdom.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "72F23523-5859-418B-8B99-420062258BD7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9E3718C1-48AA-41FA-B3BB-1650DEF9B521")!,
                name: "Mapbox",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Mapbox", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Mapbox", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EFE0E629-2549-4692-8E03-D082FC400A38")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9E5A263D-8875-49BC-BE88-126323AABADD")!,
                name: "Detectify",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Detectify", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Detectify", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FEBAA266-330A-41F4-8B19-F6023736DB98")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9E654A3A-DE47-4BFE-8014-1680FCE77452")!,
                name: "Hotbit",
                issuer: ["HOTBIT"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "6BB5522A-8979-4A04-8C72-A59552268A23")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9EE1CD91-D80E-4322-B896-A2415DD077B0")!,
                name: "Alchemer",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Alchemer", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Alchemer", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E9812A04-3AB7-4039-9207-33E52FC5C92B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9F1BCFE9-A951-4370-AFCD-ACEA35A0243B")!,
                name: "Linode",
                issuer: ["Linode"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "DB619E49-9393-4CF5-808E-354157D98325")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9F4E2BC6-6B23-4E09-92F5-203165EC76DF")!,
                name: "TurboTax",
                issuer: nil,
                tags: ["INTUIT"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "1CF1197B-940E-4AB3-8FBB-261B6CB1D464")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9F8CDE87-CDBE-4551-B2DE-7829A2FE9F42")!,
                name: "ActiveCampaign",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ActiveCampaign", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ActiveCampaign", matcher: .contains, ignoreCase: true),
.init(field: .issuer, text: "Active Campaign", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Active Campaign", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D77F98D5-D64C-4237-B343-A50219BC5226")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "9FA4FA21-EE4F-4049-97BC-5E43B93ECF86")!,
                name: "Workflowy",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Workflowy", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Workflowy", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2EF26634-EF90-491E-A548-4E1F52A7FBD5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A019E22A-FBB3-48B9-B22A-FB076410A5E3")!,
                name: "State Department Federal Credit Union",
                issuer: nil,
                tags: ["SDFCU"],
                matchingRules: [.init(field: .issuer, text: "State Department Federal Credit Union", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "State Department Federal Credit Union", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C00D5B8D-8B3B-48A6-830C-798BF722759A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A074D141-F92E-4521-971F-63304A45FEDF")!,
                name: "Skiff",
                issuer: ["Skiff"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "75595AD0-66C7-4BFC-A47D-99C001A4DF12")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A11A5E88-2D35-46EB-BE74-93FA5A206A17")!,
                name: "Finary",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Finary", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Finary", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "ED111ECB-EEF4-40C2-9EFA-6068957D3A55")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A174BBBA-0FF5-4827-ACFB-AB661E5A59B9")!,
                name: "Pluralsight",
                issuer: ["Pluralsight"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "AB7D3BEE-5A6B-4C0A-BED5-EFCB5E9EB61F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A17D84E3-2644-4400-A6BB-5A5AF797677F")!,
                name: "NAGA",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "NAGA", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "NAGA", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1B1AEFD6-ACB6-4A4D-8C71-85CAE9896816")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A1AB7203-DE30-442E-A360-20A2AE8E2F69")!,
                name: "Klaviyo",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Klaviyo", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Klaviyo", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E5D6B9E5-EEC7-44F5-AF2C-DA4F85B3BE2D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A1E831A2-8D82-4E55-A3A5-CF12A468FA4A")!,
                name: "Datto",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Datto", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Datto", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1BFDAB50-F6B4-40E0-B819-93F876EBA5B8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A2987AB4-AC5C-48CE-863C-D3D3D1220FDB")!,
                name: "Twitter",
                issuer: ["Twitter"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "9889F776-434D-46AB-97EE-EF2AD88FE615")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A36D8440-359E-4DD4-AB13-31F43C77A7FD")!,
                name: "BuiltWith",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BuiltWith", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BuiltWith", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EC674F0F-9069-4B64-97FE-B56EFB2B8693")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A36F94B7-A60A-409C-9E4A-EDCBE0D0C2DA")!,
                name: "CoinSmart",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CoinSmart", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CoinSmart", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "165AB569-C5F1-417B-862D-DE6D9D1D0429")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A3969BDA-B6CA-47C3-9512-4BE3C7A174E8")!,
                name: "CDN77",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CDN77", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CDN77", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6D430CB8-8891-4504-9E1E-81CE542AC99E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A3C86B49-FF27-4072-BC93-FF7B80D0B380")!,
                name: "Front App",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Front App", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Front App", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "248F1F1F-5270-40A2-950C-7DC4A4A21722")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A3D0F49A-23ED-4C1D-B1A6-47232F4E624D")!,
                name: "Monex",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Monex", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Monex", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D2C71713-F6F1-4DA0-A5F6-F7AD54E8B2A9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A3F0564C-F03F-4AFA-9443-E75426B3645D")!,
                name: "Lokalise",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Lokalise", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Lokalise", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F977F700-F586-4C5E-8A31-62B940100B96")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A42D9F55-C8F8-409D-93A8-D2A8CB23E54D")!,
                name: "RightCapital",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "RightCapital", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "RightCapital", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "009C2B57-CAF0-4DBE-A129-8AD8A9D1DF7B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A44366C0-42F8-4164-8880-6E1B52634293")!,
                name: "Passbolt",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Passbolt", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0AA806DB-7B34-4387-91BD-08D4547B0B4A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A45A6C25-FC03-48C6-A2D5-C160C3D51F45")!,
                name: "NO-IP",
                issuer: ["noip.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "6BEF5540-2E6D-4125-90AC-88905AE42FC3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A4A5DBE8-2109-41EE-9FE9-1EFEC46346B6")!,
                name: "GameMaker",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "GameMaker", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "GameMaker", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "708B76E7-6713-4C7B-9BC1-ED8BCE6360CB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A5015CDA-7770-4CF9-A1B5-AFB955BA719D")!,
                name: "Traderie",
                issuer: ["Traderie"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5978BDE2-1244-481D-9D4C-061C531F9081")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A544DEDE-602A-4B3B-B8DD-4FF63F49D1EE")!,
                name: "DNSMadeEasy",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "dnsmadeeasy.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E8A6AE67-564C-4686-9078-5607B7B7F225")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A566F7D3-7C9C-4DFB-AB4E-2C40E4517184")!,
                name: "Tilaa",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Tilaa", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Tilaa", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2788457B-F9A1-45F3-B453-18DE6A706464")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A5DCC1F5-59BE-4FDB-AC4F-23363130F6C6")!,
                name: "Balena",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Balena", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Balena", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0A2FB648-547D-4295-8395-9541530E5FCA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A5ED7742-3798-40F6-AFFC-8BB459AF80EA")!,
                name: "Uphold",
                issuer: ["Uphold"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "4A3BF3C0-68C8-4AA7-809C-C3962EA0C564")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A657EDFE-7D07-4183-A409-0E6F7A0E0564")!,
                name: "WePay",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "WePay", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "WePay", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D75A84BB-3750-4F77-A889-1DE5A743771F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A6625835-3C28-42CD-820D-2EBCC08320D0")!,
                name: "Patreon",
                issuer: ["Patreon"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2BFE0CFC-B557-4F2D-988C-72015254B671")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A68BC354-0466-4FD8-BCBF-D9998B694867")!,
                name: "LaunchDarkly",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "LaunchDarkly", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "LaunchDarkly", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "03C68D8E-D646-48AA-8D7D-904FCC13C61A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A691DF14-874D-4250-8180-48D05CDB2989")!,
                name: "Heap",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Heap", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Heap", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "9973600D-8DA5-4A1D-85A3-11928FD80984")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A69987EF-9334-4BEE-ADFA-EE94DDA00C65")!,
                name: "VPS Server",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "VPS Server", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "VPS Server", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D82BD671-E134-4C9B-B121-9BCD1005213E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A7354BAA-0A57-4003-B0C8-85CD7A19F32F")!,
                name: "Paxos",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Paxos", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Paxos", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F2DF791B-6E80-47AA-895D-412748D2A83F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A7516A9C-2DBD-4ABA-8E9D-50A6D8815C7D")!,
                name: "Fly",
                issuer: ["Fly.io"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "75D24465-2516-4598-A709-D28BBC17337B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A7579FCC-EE5E-4B90-85C3-DAAC271A5CF2")!,
                name: "Cloze",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Cloze", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Cloze", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5AC41237-810B-4CC1-8AD2-1C27AD35BB3A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A770E137-11EC-4785-924C-2CDA2BAE0495")!,
                name: "Whimsical",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Whimsical", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Whimsical", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3DB07FF5-3A8F-4119-8266-BEFCD9059469")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A7CF31A1-1B33-4456-8C88-567E100B4B9C")!,
                name: "Nifty",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Nifty", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Nifty", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "254F7C6B-3C1A-4237-A231-487022DF0DC4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A85B7921-5DA3-43AF-BA05-9AAC1FC9A6D4")!,
                name: "DX Email PRO",
                issuer: ["DX Email PRO"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "BEBE73C4-8079-42AC-B735-5B991367CA25")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A87E9253-5BA7-43EF-98A6-5FAD3F0920C5")!,
                name: "UK2",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "UK2", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "UK2", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5F2C6C03-047F-4029-89BF-BBDC31B6BE76")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A916B5E1-627B-4E23-B690-81B33C4B701A")!,
                name: "34SP.com",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "34SP", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "34SP", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "87FFDB0E-82AA-4571-99E1-C2506B4267DB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "A9F9DEEB-C0DB-447C-9316-0BCC5C17D81D")!,
                name: "OKX",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "OKX.com", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "40DD3926-F325-4421-883A-F9051B0DCF3E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "AA38D4C4-E405-4E28-8CD3-E8B0ECAE366F")!,
                name: "NiceHash",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "NiceHash", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "NiceHash", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D7FF6819-7733-4231-8671-29C3C3B51030")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "AAE63726-A3FE-4BA9-ABE1-173F1BFB590F")!,
                name: "ImmobilienScout24",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ImmobilienScout24", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ImmobilienScout24", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "93355C73-A8E2-4C4B-9BB4-E15525EC3047")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "AAF4136B-6489-4E34-BA8D-BA2377BC61EE")!,
                name: "FreeAgent",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "FreeAgent", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "FreeAgent", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EB504A22-6E98-4B51-93DA-E3B9E59F844E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "AB5170D5-098B-4D87-A248-64BADB66CFB3")!,
                name: "Parsec",
                issuer: ["Parsec"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A850B2E8-1F72-4A6E-85F7-9023BC57C75F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "ABFD0524-AD3A-455C-9FF1-E2894C68C2E5")!,
                name: "BambooHR",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BambooHR", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BambooHR", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6D47EF7E-BC56-4358-BDAC-45A7D4FFCE2F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "AC38233E-F4B3-47BA-B045-9CF8A6619749")!,
                name: "Olymp Trade",
                issuer: ["Olymp Trade"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7BEE53FC-F205-4A92-8984-CA0A11A9FE92")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "AC419CFC-9BA0-4E30-9CDE-236EFD67509B")!,
                name: "OMGServ",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "OMGServ", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "OMGServ", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8F5297C8-1FE6-4DBF-8861-63FE69E63F1E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "AC8C167D-82E0-4D49-AB51-7E73B96A7789")!,
                name: "Bitrix24",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Bitrix24", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Bitrix24", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5B1C87EC-4B04-4649-B09D-F59CE1AC0942")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "ACC35462-61B8-4573-B638-24466631D31F")!,
                name: "Wolf.bet",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Wolf.bet", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Wolf.bet", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EAF0B27D-33AB-419C-94A3-810AC5FBAC91")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "AD4D1C0E-382D-424E-BE1B-7A6F83874E51")!,
                name: "Pushover",
                issuer: ["Pushover"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D2B279ED-90CA-4AA4-B02F-45E98AA008F5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "AD6A5114-6205-4478-BBE2-36C63927FCBE")!,
                name: "Rapidgator",
                issuer: ["http://rapidgator.net"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "54E1C26D-6596-4184-B0DE-DD72B4DD52DC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "AD743CCA-49F6-4910-95A4-F6A0E0533FC2")!,
                name: "IDrive",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "IDrive", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "IDrive", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F32C6479-19D4-4A9D-8B37-85DD94629636")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "ADCAC151-C9A7-4EAC-B65E-28C30CFE9282")!,
                name: "Betfair",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Betfair", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Betfair", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8CC8707F-3E96-4644-826A-56FC3C4DC7F2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "AE853D4D-CF42-43B3-A2A8-4BD61536A9E7")!,
                name: "Adobe",
                issuer: ["Adobe ID"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "372C450D-4334-4585-BDD9-FE3B8D962D0A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "AEDECA67-57D4-450D-9737-F7DB26FA4E46")!,
                name: "tastyworks",
                issuer: ["tastyworks"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "6200F337-54C3-4E74-8100-EF405F767460")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "AF78A598-DA12-473D-8E83-B95CFE0D3384")!,
                name: "Sentry",
                issuer: ["Sentry"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E5C1469C-C522-4DBF-973D-5C6F1AA54EA8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B0616A8C-9FCA-4BA3-8F67-13893706032F")!,
                name: "Xbox Live",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "xbox", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "xbox", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3DAC779E-08D6-452F-9088-C1C6ACD087D7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B08A2F47-2883-4190-861D-6042EE86D334")!,
                name: "pCloud",
                issuer: ["pCloud"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "96003CAA-758C-493E-B177-CCD27EC3434A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B0A1E86B-BAA4-43F5-B2C7-16DCAC2120B5")!,
                name: "Xero",
                issuer: ["Xero"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "29A5BF72-7EE5-4C0A-A968-3DBDD3E0883F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B16F2BAD-B094-43E9-8347-E4A02C04A561")!,
                name: "SourceForge",
                issuer: ["SourceForge"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "98074517-7DC4-48C7-8B60-8ECF53090411")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B18932D2-4DDE-49E7-8F28-6568958E376A")!,
                name: "Coursera",
                issuer: ["Coursera"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "F9A2CD0D-B4CD-4130-9C06-AA354CBBD221")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B1A9346E-79D0-419C-9DD8-DDC57540DB28")!,
                name: "Accelo",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Accelo", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Accelo", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "AAB8250D-309F-4E4C-AB57-772DD7D73C40")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B1F353DF-9C26-441B-A45E-53773CDC3821")!,
                name: "Hosting Ukraine",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Hosting Ukraine", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Hosting Ukraine", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D38EF48E-F3B1-4EEA-B308-276E5E7A6547")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B22D64E6-535E-421B-8ECE-C6F4B5103ED7")!,
                name: "Podio",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Podio", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Podio", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "88A21D7B-15DF-4020-A713-69D880CCA58E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B235239B-0FF5-4D74-BABB-3A76E8DCE4EB")!,
                name: "GMX",
                issuer: ["GMX"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "DCFA66E0-BEEE-4560-9946-1096A804C913")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B280B90A-8C57-4DBE-8B54-1965AC1935DC")!,
                name: "Cardmarket",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Cardmarket", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Cardmarket", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "81EA442E-3146-40A3-9335-BDC5F9511F48")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B2B6171A-438B-4E24-AFA8-C89053A2B09C")!,
                name: "CommunityAmerica",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CommunityAmerica", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CommunityAmerica", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F147D94A-2A3C-4C0C-8E20-5F32EE1A7FA3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B2F42E95-CAF9-40B4-AAD1-4F7EC644129C")!,
                name: "section.io",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "section.io", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "section.io", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "94581656-FA9A-42DA-9509-BC3C833F9424")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B3170DCF-AC9E-4808-898A-B29A3E9DEA44")!,
                name: "cloudHQ",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "cloudHQ", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "cloudHQ", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "46AFA877-A41A-4E3D-BADF-AC749F78048E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B34A2BE5-9A4D-47A2-B51C-397593B17495")!,
                name: "Tableau",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Tableau", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Tableau", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5ED53CFB-6EC8-4301-93A5-C64E8FEEE5E5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B359A557-2215-4623-8B4D-2975F310B6E5")!,
                name: "namuwiki",
                issuer: ["나무위키"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "6AECCDAE-1C03-4D50-87F4-4E5712DBE772")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B36BBB0F-DC99-4F9F-B934-74C68AA0EB3A")!,
                name: "101domain",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "101domain", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "101domain", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "66FC163C-D717-4C18-8277-CFC30291CD5F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B3A39CD8-702A-43B9-809D-0050B7203F0E")!,
                name: "GoSquared",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "GoSquared", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "GoSquared", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8E3FFAEC-9AFF-4DEE-95ED-2EFB063BAF84")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B3AD7C69-D5DC-47E8-82B0-AC607E151329")!,
                name: "Shopify",
                issuer: ["Shopify"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "AB0B5936-B6DF-49F4-9DDC-C898860976DE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B3AFDA8D-5024-43AA-965C-B12A1036AAF5")!,
                name: "DMDC milConnect",
                issuer: ["DMDC milConnect"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "F37FF2DA-F229-406D-BD00-6019CB92097A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B4017DB1-4377-42E0-849C-C70EE3D4F699")!,
                name: "Cisco",
                issuer: ["id.cisco.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "0C91F7FD-783A-4F4C-846E-2E57E13727BA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B4417C8F-1E3F-418F-84B7-77874D164C1A")!,
                name: "Findmyshift",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Findmyshift", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Findmyshift", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "51722E7C-193E-46A7-8817-91FB356E425E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B47CA012-EDA9-44FC-AEC8-39A16A2EE928")!,
                name: "Acquia",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Acquia", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Acquia", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0764B5C9-83C3-4E6C-A053-590ED3379D8C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B4ED9356-1B2D-4A21-BA2B-C96EEB4EDCF3")!,
                name: "Trimble",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Trimble Identity", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6126C800-79B5-40EE-8244-8D14A7D00E97")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B545E75E-34CF-4186-B246-DC02AF28DE70")!,
                name: "20i",
                issuer: ["my.20i.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5BEFD7AE-B6AE-481B-863E-22783C95A493")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B54E1619-84EB-4A39-BE76-FA2A4E6BE6FF")!,
                name: "elmah.io",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "elmah.io", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "elmah.io", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1CAFDF9B-69F8-4638-9EE1-1C67F8FEB7E5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B5586D9B-E92D-4557-8B6A-69F79CBE767E")!,
                name: "Pterodactyl",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "pterodactyl.io", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "49BB26CB-0B4A-44A7-8EC4-0BB8FA283733")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B5850D68-91CF-40CF-AA7C-74776BD6CAC0")!,
                name: "SendOwl",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SendOwl", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SendOwl", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2D6C7FCD-8A93-428A-B6EF-2FBD29837FDF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B650BB73-FD1C-45CA-BB0D-ABFDBFF08014")!,
                name: "SAPO Mail",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SAPO Mail", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SAPO Mail", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BCEAC4E9-AE84-4963-8B1B-C8A5013F6C6E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B6A4766D-D489-4488-9330-041D12F33D60")!,
                name: "Red Hat",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Red Hat", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Red Hat", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "152FD0E2-7BCC-4D81-A76C-649F5A996036")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B6B72488-1F7B-431D-AFE0-4889496DEB70")!,
                name: "Oracle Cloud",
                issuer: ["Oracle"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "910890DB-0DA8-4D54-B0A0-D7BABF811ADE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B6E1967D-9EC6-4BA9-BA53-6551E9B5E75A")!,
                name: "Floatplane",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Floatplane", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Floatplane", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C321115E-762E-4D10-B089-07543A418D24")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B6E2FDC3-447D-4269-A5D8-83E8905F3EEA")!,
                name: "Phemex",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Phemex", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Phemex", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C348BC60-4ECB-4120-AE73-884335B4D365")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B6EAADA1-807E-4188-B418-DF36F8D4A964")!,
                name: "Auth0",
                issuer: ["Auth0"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "B413E65A-CEF9-404D-B1DC-B3BD8E1AE7C3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B7100AB6-810C-430A-9FEF-7AE03DD6DC94")!,
                name: "Carta",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Carta", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Carta", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "71E7A313-308C-4275-A3B2-9AAFF9CD0ED2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B71B2589-EFB3-4237-9BF8-22E9826496ED")!,
                name: "QuickFile",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "QuickFile", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "QuickFile", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "31413840-9231-42E3-BD3E-FF0AC6AC4458")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B78BBA1B-4733-42BC-A1D5-CA18D53E291F")!,
                name: "Paxful",
                issuer: ["Paxful"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "AD3E5352-FBDA-400D-B891-E21DDEC8295E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B7CB942A-BBD6-4823-B7C9-F0F4CEE99C16")!,
                name: "Postman",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Postman", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Postman", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "94D0D578-13D6-4A97-B112-88F2F1B443E3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B7EB2D59-E9B4-4295-907B-B62C1AD1310C")!,
                name: "Mercury",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Mercury", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Mercury", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "64F1D5C7-5ABD-4897-BB3E-823990612154")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B807A96B-B1BF-4550-8729-D45068AA1140")!,
                name: "Webflow",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Webflow", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "38A47686-7AF2-4B3B-827B-315B6B92EB74")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B84DC9AD-9910-44B9-B065-99F06C679706")!,
                name: "Mailgun",
                issuer: ["Mailgun"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "9E4DB15D-4AC6-49FC-A22C-8A0B580BDE69")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B872CBD5-DCAA-4A36-83DC-29B273009726")!,
                name: "Coinsquare",
                issuer: ["coinsquare.io"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "523A8784-C94D-4AC2-BD6F-153B1DF3A9E8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B8736A08-3188-42DC-9127-14686EA744CE")!,
                name: "Knack",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Knack", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Knack", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D22AD62F-F438-40F8-A304-6AAAB48328B7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B87A58F6-2641-46F1-978A-95D67D481C20")!,
                name: "STRATO",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "STRATO", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "STRATO", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E48A3401-65F3-4509-97A8-938719064FF1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B8869267-E0A5-407C-9B77-8C664896B252")!,
                name: "Windscribe",
                issuer: ["Windscribe"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A538ADE5-25F9-4D84-B908-39495B168B47")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B88B6BE0-9BC9-49EC-9629-41E80728D1C1")!,
                name: "Engine Yard",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Engine Yard", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Engine Yard", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6E34C713-8F1E-43B1-B16E-A161099CF437")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B8CCC448-1C97-4D5C-A781-25C48996B00F")!,
                name: "Sony",
                issuer: ["Sony"],
                tags: ["PS", "PLAYSTATION"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2DC7DD80-1B1E-420B-92EE-838298DE29A9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B8EAEBBE-141B-4D01-AF2F-5F568571BF77")!,
                name: "Clio",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Clio", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Clio", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "200243CB-EC62-493C-9D38-FD28FD169BF8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B90E407E-B5F8-4EF5-A3E5-CC3E2DDAF2B9")!,
                name: "APNIC",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "APNIC", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "APNIC", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8F68FF8F-35DF-4600-8A6D-ACF23BAA0E74")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B91A451A-C39D-4660-8852-9571480506F3")!,
                name: "dmarcian",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "dmarcian", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "dmarcian", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8A64113C-04A5-4E02-9064-6AEC58FFDC17")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B962226B-81D1-4CDB-A1FB-4F3F97BCA86D")!,
                name: "eNom",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "eNom", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "eNom", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D9E6030C-CAB2-4EED-8A8E-D3990C6E77E5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B963FBE1-F4CE-42DD-9D54-A978D10908D0")!,
                name: "Anycoin Direct",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Anycoin Direct", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Anycoin Direct", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3D666863-11FA-460A-ADF4-5706BCA6AF49")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B98E779D-5AF4-4C5B-A52B-9BAE9404CB00")!,
                name: "Tixte",
                issuer: ["otpauth://totp/tixte.com?secret=xxxxx&issuer=Tixte"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "8F243E82-97D7-4906-B641-CC00A59576C3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B9A73622-27A2-4776-8996-C6E43BEE3463")!,
                name: "GoTo",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "GoTo", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "GoTo", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "50A61314-EAF4-46D9-8DEB-2B470266937C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B9B8FF8F-0588-4281-A199-674F7785A641")!,
                name: "itslearning",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "itslearning", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "itslearning", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "073D9DDF-0929-4321-AC75-289628A23174")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BA7F09F8-10EA-4158-AAF7-0611C78A229D")!,
                name: "M1 Finance",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "M1 Finance", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "M1 Finance", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B81727B2-1515-401E-B1A6-7C3C051A437D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BB0CF5E7-D66F-442A-9F15-1623CFCFC57E")!,
                name: "cPanel",
                issuer: nil,
                tags: ["HOSTING", "PANEL"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "AE7EBA01-F217-4138-9389-0DBAC94A8F7E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BB91944E-949D-4474-A97F-ACA5A722FB57")!,
                name: "Chartbeat",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Chartbeat", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Chartbeat", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "688E5014-C9D6-40D0-8B0D-DCEBE407BB13")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BBB8945E-9E8E-4ACC-9EC6-85EFBDA0AF98")!,
                name: "Cloudbet",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Cloudbet", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Cloudbet", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "81E1CA40-EB64-4F45-B7BB-D1EE8486625E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BBF98616-DAB0-48D4-859A-0877AD00766A")!,
                name: "TeamViewer",
                issuer: ["TeamViewer"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E478EDD8-EC9B-4E06-B0F8-1089CE988125")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BC1329AD-925B-4F51-8FF2-0079975D9BC0")!,
                name: "Kaspersky",
                issuer: ["Kaspersky"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7F5D563C-229A-4E2C-BBBD-50C7D27F5BDB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BD49D794-B5D8-44DB-BA89-DAE49B11BBEB")!,
                name: "Schneider Electric",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Schneider Electric", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Schneider Electric", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "AEBFCEC5-C95D-4D02-900D-7AD4C7121301")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BD59AF38-1495-4CA2-99D4-76C1D9787A05")!,
                name: "Sendcloud",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Sendcloud", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Sendcloud", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0C38BB1A-1D23-441E-ABDB-ABD4F46A5DEA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BD82B421-51CF-436F-86E9-B9C98487F439")!,
                name: "Filen",
                issuer: ["Filen"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5C7ADBB7-3438-424B-A7D9-F82B7360516C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BD847A68-44F4-4CCF-B4B6-0406EEABC753")!,
                name: "Intuit TurboTax",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Intuit TurboTax", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Intuit TurboTax", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "CF952BDE-EABF-4334-852E-11E3861F0B4E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BDF9B780-CCED-4156-8BFF-C63315BDB3ED")!,
                name: "Planio",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Planio", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Planio", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D781E3E5-0B60-4471-83C6-95E04E741C61")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BE075048-B23D-4226-9FCF-2FF573AFB7E1")!,
                name: "Betvictor",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Betvictor", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Betvictor", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0CD28760-7717-4152-8786-7470F1476B9C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BE114956-58BB-4909-8668-44E728554556")!,
                name: "NextDNS",
                issuer: ["NextDNS"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "88E25804-B257-416A-8CDC-68F71CAE5F32")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BE16E104-BB24-4683-9C7F-7A38E0FEA894")!,
                name: "Back4App",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Back4App", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Back4App", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "05C03BAA-593D-4E28-95FC-CDD2402FF824")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BE30D50C-3F36-47CB-A290-1D8BF057F9F7")!,
                name: "Emplifi",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Emplifi", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Emplifi", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "297C0A36-5202-49D0-846A-C86F3057CA94")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BE5B180F-67BA-487B-9166-A4E0605C1331")!,
                name: "Domino Data Lab",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Domino Data Lab", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Domino Data Lab", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7551730E-2315-45A3-A694-02DB3F5DF261")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BE87D55C-5786-41A2-8851-84BA49C7D4D0")!,
                name: "Deutsche Bahn",
                issuer: ["Deutsche Bahn"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2DA66DFC-D49D-443C-9322-57AE6C623007")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BE900C77-FE67-4F9B-805B-10C899125FA5")!,
                name: "Microsoft",
                issuer: ["Microsoft"],
                tags: ["MS"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5336CD6B-2971-4A3F-BDD9-7D32EA2ABE27")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BE94105A-D323-4565-983E-DE4760B9FE98")!,
                name: "Glasswire",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Glasswire", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A3B6DB73-ED50-4061-BC72-735A0B06F147")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BEA00452-571B-4B75-83CB-BE9F79F8DCC6")!,
                name: "ClickUp",
                issuer: ["ClickUp"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3F75FD3E-BE90-44FA-9620-A2BA8C158557")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BF211001-F2A2-4385-B857-9740B1EDC85A")!,
                name: "WitherHosting",
                issuer: ["WitherHosting"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2D0E42E8-E91D-4983-8364-D005429D57AD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "BFEB9527-09C0-4D93-8B36-DDF0F634C3C1")!,
                name: "Mist",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Mist", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Mist", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4417B65E-35F8-48A7-83D4-0C6AE4391D3C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C103519F-E4FE-4C5A-9C75-E55B42D94A17")!,
                name: "AnonAddy",
                issuer: ["AnonAddy"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "928647E4-14DE-434A-8210-817202D36D73")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C1098C10-4C25-4AEC-8C5B-AAB56989B3B9")!,
                name: "Missive App",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Missive App", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Missive App", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "55753574-A137-4327-BA45-047DAF8A9A61")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C112BF95-6093-493E-8ED8-3CD700A6209A")!,
                name: "CoinField",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CoinField", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CoinField", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "83BB02CC-D58E-43CF-B130-F25103D49810")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C1313346-0D77-4DC7-A67A-2C4136B4F4DE")!,
                name: "Neolo",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Neolo", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Neolo", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "ACB3B7C1-612A-4913-A407-8A78832694C3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C1A8AA2E-5D5C-4F1F-8C1D-15277D75CBD8")!,
                name: "Bugsnag",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Bugsnag", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Bugsnag", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8836E46D-263E-4D37-BDC9-DC92E8A4AE87")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C1CA5186-2E6D-4D70-B8C9-A5410B791664")!,
                name: "Stake.com",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Stake.com", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5430258C-8064-46BB-9ADF-9A36E276407B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C21E91ED-6378-4341-9668-064D76F4B1BD")!,
                name: "Canva",
                issuer: ["Canva"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "BDEA153C-20D7-4844-9C97-D694EE191353")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C23036D4-5065-4ACD-9285-9BF53CC2869A")!,
                name: "ConnectWise Control (ScreenConnect)",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ConnectWise Control (ScreenConnect)", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ConnectWise Control (ScreenConnect)", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E1CAE46B-2A0F-47B5-9750-73E3DAA333D4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C2A740BA-8823-4ADD-9F60-3F87797251F0")!,
                name: "Wealthsimple",
                issuer: ["Wealthsimple"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "699D4DD1-5144-49E6-9C77-BF065E7BCD14")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C2B17B60-31F1-489B-B3DF-3F7B1F750D6D")!,
                name: "Uptime Kuma",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Uptime%20Kuma", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Uptime Kuma", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E40B5B59-34F0-406A-87D8-3E2E27F79B2A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C2C620FA-4C2D-4A8B-A2AB-F36296E75EB8")!,
                name: "Poli Systems",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Poli Systems", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Poli Systems", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D63DED88-E3C9-48AC-A7F9-C7E1D2A433B0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C2E5B8EA-E5F2-48C9-8E9F-452622A3DF9A")!,
                name: "MEXC",
                issuer: ["MEXC"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "DF2FE8D6-4742-4903-A7DA-E4C86D990B43")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C3B53C9A-F0AD-4FED-B34F-3857CF11DFA0")!,
                name: "Exact Online",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Exact Online", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Exact Online", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4EBFCFE7-DBE5-4948-B791-82E9EB42E03B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C3CF1E8A-8F6E-4009-8F19-5677F22899C0")!,
                name: "Changelly",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Changelly", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Changelly", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4629B020-3982-4454-916D-4A465A09C9AA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C3CF42DF-5F28-4812-A954-7364473D5723")!,
                name: "VMware",
                issuer: ["VMware+Cloud+Services", "VMware Cloud Services"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "91779097-9EE2-4E9D-A208-20D3D01D1643")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C3F5925B-225A-4232-BECF-66CB4C9B04DB")!,
                name: "Notion",
                issuer: ["Notion"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "6656FDCF-5AA8-4C26-BFEB-ADA408E764E7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C4504792-DB36-4AB6-9119-A3EE097A4A94")!,
                name: "Con Edison",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Con Edison", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Con Edison", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0EB466B7-A2BE-4158-9A41-CC35691DB480")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C4A11C0E-F261-48FE-969B-5646D7EABA0F")!,
                name: "AltCoinTrader",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "AltCoinTrader", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "AltCoinTrader", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4BDD875E-E88B-46FF-9455-94F235F2A7CA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C4A41A3C-741E-4C57-A59B-1E56D6BB202D")!,
                name: "Betterment",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Betterment", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Betterment", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7560DAAA-266A-42FD-999A-D3C039F5E100")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C4C182D1-88D7-4C0A-BC67-1AEB28FA21DB")!,
                name: "coindeal.io",
                issuer: ["coindeal.io"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "163316F8-FB4A-45C4-A349-1187E51BFE72")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C6055DCA-EEAA-440B-809C-B038C42B5065")!,
                name: "Drift",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Drift", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Drift", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "441A0F17-B8E3-4165-819C-CD17473BA6E0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C6256792-D4DA-4954-A3E7-2A0FCB4F7D2D")!,
                name: "BullionStar",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BullionStar", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BullionStar", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D3CE67D9-4325-45CA-AFB6-2F0C4A788972")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C62A918A-A48F-46BD-A5FE-3E5024FB3332")!,
                name: "Labcorp OnDemand",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Labcorp OnDemand", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Labcorp OnDemand", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "16FC5678-180E-4E64-9398-842242382ACF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C62E1EA9-E2D8-4742-A6A9-D9B3527A068A")!,
                name: "15Five",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "15Five", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "15Five", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "978354B2-AF33-440D-BC4D-97D95024ED31")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C63760A0-5F64-4B99-B8BD-CD08D4266D86")!,
                name: "Federal Student Aid",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Federal Student Aid", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Federal Student Aid", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C69C5152-2B51-43EF-B881-D3E50C599BB6")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C6441103-FA31-45F6-BC7B-76E3D20A73B1")!,
                name: "Mailo",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Mailo", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Mailo", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FBD7637D-C1A3-454A-8E06-B7CC5F04201C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C679176D-D306-4A06-876A-3334B47D3975")!,
                name: "AnyDesk",
                issuer: ["anydesk.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5FB9027D-E589-43AB-88A7-13F39799EF94")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C6A0E139-D7B3-4351-8741-CFDD296B5802")!,
                name: "Bitcoin Meester",
                issuer: ["Bitcoinmeester"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "4E2C56B1-02CE-4756-8569-EF872D405874")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C6A5B0B8-7C7F-4469-A5B2-4E97F4B93EB1")!,
                name: "XDA",
                issuer: ["XDA Forums"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "8250908F-6FD4-4FDF-9250-1FB45E27B595")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C6BA0B94-7535-4EA3-B490-9DB5513F0A3A")!,
                name: "LBMG",
                issuer: nil,
                tags: ["LBMG.CH"],
                matchingRules: [.init(field: .label, text: "lbmg", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "70D6C5D3-7184-486B-96B1-D3B35E038209")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C6C60489-75B0-4EE8-984E-B1569397B209")!,
                name: "EVE Online",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "EVE Online", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "EVE Online", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A45B3994-FD70-44AA-9A94-FE72B24B0015")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C6F1FEC4-2325-4A2F-BE73-1D4C269CF840")!,
                name: "Qantas",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Qantas", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Qantas", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8CCBA7F1-0372-4A0A-95C4-AD92479E3564")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C748E680-902E-42CE-AB81-251C01759C52")!,
                name: "Wealthify",
                issuer: ["Wealthify"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "67628C98-1593-453F-B0D8-E0DED0F9947B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C755B82B-BB1D-4DCA-92BA-15EA4E11B38C")!,
                name: "KnowBe4",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "KnowBe4", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "KnowBe4", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F6FACEDA-7068-474B-9783-A04F15BC3C34")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C755E985-7434-4272-971B-A0AF16D4BF11")!,
                name: "Wiki.js",
                issuer: ["Wikijs"],
                tags: nil,
                matchingRules: [.init(field: .label, text: "wikijs", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "wiki.js", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0F97B5F0-62C7-4DE2-8B74-5E9ABC62C860")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C7A4A839-06B1-4D5F-90DC-83D7F59B1078")!,
                name: "FaucetPay",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "FaucetPay", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "FaucetPay", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "AE8F94ED-4E9A-49ED-A230-72B2089E676D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C7A9CC0A-C382-40F4-ACE1-F0C8881F1342")!,
                name: "Lobsters",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Lobsters", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Lobsters", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0A8C0A5A-AB5E-43BC-90AC-4F43A598F8EE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C8617020-8FDD-4B51-8966-E932DE5C6EDA")!,
                name: "Wrike",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Wrike", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Wrike", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E389F4A5-9ECC-4252-AE2E-D8F13C5071C1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C8EBF624-C4D2-4E6A-AEAC-FC235494AB92")!,
                name: "Cloudflare",
                issuer: ["Cloudflare"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7E40BA1B-12C4-46B5-B74D-AB362C21494A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C91392D9-FC42-4EA8-B297-D2EDA9DC13F0")!,
                name: "SaneBox",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SaneBox", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SaneBox", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "637F3A66-5201-4B59-B934-C4B9B8D52326")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C91E4DB8-6001-494D-8912-E09D2D371ECD")!,
                name: "Abode",
                issuer: ["my.goabode.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "486D0E95-A48D-4306-93BF-C926BFC9B8D2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C97EBAA8-7380-4E5D-9059-397F2A1FC982")!,
                name: "Vimeo",
                issuer: ["Vimeo"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "475F50FA-F86F-4AF8-A5D1-684C77D9B695")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C99DFE6D-6D75-42CE-A1FB-0C8FBBF70D72")!,
                name: "HubSpot",
                issuer: ["HubSpot"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A0E66AF7-3ADE-4CA4-8E3F-3C072826CD83")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C9BABD51-23B7-4F1D-AFA0-504BC85F79B5")!,
                name: "Bokio [SE]",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Bokio [SE]", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Bokio [SE]", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "71640138-7E8B-456F-A2CA-BFFA8FCD385E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C9C39E2A-C471-46FC-8467-7AC2EE93B7B3")!,
                name: "Yclas",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Yclas", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Yclas", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D8F29DE6-819D-4154-90D1-F3172DB294BD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C9F0697E-11F3-4CFF-B148-A689805507F8")!,
                name: "Hotjar",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Hotjar", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Hotjar", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E93B56B7-4C39-4C54-8C88-922156F75570")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CA16982C-9738-44C1-AF9A-2580A734ACD1")!,
                name: "Netlify",
                issuer: ["Netlify"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "8B27C743-F69F-40BD-9407-3F64418D69D0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CA2A983D-42BE-496F-9DC9-520C78FB6978")!,
                name: "KuCoin",
                issuer: ["KuCoin"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "ACC381D5-2360-47CF-B52E-470F7558F04E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CA40C524-92D2-4B52-B434-8E598374D58E")!,
                name: "Telnyx",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Telnyx", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Telnyx", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DB17FDB5-4677-4CDB-862B-B198B5E1FF17")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CA63153E-5A76-4489-BB08-BE0D41331597")!,
                name: "Namebase",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Namebase", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Namebase", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C6835C4D-4AF2-49D4-BC4D-2ED9D7E0213B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CAF28D65-0DE8-4A9D-B8BB-55580D6FA900")!,
                name: "Arduino",
                issuer: ["Arduino"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "C5EAD9F5-DB1D-409F-A7D5-93254B048A15")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CAF4B0DF-D8BD-442C-A57E-9C8187239899")!,
                name: "Wordfence",
                issuer: ["Wordfence2FA"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5FFC6239-F3E6-40E7-8FBA-8C6965992A58")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CB571368-E2BE-41F0-A4BE-C0C41F6D3877")!,
                name: "NuGet",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "NuGet", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "NuGet", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "25B1271B-F2F7-4A26-BB6D-DBAC165B99E8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CB5E1F42-22EE-4993-A04F-9476A9C7C2B3")!,
                name: "PlayStation",
                issuer: nil,
                tags: ["PS", "SONY"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "4A1E6984-020D-4184-8844-1D1465A925CC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CB6E08B9-DD63-45FE-A3C9-EE5A95EF4355")!,
                name: "Avast",
                issuer: ["Avast"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "108A8AD6-ACB2-43F5-A697-5DD1116D4DA5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CBA07980-5736-41CD-A7FF-7D1DED91908A")!,
                name: "Topicbox",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "topicbox.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2C1C87ED-E401-4234-BB14-85F632A9CFDC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CBE525D2-EDC9-4C35-A2B0-3966B997FAA0")!,
                name: "Groups.io",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Groups.io", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Groups.io", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "650DB4D2-DC14-4F5B-896D-134AAFDEDB23")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CBFBDE48-84BA-42E8-B3BF-07D7163E14B7")!,
                name: "Bibox",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Bibox", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Bibox", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0CB9EF76-9F6E-4FFF-82E4-010926F9AC50")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CC919F66-B905-4A74-B033-C029308B1092")!,
                name: "NameHero",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "NameHero", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "NameHero", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "68C86A94-9AE8-4C5F-BC90-43BDC1FC4EAE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CC9B76F7-03DA-418A-BC22-E0C183D2BCAE")!,
                name: "UpdraftPlus",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "UpdraftPlus", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "UpdraftPlus", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2183B659-6C73-4679-85FC-3497A51527C0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CCD5C47A-54BE-4B11-A4CF-386986BD5C6F")!,
                name: "CDNsun",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CDNsun", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CDNsun", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "91EC291A-F626-475A-AD1D-D1F5C2A72761")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CCFF9D4A-C6A1-4A0E-9113-E365E81AFB89")!,
                name: "SimplyBook",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SimplyBook", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SimplyBook", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DFE4EA38-0FD0-4997-ACD5-2AE2EF01056A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CD188F62-FB59-4CD1-8AE5-B64C0AAC60A5")!,
                name: "Nimbus Note",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Nimbus Note", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Nimbus Note", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4D56A016-EC72-4A3D-AC0E-EEFAC85A601E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CD19A814-A6A4-4D97-A59F-B1A0B96078D2")!,
                name: "Tokopedia",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Tokopedia", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Tokopedia", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "88B27A8B-09F2-4032-9A5B-8EAA3795DD69")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CD2CCD13-EED6-4B66-8A89-8C3F0799B9B6")!,
                name: "MYOB",
                issuer: ["MYOB"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "1FB872E7-C2B3-40C7-8F1C-711E8589956D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CDADF221-4F82-448A-A738-C12CCFF5898A")!,
                name: "Twitch",
                issuer: ["Twitch"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "45B960F2-8B2A-4BFE-8BDE-4893B1003D26")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CDEC1FEC-5E6F-4470-9A15-60631F6C4383")!,
                name: "Snapchat",
                issuer: ["Snapchat"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "0EC93E50-3B19-49B2-BACA-BA561A1BA2B1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CDFB31CE-9D07-42C7-B621-114043BB81E8")!,
                name: "ViaBTC",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ViaBTC", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "ViaBTC", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2961FD45-C8A0-4837-9E83-6CEE5318EC7B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CEBB233B-1C6F-46CD-BB4E-6FF28F5DD1A5")!,
                name: "Pusher",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Pusher", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Pusher", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BBC023F9-FAE7-43D5-8117-1EA258CD2FE5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CF118B0D-8972-4491-AEC4-EB7821701728")!,
                name: "Vancity",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Vancity", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Vancity", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1216E928-CFA1-42FB-AC46-D54F7B962D82")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CF362457-F92C-41B1-B937-75F6C2BC7928")!,
                name: "Mailcow",
                issuer: ["Mailcow"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D9EECF73-C935-48D6-9AAC-A9A3C63F7D0B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CF415505-1DC3-4BB7-A9BE-1FE85B736CB6")!,
                name: "University of Notre Dame",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "University of Notre Dame", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "University of Notre Dame", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "00595FA8-96D3-48CB-85FE-AF8B6967DB08")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CF794E79-AFA6-4C3B-BA61-7E119F2F5C9F")!,
                name: "CleverTap",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CleverTap", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CleverTap", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "87ABFBEB-863A-456A-A2D6-F7C77A61206B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CFBB724A-5F4D-4DA6-BFB5-352FEE268E55")!,
                name: "OLG",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "OLG", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "OLG", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A4F3C3D4-0FB4-43F2-9D6D-8DE3CFB15652")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "CFD72B78-DE9E-47DD-A2D0-DB3B45A7E0D8")!,
                name: "Sonic",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Sonic", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Sonic", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "17BFBFD9-E1D7-429C-A186-4CE5EB989A50")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D0304FA7-F304-40E2-93C4-B4D4D3E95486")!,
                name: "Cisco Meraki",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Meraki", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "30D5083A-E9FD-43C0-A011-698E431FB409")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D0D6F366-CCBA-4BEF-9E3B-8ABD120897BB")!,
                name: "Compose",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Compose", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Compose", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "9B38D20C-50DB-4C41-8958-6FA90CC556E8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D0E58424-5C84-43E5-B508-C3D59DCD033A")!,
                name: "Smartly.io",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Smartly.io", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Smartly.io", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3E808796-A00A-4D57-9D72-773645E1990A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D0EDD58D-E40A-444D-A440-E4907B0A22D6")!,
                name: "Bitwarden",
                issuer: ["Bitwarden"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "6BA06A11-E5D2-493A-950B-CB0D400BC6DB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D1A264B0-A140-41F0-A810-221B8C5B8FE4")!,
                name: "TherapyNotes",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "TherapyNotes", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "TherapyNotes", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "20AB5234-CF6A-4D98-8941-47346F0A6165")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D1F4FD42-38E0-4D8D-9FF4-4F1F7D9F0A8E")!,
                name: "Rubrik",
                issuer: ["Rubrik"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E4C14F12-668C-49FC-B0B5-DEC9830E5CE1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D241EDFF-480F-4201-840A-5A1C1D1323C2")!,
                name: "Steam",
                issuer: ["Steam"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D5FD5765-BC30-407A-923F-E1DFD5CEC49F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D25508F8-C64B-41D3-905A-E95D484B034A")!,
                name: "Zonda",
                issuer: ["BitBay", "ZondaAuth"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "B8B16D9F-52EC-471F-BFC0-FD1E6F9D60F3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D28A884F-3F49-4C10-B3F0-40D8F2A356C1")!,
                name: "North Carolina State University",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "North Carolina State University", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "North Carolina State University", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BA14D0CB-8F0E-4DBC-BE7D-1D7FBA074A76")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D2DF94E1-FCF9-4F47-B605-F123A7D8EDF5")!,
                name: "Trovo",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Trovo", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Trovo", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1309AA5B-344C-4058-B1EB-7211C6EA5361")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D3085B71-88D3-4C41-BD73-D029FC90E401")!,
                name: "EmailMeForm",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "EmailMeForm", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "EmailMeForm", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A9C3AE21-A596-4103-8E25-F867B55D5A96")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D30DADA7-C3B8-4F37-9CDB-4FDBE649BA8A")!,
                name: "Availity Essentials",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Availity Essentials", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Availity Essentials", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6F24DC2C-5A8D-416C-9B71-DA36E1AE0E88")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D33DD19C-CE43-45A2-B204-FC636F69E75E")!,
                name: "Roblox",
                issuer: ["Roblox"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E37670C2-0870-48AD-B736-1D8E0DA7E635")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D353DC43-CACD-4618-9169-6BDA93D940F1")!,
                name: "Kickstarter",
                issuer: ["Kickstarter"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "AAAEF857-A3E1-4A88-91EC-F982AEF0CF0B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D3663717-FF77-4DCE-9CAB-48204F1A30C1")!,
                name: "Flywheel",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Flywheel", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Flywheel", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5C578A2D-CFF4-455B-B840-DDCFFD333563")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D3B5E2F2-96C2-4FA4-8B2D-38E3FAF8FC3E")!,
                name: "GoCardless",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "GoCardless", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "GoCardless", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "965D9C91-11BA-4703-99C1-544695135643")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D476A817-D8CD-4A39-90DC-88CF65E97C66")!,
                name: "NS1",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "NS1", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "NS1", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "363A3A90-3180-4EDF-BF17-4E0B05D6A72B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D4EABA7A-4FB0-4447-96B1-005FBF8CDF38")!,
                name: "Heroku",
                issuer: ["Heroku"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "EAFABE79-26CB-43F3-B2CF-027D155407A9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D5085CF3-4521-4804-A88A-F78241546308")!,
                name: "Cordial",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Cordial", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Cordial", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C917DBF8-F285-452E-B5C3-87CCCA406C60")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D50D085C-87A1-4C03-80AA-D2384971C6F3")!,
                name: "Amazon",
                issuer: ["Amazon"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "96B374DC-C981-4E55-AF2E-9272B43455A1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D50E1BC1-D85A-4323-ACED-B0A343B12426")!,
                name: "RunSignUp",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "RunSignUp", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "RunSignUp", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7FE635AD-3CB2-4C1C-A863-D08699CAAEEC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D519742D-DB19-440A-B9AF-CD4C31A58603")!,
                name: "BitMax",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "BitMax", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F243AFFD-CA1C-4F7A-9BB6-BF087021F8B8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D54E6374-570E-445F-ABF8-608E8BCA5162")!,
                name: "Gate.io",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Gate.io", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8BB211BB-7829-482D-B9FB-51BC5D99710F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D5E2786C-9601-4B11-A33C-9F818BAFF264")!,
                name: "NEXO",
                issuer: ["Nexo"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "CB8690C9-9D0A-4D87-95E2-26DE44529ACB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D64758C3-18DE-4D77-9139-B60738D57F4B")!,
                name: "Spring",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Spring", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Spring", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3912FBBD-5C38-420F-9B20-6536EED22179")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D6570704-868F-4CCA-990F-3F0FDCEAE277")!,
                name: "Bybit",
                issuer: ["Bybit"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "0187C518-0EDC-4892-9FB5-46C10C7AC16B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D657FE1B-6EB7-47A7-AED7-51F6773655E7")!,
                name: "MaiCoin",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "MaiCoin", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "MaiCoin", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FFBB48D4-7E95-4B01-BD54-66092BC38328")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D65F8C6F-E47C-4DF3-88BE-579EDDFD8464")!,
                name: "Aiven",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Aiven", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Aiven", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2583B855-A6AA-4199-BD3E-FA15F184BA61")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D6850B85-7648-4558-B06D-01B91BF83DFE")!,
                name: "BitBar",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BitBar", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BitBar", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A9F58C40-A348-401F-9671-17AFD77DE40E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D696BBDF-5075-4F8D-AF54-AFB334D704C5")!,
                name: "PowerReviews",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "PowerReviews", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "PowerReviews", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FBF9CF79-AFA8-4E26-9B46-1BC378C8764C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D6C385EF-7A96-4788-843D-7D071BD4D0F6")!,
                name: "Emma Email Marketing",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Emma Email Marketing", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Emma Email Marketing", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "300464D4-EE2B-4DFB-BD3B-3C0EA0E75E7A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D6C6D348-ECEB-45E3-BB22-FD25C08B8243")!,
                name: "Sonix",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Sonix", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Sonix", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2F43AC34-4290-4CC7-B337-581E6CF1BE57")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D6FB6986-F7BD-4DE7-A541-25362B27A2BC")!,
                name: "Coinut",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Coinut", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Coinut", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D86665E5-0401-40A2-9A25-0700B24277C0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D70C9E1A-69B7-4A5E-8745-ED8D45737060")!,
                name: "Envato",
                issuer: ["Envato"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7D3744C4-FCEC-47D7-B660-640C9D04EFF9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D7B6F20A-B1CC-4AA4-86AA-02EFB00244B7")!,
                name: "SiteGround",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SiteGround", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SiteGround", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FD0820EC-C5D5-41C1-A73C-93EFD4578EEE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D7CBFB18-60B2-47A6-B14F-C64E4C4B0F2A")!,
                name: "Serverspace",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Serverspace", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Serverspace", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D998CEFF-02AF-4246-B1D5-F50139E85FD2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D816F562-0AD3-4F13-BC64-17083336EC77")!,
                name: "Formsite",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Formsite", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Formsite", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F5E17C5F-06E2-43EF-B738-55E41DBEB6CC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D83858E9-F030-40E2-A3CC-20A902E97CEC")!,
                name: "Mountain America Credit Union",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Mountain America Credit Union", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Mountain America Credit Union", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "044C8FF6-2A87-4F25-829B-AFB4D302472B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D85A3247-BF4E-4C8D-AAE8-A17F896013DE")!,
                name: "Preceda",
                issuer: ["Preceda"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "580A11D7-69AD-4AA8-BA4B-1D9F5C23474E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D8AC3674-439C-431D-996F-73782390A870")!,
                name: "DreamHost",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "DreamHost", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "DreamHost", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "ECC7446C-78FA-4C68-95BA-9A27D7DA3549")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D8E293B5-918E-4E08-99F1-5076493CE7C3")!,
                name: "Truth Social",
                issuer: ["truthsocial.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D08818CF-2843-46C1-AF6E-2989750838D2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D94B0045-E3E9-415D-A585-89CF2B29E466")!,
                name: "Taboola",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Taboola", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Taboola", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2D1132CD-59F5-4E61-A383-6A0D58F0A14E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D9F8DC5A-9111-4E5E-8568-9D88849481B5")!,
                name: "CoinFalcon",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CoinFalcon", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CoinFalcon", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "03F332D0-DE3C-488C-A768-29F7DB373D79")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DA8084C3-9115-4879-9900-C5F41B7A98D6")!,
                name: "Wealthfront",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Wealthfront", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Wealthfront", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DA3BEFAA-56C1-4B79-81AF-6B35E84D7824")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DAD21619-8E8D-44FD-9B85-A4CC8D6B56DA")!,
                name: "MyAnimeList",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "myanimelist", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "90BB2F2C-C3CE-4B07-9A12-44FCEBD6170E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DADF55EC-372D-4DC9-B025-208B52485720")!,
                name: "Faucet Crypto",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Faucet Crypto", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Faucet Crypto", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A9087677-4F20-404B-920C-B84CA36E2330")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DAE3B24E-F732-4AD1-AFFB-71A7068896D6")!,
                name: "Bithumb",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Bithumb", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Bithumb", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DB821708-CB2B-49DF-BF15-46917CEEBCCB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DB8726EE-C246-4E75-BFF3-422C9C0E5EFB")!,
                name: "OpenSRS",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "OpenSRS", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "OpenSRS", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "015ED54F-C8B8-49E5-94C5-03BA6ADDEA53")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DBA78FE8-DA79-4C21-8F8D-6E9C0534C2D6")!,
                name: "AllMyLinks",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "AllMyLinks", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "AllMyLinks", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EFF97B47-0A43-42E3-B276-CB235E1457DD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DBBEB162-83E6-45B2-B1A2-11300AE18DD0")!,
                name: "Gmail",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Gmail", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Gmail", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2020274E-F0AE-4643-AD56-AF73612AE468")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DC08C6DB-D095-4BAC-A64B-275B2F7843EE")!,
                name: "Putler",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Putler", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Putler", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BDB60032-34A6-47F1-805E-BB91B0DBEE03")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DC9099BF-F506-4713-B206-BCC4F802ED1F")!,
                name: "Deputy",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Deputy", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Deputy", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "3DAD9223-DE78-475E-B252-F341536EDBAB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DCBC5CC0-60D3-4235-9430-4A8C06286283")!,
                name: "Nextcloud",
                issuer: ["Nextcloud"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "CAA08091-57D6-409D-A45E-F684CDBC79B0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DCF1A91B-E527-4C40-9A5D-C34EA2F1C680")!,
                name: "Twingate",
                issuer: ["Twingate"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "15CA416A-3212-4DB7-9BCA-60548203B411")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DD1FC65B-34A9-4C97-B3A1-F7DA1385CE61")!,
                name: "Minergate",
                issuer: ["minergate.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "1054C554-F8BC-46C5-9C79-F7A8B74DD5FE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DD201816-6A50-43EE-AC67-220F3D569BDB")!,
                name: "SPID",
                issuer: ["ARUBA"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2A90F267-5E37-4003-A114-E05892E5F4DF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DD48038E-54F0-4D26-B6E7-682D75B0FF00")!,
                name: "FreeTaxUSA",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "FreeTaxUSA", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "FreeTaxUSA", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "27B3D372-9613-43CF-B9B4-9BAB86411C77")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DD56B47D-3F3B-4254-89FA-804CFC63BFFB")!,
                name: "Batch",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Batch", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Batch", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E1E27F88-1825-4746-BB36-581E9CA7AAF6")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DD6A9A01-52D7-4B5E-9F74-0CA68538A070")!,
                name: "Crowdin",
                issuer: ["crowdin.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "6059F9E8-D90B-4CCA-ACEA-AE8797837ADB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DDB8874C-4FB7-46AF-B478-5ABB52F30ADD")!,
                name: "2Checkout",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "2Checkout", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "2Checkout", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "16A03F1C-AAD1-417B-875F-3DADC9E38F2D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DE1F18FB-D73A-4136-A675-801911202565")!,
                name: "Principal",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Principal", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Principal", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "CD75E4F1-E661-40C4-B6F4-EA5DCB66567E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DE59D073-72A6-4FF5-97FF-5CE7A56D0DB2")!,
                name: "CoinPayments",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CoinPayments", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CoinPayments", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A91BBFE3-365C-4C04-99C0-247506F51897")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DE8611E4-4B83-4B9B-B252-94FD02460916")!,
                name: "A2 Hosting",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "A2 Hosting", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "A2 Hosting", matcher: .contains, ignoreCase: true),
.init(field: .issuer, text: "A2Hosting", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "A2Hosting", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4FD0608C-3721-4349-9F57-9930521F5BB5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DE9A762B-166B-465E-A1C4-863937C9E337")!,
                name: "Gab Social",
                issuer: ["gab.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "20911304-BFF2-4754-8B53-15A43F2AADF0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DEC50470-32C3-4F63-BAF1-40E82B961F10")!,
                name: "Raygun",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Raygun", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Raygun", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "77977D70-B13E-4B8F-A420-9E0412E0EB46")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DEEAD8DD-C9E3-463A-8C73-1E75C5EC13CF")!,
                name: "Rockstar Games",
                issuer: ["Rockstar+Games", "Rockstar Games"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "FCB5345A-DACD-4898-884D-162C8263FD62")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DEF23EE5-6F78-4803-A744-965B688A9B10")!,
                name: "STEX",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "STEX", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "STEX", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5FB72425-B149-4AD7-8ADB-E6FBF9A4C506")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DF008D68-670F-4188-BF4B-2CD6A05F0060")!,
                name: "NETELLER",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "NETELLER", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "NETELLER", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DFDFA67E-2017-4557-8429-38ED6726BC5B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DF07B6DE-6B7A-4CD2-93C8-EB3F84FD8D3F")!,
                name: "Optimizely",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Optimizely", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Optimizely", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "45918E70-6145-4808-BFAF-769E5F7B7185")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DF8F7DEA-9B3D-4058-BD1E-4A2E8D93F45E")!,
                name: "NetSuite",
                issuer: ["production.netsuite.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "CB4C0BB5-5C0C-43DE-AA26-6ADA823F0466")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DFC48ABC-3FD9-4456-833F-FCAA52691CCC")!,
                name: "Stripe",
                issuer: ["Stripe"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "755CDCDE-A73E-49A1-ADF4-A6CC2B85174C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "DFE680B6-D728-454D-86FB-E97F19703D12")!,
                name: "PythonAnywhere",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "PythonAnywhere", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "PythonAnywhere", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6EDBA584-A91C-4D58-9DED-B18733083AB9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E0181C49-480E-4623-BBE6-6E1A3C1AE6A4")!,
                name: "Coinify",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Coinify", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Coinify", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FEA5051E-9569-4299-A71F-58BB078AA662")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E0305FA4-281B-4666-8D1C-A3FA80F3C58B")!,
                name: "Repairshopr",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Repairshopr", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Repairshopr", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "10F10CE2-DB50-48DC-8121-5733A485FBD3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E07B39BA-1894-4732-AC6A-CECB71C4001B")!,
                name: "Miro",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Miro", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Miro", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "898AA6D1-7CF1-4C53-8B1B-BA2991FA2E86")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E085EA95-678D-4B5D-97B4-2B7107567069")!,
                name: "Robinhood",
                issuer: ["Robinhood"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "6582193F-C4BB-4AA2-B7FE-6EFA02BD6995")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E0A0A866-8269-4B7E-B659-3758ECD06100")!,
                name: "Apple",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "apple", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "90CAF674-4269-4193-9749-4849F97CFB53")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E0ADC0EA-8017-4FEF-BB6C-505969352084")!,
                name: "Valr",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Valr", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Valr", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BA1A9E69-F71F-41DA-A843-83FF2B506E4B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E0D3D638-1FA2-4AA4-8242-4920BD151226")!,
                name: "Blockchain.com",
                issuer: ["blockchain.info"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "01F35A89-4444-4208-A405-C914340DF362")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E15848DD-88DC-4B75-9384-29FB97749177")!,
                name: "Krystal",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Krystal", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Krystal", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "CAC6A9FB-B018-4F1C-B7D2-8C71013C8433")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E186F845-BEC9-498D-9446-BC8987259BFA")!,
                name: "Name.com",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Name.com", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Name.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "27814220-BD4C-413D-A24C-10EC163A7700")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E22669E3-888A-400D-922E-11A9E4AE04C7")!,
                name: "UpCloud",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "UpCloud", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "UpCloud", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "CC7B5194-C464-47A4-8197-D4F67791886D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E2D0C20C-FF6C-48ED-BC21-F2D738AC0067")!,
                name: "Hokodo",
                issuer: ["Hokodo Dashboard"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "9304E41F-B37E-4437-AAE9-8CB98CFB1652")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E30309C0-6975-4AF4-9C9D-4B96DBCB4E40")!,
                name: "CoinOne",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CoinOne", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CoinOne", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6DB9522A-35A6-4D18-81A1-1D77081DD511")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E325587D-695F-49B2-82A3-130E10640DB1")!,
                name: "Tumblr",
                issuer: ["Tumblr"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7E039B98-B8B9-4A7C-A3F9-2059AB85A9EA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E32CB9ED-F0A0-46E5-8011-0C8D33617ADF")!,
                name: "Tebex",
                issuer: ["Tebex.io"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "29B478A1-D863-42DE-AC32-095AF746914C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E3522CAF-0C43-4EFA-ADBC-9C75B8E1940F")!,
                name: "Koofr",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Koofr", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Koofr", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F8F2478B-5407-4CE0-9AB7-B2AA0B893BD6")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E376EC91-99A2-4771-82FA-0DBD72C82A95")!,
                name: "Kintone",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Kintone", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Kintone", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "973D3E29-54B4-487A-8428-BA5D1B1C43C5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E37E69DB-149F-49A8-A769-651A3A2F1F6F")!,
                name: "Purse",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Purse", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Purse", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "53D2FD49-364C-431A-86CF-C729983416A1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E3A1EE7B-B689-43A7-A88C-DE98C793B2A5")!,
                name: "Zapier",
                issuer: ["Zapier"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7F76CD41-6022-409A-9253-E399CDE29B88")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E3C02BBB-3D55-4A37-823E-C4AD929C202E")!,
                name: "Saxo Bank",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Saxo Bank", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Saxo Bank", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "364CACF5-E3F4-4DC3-876E-B6C2802CF099")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E3D80B18-B187-40AD-A2BA-D4F35AC84110")!,
                name: "Hint Health",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Hint Health", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Hint Health", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "CB6128DF-3B38-4FB8-9CC6-DB94B5326B0B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E3E901E5-28DD-4941-8DDF-74C91858C613")!,
                name: "DirectAdmin",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "DirectAdmin", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "DirectAdmin", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2C69CC2F-5C82-4609-AD3F-10F87D0D1FE5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E40761DB-A914-447F-A353-A53076734756")!,
                name: "Miss Hosting",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Miss Hosting", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Miss Hosting", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0161D30D-5733-446C-9414-04354E868B21")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E4ABE02A-D7A1-465F-8974-3BB073BFA5F6")!,
                name: "Runbox",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Runbox", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Runbox", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6FA97BE1-4C36-4ADA-8276-814104F743FA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E4C4F37C-866E-4C30-9E02-8213A0AFF7BD")!,
                name: "Tutanota",
                issuer: ["Tutanota"],
                tags: ["MAIL", "EMAIL", "E-MAIL"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "856858A8-25F9-49BF-9EA6-10B07A618D1D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E4C7D1CB-9AE4-4DBC-B258-2FCC033AB5C3")!,
                name: "Replit",
                issuer: ["Replit"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A11C8FFA-44B1-47FD-B1B4-043973BD9D4D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E4CD7C6A-570D-495F-ABA7-AF67BF6363F7")!,
                name: "JumpCloud",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "JumpCloud", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "JumpCloud", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "552EB7E2-2FB8-4735-A6E3-72FC0015BF14")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E4D9664E-C6B9-42B4-A339-8EEC92CBADCA")!,
                name: "NameSilo.com",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "NameSilo.com", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "NameSilo.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "057319EE-BAC5-4382-86B9-7DC4BBAD6717")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E4EFFD58-8E12-4E34-BB70-7E9D3008AEDE")!,
                name: "Wikipedia",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Wikipedia", matcher: .contains, ignoreCase: true),
.init(field: .issuer, text: "Wikipedia", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2897C31F-95E3-470B-A5E9-E2BFB1BA5D40")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E51103DB-904D-4C32-8295-B4B270EB87C7")!,
                name: "Cliniko",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Cliniko", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Cliniko", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2497F9DF-245F-48A1-85E2-35B553E3000A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E53B287D-7946-462C-926E-E0ACE104596F")!,
                name: "Notejoy",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Notejoy", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Notejoy", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "716B89DE-67B1-4B29-8230-DA6C03423C98")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E5618B78-9499-4E14-979F-A0765DE153F1")!,
                name: "You Need A Budget (YNAB)",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "You Need A Budget (YNAB)", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "You Need A Budget (YNAB)", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5373C9CE-DA66-4C89-8950-E23C007F5174")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E5AE530B-546D-4B49-A1E0-C7701F8A9640")!,
                name: "BlockFi",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BlockFi", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BlockFi", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B3CFBCFE-51E0-4CD4-A853-44F41BD19D2E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E5C0B179-B918-48BF-A946-CB362C7ABB68")!,
                name: "Kinsta",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Kinsta", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Kinsta", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "9D02A9B4-661D-483B-8A62-3B110EC0000A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E5DEE7B9-C921-41ED-8B24-E74C6B72DAA8")!,
                name: "Square Enix",
                issuer: ["Square Enix ID"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "02B0A535-36C4-46D3-9273-22DBF5236CE8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E6855FEF-9E6F-4636-93D6-ECFEC445350A")!,
                name: "Sendinblue",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Sendinblue", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Sendinblue", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0054814B-7F9E-42FE-8B02-1576E5D255F6")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E6C6261F-DA7F-4F2F-A34A-65BBFF91611F")!,
                name: "Timetastic",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Timetastic", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Timetastic", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A552BBE1-90C1-4335-9CA9-7090176CC3AC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E6CABA64-CF95-4EDD-A53C-9C9549672D3B")!,
                name: "Mercury Cash",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Mercury Cash", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Mercury Cash", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "89676E6D-042E-4F38-B2A3-40A94491FCE0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E6CCC0E1-82C7-424F-B8BA-31C779C8E530")!,
                name: "CloudBees",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CloudBees", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CloudBees", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F1D88646-6683-4610-A316-DE6490A70511")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E6F9B440-EDEA-4D3E-AD2F-0E2C4FE7161A")!,
                name: "Smarkets",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Smarkets", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Smarkets", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "08E2F10E-75F5-4A18-8C73-401F02084369")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E709DC4B-2A72-4F6F-9C8A-6B3DBEBC42E5")!,
                name: "BeamPro",
                issuer: ["Beam"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "83BFBBC9-3399-4556-8724-3FD1EA46B97A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E766B17D-8513-4B4C-9CD6-B7765EF4ACC7")!,
                name: "CoinLoan",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CoinLoan", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CoinLoan", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "84B89B07-8F9B-456A-AB4A-C15F75C96A59")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E7672F3F-2760-47A9-B0A0-516B8D59695D")!,
                name: "University of Delaware",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "University of Delaware", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "University of Delaware", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2CF4FDA0-548D-4DFB-9AFB-4D76A46DA81D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E788F163-F596-4252-8748-480D19B57871")!,
                name: "easyDNS",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "easyDNS", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "easyDNS", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4A4886D3-C503-4DE7-9F2C-F6F845EAABB0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E7D3967D-7F1A-47DB-9E7C-7AEAFE0731F1")!,
                name: "Rollbar",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Rollbar", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Rollbar", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C38E5C0F-782D-4ADA-85B2-D801FD4E1F6F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E82B02E9-84BB-4AF3-B66E-09928DA55945")!,
                name: "Liquid Web",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Liquid Web", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Liquid Web", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "02A52D7A-B885-4826-8F86-0801F768F58F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E840C397-BBC5-42E1-8D35-E9EE78F919E8")!,
                name: "Mail.com",
                issuer: ["Mail.com"],
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Mail.com", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Mail.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "814849A3-C6DA-49AC-B53B-D64C3BA80D92")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E8622066-1148-45AB-8C89-BB81432119A2")!,
                name: "Jovia Financial",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Jovia Financial", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Jovia Financial", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F162831A-4F49-4512-8DEB-06456EC4E123")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E8937E59-D7DF-4020-A345-0B2B638805C3")!,
                name: "BullionVault",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BullionVault", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BullionVault", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "95D2EC85-ACCB-46C6-B71D-1B0B38B51D8E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E899321B-2AA9-44C6-B619-5AACB7955954")!,
                name: "CoinList",
                issuer: ["CoinList"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D5CAA96F-FC26-4B31-94E7-49A17DE8080E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E8A2C1F2-FC4A-4DF2-8076-99575CC27EFB")!,
                name: "Госуслуги (Gosuslugi)",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Госуслуги (Gosuslugi)", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Госуслуги (Gosuslugi)", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "04529752-EF96-4D58-85D7-AA610D99DB86")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E8CF90A1-736D-457A-8E28-8253D1E4A373")!,
                name: "Raindrop.io",
                issuer: ["Raindrop.io"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3D72FA6A-5683-47B1-83D9-33ABFA842AC7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E8EE95B5-5DB9-4C41-A97E-0C6C272E1F47")!,
                name: "E.ON",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "E.ON", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "E.ON", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "74CCBAB4-9ED1-49C4-A3CC-491895EEBBEB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E8FE47DD-95B6-4AB9-B3FC-2F82AA8E8A89")!,
                name: "Luno",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Luno", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Luno", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "851A231D-64E9-4E4D-A05D-1C219E5B3F27")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E9BA90A2-6DDF-458E-A9D7-D1F13B0FD3A0")!,
                name: "Meister",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Meister", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Meister", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FF9E3674-B477-4CD6-9115-C08A119E0C0F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "E9C7E9BA-2269-42F2-A532-7D3ECBC34289")!,
                name: "mailbox.org",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "mailbox.org", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "mailbox.org", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DB778165-44F2-4AEA-A111-1F439B6F9D47")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EA4394E0-779F-49FC-A6D5-17E7212BDA51")!,
                name: "Make",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Make", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Make", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "71C2B71E-DF19-4911-8154-AF4E9A478FBD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EA543918-C254-443B-9CCA-33DB8AA1A21D")!,
                name: "TrendMicro",
                issuer: ["Trend Micro"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "0A26CDEB-A53B-411C-BBCD-48D73F70D3CF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EA7CD947-35FB-4E7A-B639-06BA51BE2A0C")!,
                name: "SendSafely",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SendSafely", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SendSafely", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BD5C9789-92BF-4741-B706-057ED51C85CE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EA9A36FC-711D-48D7-9B51-0E4BDFD7A00D")!,
                name: "Coins.ph",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Coins.ph", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Coins.ph", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1E740253-0B33-4FEB-A825-C4387DCC41D4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EB406CFB-BC68-4EFC-947C-976771F5377F")!,
                name: "Pivotal Tracker",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Pivotal Tracker", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Pivotal Tracker", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "8B4FBC8D-5B1B-4359-9C57-2C33A315CBCF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EB535C31-B47C-4A6D-9B7C-45B7716E1447")!,
                name: "YouHodler",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "YouHodler", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "YouHodler", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "98D4685A-4E7C-465D-930E-5B11CCFBE944")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EB82164F-AA83-44AF-A943-387A0BB19C08")!,
                name: "CoinSpot",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "CoinSpot", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F94290C5-970E-483B-9A7D-F4FE02706FD8")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EB93E63C-BAB4-4E1E-8CFF-916A33BA760A")!,
                name: "Fintegri",
                issuer: ["Fintegri"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "FFAD6E64-14F5-4B1F-B2AA-41232A4EEDF4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EBB4D08F-4A28-4DB8-8395-A929B9E449A7")!,
                name: "Amazon Pay",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "amazon pay", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "amazon pay", matcher: .contains, ignoreCase: true),
.init(field: .issuer, text: "amazon+pay", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "amazon+pay", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4B756B32-40D3-4AE0-B8F8-1B81308DBEAF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EBE7DC06-C1D9-45AD-9BB2-16C7E1685C6D")!,
                name: "Stackfield",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Stackfield", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Stackfield", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "98E17353-A3A1-42C1-B02C-AB168825AD69")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EC0D13E2-3479-49FB-AEAA-67DAB162CADD")!,
                name: "LastPass",
                issuer: ["LastPass"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7D4E81CD-EC45-491D-BE61-18C0652FCF8B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EC1393A0-9205-4706-AD58-193CF8C2FBC1")!,
                name: "HackerOne",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "HackerOne", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "HackerOne", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EC0CF3CF-54AA-47F0-ADD2-16602D1D2D89")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EC30202B-98D9-440F-B376-1635EFD8A67F")!,
                name: "RunCloud",
                issuer: ["RunCloud"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "96B293B5-F4EE-4201-93A5-81C0B73581BF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "ECBFA345-A65A-4516-8A8A-747A12703B7F")!,
                name: "ALL-INKL.COM",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "all-inkl", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "all-inkl", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "B34A23F8-ACCC-43D6-8267-77B3F86C2B60")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "ECF415C1-DB26-43F9-A4DF-BBBACBF1AE96")!,
                name: "Xplenty",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Xplenty", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Xplenty", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4B2CBFE4-1A82-46E0-9895-73418EA33562")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "ED5653F7-109F-4585-B60D-90F8702DFDFA")!,
                name: "Hushmail",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Hushmail", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Hushmail", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E4A960D1-971E-4330-BE1D-E6F9247941BC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "ED5D852E-E2E5-4C96-B640-7FBBFB4165B0")!,
                name: "Passwarden",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Passwarden", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Passwarden", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C26B2C77-4015-4AB1-A796-C3D99FBDBAB9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "ED64D5AF-2641-465F-9936-4C5BC6075695")!,
                name: "Plex",
                issuer: ["Plex"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A29152D6-0AC4-41C6-8CE8-A84C4D87EBEF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EDF4885F-6C13-4C3D-8AA8-378F9177879D")!,
                name: "MEGA",
                issuer: ["MEGA"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2FA5A5BD-FF1B-41DA-9109-25F9EA49F56F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EDF70AD0-18F6-4B38-871A-B128BEA8B725")!,
                name: "East Carolina University",
                issuer: nil,
                tags: ["ECA"],
                matchingRules: [.init(field: .issuer, text: "East Carolina University", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "East Carolina University", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D59F32D3-7BA3-4D92-8566-A81285F1AED2")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EE0B83EE-3920-43FA-83FD-6DBE88C5578D")!,
                name: "Server.pro",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Server.pro", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Server.pro", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EDA4A2E6-F39F-4AFD-BC0A-4B5CD974C447")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EE369040-4AC2-4CEB-9569-1B1C65288A8B")!,
                name: "GoDaddy",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "GoDaddy", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "51C99CC4-9C19-4D9D-8CCB-41C630F5E977")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EE576944-E5F6-4AD1-8840-6C7AD8EB4715")!,
                name: "3Commas",
                issuer: ["3Commas"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "8541F4D5-513F-46E8-BC90-CC13F0764381")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EE678254-FB1E-40CE-9958-862887841A06")!,
                name: "Scripting Helpers",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Scripting Helpers", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Scripting Helpers", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "917DB66B-9FDF-46D6-A43A-0617BE21C2F5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EE8B898B-F406-4DE9-93B6-A9217FA48481")!,
                name: "Stiftung Warentest",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Stiftung Warentest", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Stiftung Warentest", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "63243B77-816B-4F1C-9CCD-092962F2235D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EE990E63-4E8D-4AA5-BE25-FD945108AAAC")!,
                name: "Etsy",
                issuer: ["Etsy"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3D19F274-79D5-450E-9885-E71129CB640E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EED0167A-C72D-4A0F-80C1-5FF560B513CF")!,
                name: "Gitea",
                issuer: ["Gitea"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "1B4D77ED-6DC8-48EC-8382-161F2A1EAF00")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EF153134-36A5-4550-97A0-65F13790359C")!,
                name: "Checkfront",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Checkfront", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Checkfront", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "9116D5FB-116D-464A-B0C5-730FFDD81473")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EF56A8CE-AE58-4327-BEFE-060E010BEBB5")!,
                name: "Prostocash",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Prostocash", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Prostocash", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "55E850B1-8B39-47C2-8A99-DD0E28A3E8AB")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EF68A01C-9118-429B-A68F-F483A749A61D")!,
                name: "Rejoiner",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Rejoiner", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Rejoiner", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "4AB958D7-18BA-47F2-A0D3-DB8BF65F0816")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "EFE98F26-B2D7-49E3-809E-A8AAE8C913B5")!,
                name: "Technische Universität Berlin",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Technische Universität Berlin", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Technische Universität Berlin", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "242322C6-DBB8-40F1-B83E-FA926F4AB4D0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F014153D-C667-4ADD-A05D-C3FA6D6E9561")!,
                name: "American Century Investments",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "American Century Investments", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "American Century Investments", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E43CFE9C-4875-4C29-8EE4-F0EFBCD0FEFC")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F028CE41-346F-48A4-B83C-50A51F2D701E")!,
                name: "Choice",
                issuer: ["Choice By Kingdom Trust"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A85B05BC-2A16-4C57-8A08-17E6C7DBC5F4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F0B52BD0-9D8D-43D1-954D-95E8950D607E")!,
                name: "Cryptonator",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Cryptonator", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Cryptonator", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F77608C2-C56E-4FE8-AADC-5D088B7F2465")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F0DD74A7-28FB-4C77-9541-3D2A2DF53268")!,
                name: "TradingView",
                issuer: ["TradingView"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A0DD2706-8912-4E35-BF7D-8A31B310B323")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F0F1B8DA-8838-4629-962C-9E4EEE5FEC58")!,
                name: "Hevo Data",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Hevo Data", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Hevo Data", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "03E9FF66-A96D-4413-A12A-667B8A9CAADE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F118573D-40E8-46F1-A96F-3F1439FADCD4")!,
                name: "AltoIRA",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "AltoIRA", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "AltoIRA", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DDB9C0A0-0692-4BAA-BB39-7F80E06F7E66")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F13F2163-B024-4DB7-BAAA-8D33E60DD654")!,
                name: "Vivup Benefits",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Vivup Benefits", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Vivup Benefits", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FC96CC55-0DE6-449C-B840-2B145399B581")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F15D2255-4BCD-4943-A0AE-705D96DF97EE")!,
                name: "Credly",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Credly", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Credly", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "AA1A5C28-F93D-4A61-B0D1-94A412860491")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F17EDF5D-BD7F-4ECC-8445-EFEC4E9E7593")!,
                name: "Mintos",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Mintos", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Mintos", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0D3E1D87-06AB-4E79-8CF5-A08C7940A5B1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F1C77692-9282-495D-913A-EF5C5996AE44")!,
                name: "WireGuard",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "wireguard.com", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BB9DA84A-2B56-4160-B2AC-CEF537A20E4F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F1F33335-C739-48EE-8205-4B5BD2D37162")!,
                name: "Kerio",
                issuer: ["kerio"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "F49EFC49-CC3A-4CCD-B796-E4CF38E0174F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F2425ECC-F42A-4F0F-8D39-254FC7AE35BA")!,
                name: "Namecheap",
                issuer: ["Namecheap"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5C80186D-E0ED-4D34-B27D-71BA52E897CF")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F27AF1A5-53FC-44CE-80EA-8FA8C9CA04BC")!,
                name: "F-Secure",
                issuer: ["F-Secure"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "758F71EB-25E7-49E3-8A83-F39A7C24DCD7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F2BEEE5D-1DF3-4A57-AD58-0417DBEA3725")!,
                name: "Meta",
                issuer: ["Meta"],
                tags: ["OCULUS"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7D7C381B-7FEB-4155-991F-074AE53E6BD9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F2C3BF6C-3130-4145-811E-CA864B52B129")!,
                name: "Matrixport",
                issuer: ["Matrixport"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "886B383C-A02A-4566-A618-A0FC0A9E9CD1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F2D06792-362B-4FD6-85FB-5144757A8F40")!,
                name: "MyHeritage",
                issuer: nil,
                tags: ["HERITAGE"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "EF5B7DF4-55D3-49CA-9EC0-93D380302884")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F3379D7D-69ED-4970-9B18-F293B993B829")!,
                name: "Hack The Box",
                issuer: ["Hack The Box"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "78506E72-BBBB-462A-9C04-6B8AC4EE4A7F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F371AF0D-6559-4BDA-9DC9-E0C49FE90F82")!,
                name: "Current RMS",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Current RMS", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Current RMS", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E4B3A960-9742-4151-87AC-D8485F0C5044")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F3BA89B1-68A6-4AD9-BBC4-8555176C98B7")!,
                name: "Mimecast",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Mimecast", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Mimecast", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "005EB58C-4A8F-4F81-936F-DC5543C4E96D")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F3D3486C-AB83-434C-8304-88A7A00E31CB")!,
                name: "Freshworks",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Freshworks", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Freshworks", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F4F8DF6D-5ED7-49FA-9E82-59DF822F05F7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F3DAE646-0CFA-467D-9ECC-06790E1AA6D2")!,
                name: "Samsung",
                issuer: nil,
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "6FFEB8A0-4031-482A-8E00-83262509C864")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F3DC384D-CED9-49BA-BE8A-BDF774A4FDE2")!,
                name: "Scaleway",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Scaleway", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Scaleway", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DD09AE88-EEFA-46F6-935F-FF4154B8D745")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F4308A8D-6983-466B-A51E-345F1C2D4273")!,
                name: "FTX",
                issuer: ["FTX US", "FTX"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "003E95FA-9605-4C93-9628-060415A0C6AA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F4582C15-0A20-4F15-A7AA-700DCA00D02D")!,
                name: "Toodledo",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Toodledo", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Toodledo", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BE6E929B-9FEC-4383-86AD-862E074E0CC0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F478C5EA-D8E6-4325-B418-A84013520D7C")!,
                name: "JURA Elektroapparate AG",
                issuer: ["JURA Elektroapparate AG"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "17367ABA-2F2E-4921-9DF3-279765CF39E0")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F4849B82-E5E5-40FA-BB33-5BE34BB83689")!,
                name: "WB Games",
                issuer: ["WB Games Account"],
                tags: ["WARNER", "BROS", "BROTHERS"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "04164B86-1B37-4DDD-9BB0-0DD46B23C216")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F506D1B4-099D-495E-A1A4-C7ECEC4D007D")!,
                name: "HurricaneElectric",
                issuer: ["ipv6.he.net"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "1D9AF0EC-056C-4D54-9F99-74011DD76DC5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F55C3AB8-86F8-40CC-A6DA-B9CC35A90FF8")!,
                name: "MURAL",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "MURAL", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "MURAL", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "604445D7-9F7C-4ACB-B662-4B17DC18A026")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F580A770-C632-45A0-AF1D-F6B616F0393F")!,
                name: "Envoyer",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Envoyer", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Envoyer", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D239A00C-647A-4E86-8F86-AA8A44FC897E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F5A9A8E5-3167-4B11-A680-03D8AAD50784")!,
                name: "Joomla",
                issuer: ["Joomla"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "FB3F31B8-6EA6-44F9-9129-9094F54FF8F5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F5D5CB4C-6DAA-4926-8891-DD63CC2683C2")!,
                name: "Buhl",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Buhl", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Buhl", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "105803CF-D226-4380-B5E8-F909E4554E8A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F5DB7E54-C559-45E3-A5F9-7686C0951CB9")!,
                name: "VentraIP",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "VentraIP", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "VentraIP", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "FFB1E97E-4757-4595-AFFF-4D881E426043")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F5E3E428-9FF8-4B37-8FB0-CF755E49826D")!,
                name: "Bitbuy",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Bitbuy", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Bitbuy", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C26C74E3-8766-4CA7-BAF5-D0AC72A87394")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F679765A-0626-4AE8-87CA-6F7DC194C77A")!,
                name: "Deel",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Deel", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Deel", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "77678F23-9D59-4519-8F4F-A0A57D89D748")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F6888C4F-4C5B-4027-8B56-8616BAE20AC6")!,
                name: "FastComet",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "FastComet", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "FastComet", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1417FA05-E939-4125-A6F3-E963F6271847")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F6DE2CAF-AA67-4E98-A6AA-3682B826A21C")!,
                name: "BTC Markets",
                issuer: ["BtcMarkets"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2F4917CA-8E34-4271-9E6C-5D234A181A94")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F7309D90-FF20-4107-9587-24D33C0810E8")!,
                name: "Pixieset",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Pixieset", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Pixieset", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "2B110137-A810-4CFF-A2F5-90CA5D252C8E")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F73F0F10-FA7F-471D-980C-7F97A1546688")!,
                name: "DEGIRO",
                issuer: ["DEGIRO"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "38D29122-8FA4-484D-94EE-D10F1A5EFBC3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F762BEA4-D385-4A35-BE4A-FFCDA80931E9")!,
                name: "Hetzner",
                issuer: ["Hetzner"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "86EE7A24-B59A-4F75-B2AA-18BB718B903A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F76DC205-7C4A-4413-B80B-75BF8898502E")!,
                name: "Questrade",
                issuer: ["Questrade"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "46A1E2F1-6949-46F8-8929-92059652E041")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F79B5297-C5BA-499D-B91B-00ECA37DA6BB")!,
                name: "Aruba Instant On",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Aruba Instant On", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Aruba Instant On", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "88639AF3-E04B-45B6-926D-F7791998B823")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F82A02C7-C5AF-4789-95BC-37CDBA23FCCE")!,
                name: "Kriptomat",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Kriptomat", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Kriptomat", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "A1007044-DB32-4ABC-844E-6E684B91BA31")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F8B057B6-472F-4558-958B-3C2DFE6E7163")!,
                name: "University of Otago",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "University of Otago", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "University of Otago", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "05FD202A-986F-449F-BEBF-52F70AA01D5A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F94AA238-33FF-4804-858D-46F2681B1A57")!,
                name: "Nexon",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Nexon", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Nexon", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6870295D-9E5D-48A4-88F0-66DEF67948E5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F956A148-2A36-4906-9F2F-4F07DAEDF566")!,
                name: "SolarWinds",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "SolarWinds", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "SolarWinds", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C3A989DC-0893-49E4-90AC-73CD967B731F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F9E983FD-EBFF-4AB2-AFA7-8A83EAE8DED2")!,
                name: "CloudConvert",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CloudConvert", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CloudConvert", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "ECABA12B-0139-4156-B6EC-2F21BA67EFC1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F9F298EF-7DE4-4CF0-9091-72D1C62104C3")!,
                name: "Crowd Supply",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Crowd Supply", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Crowd Supply", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "77963B50-6FAC-47A5-8157-9082EA989CCE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FA0801C4-E26B-47B2-85B3-8E1F3DCD21C5")!,
                name: "Crypto.com",
                issuer: ["crypto.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "93D4F71F-05E8-4442-885B-24B742BE8459")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FA3812F2-3520-4E6F-9365-246215F59B71")!,
                name: "Skinport",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Skinport", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C8B94125-E8EB-4661-A6C3-D9BD064EDE8A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FA63A7F1-557E-4EDA-813A-274E405F0559")!,
                name: "ArenaNet",
                issuer: ["ArenaNet"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "27A27849-AC36-4374-A156-32CC4E58D464")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FAC857F1-B687-44AE-8C84-3F1D360C830B")!,
                name: "DCS World",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "DCS World", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "DCS World", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D61AF4DC-565E-4E69-A7E6-9DB4A819F220")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FAD4B929-928A-46CE-8E06-8906AC02D20C")!,
                name: "Niagahoster",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Niagahoster", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Niagahoster", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BA8EC043-8A4D-4DB9-BCC6-47A751BE942B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FB29AA88-B20A-41E2-93F5-BD523EFAFD8F")!,
                name: "Wirex",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Wirex", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Wirex", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0894B232-4B02-473B-9FE7-E448127BC3E5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FB2C6356-A37D-4515-A54A-8403471D5885")!,
                name: "Gogs",
                issuer: ["Gogs"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "AE1F5718-AD69-4957-BAD6-CC7FCABC26D4")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FB35F352-AEFB-4FF9-B618-2E7C2FD5C18E")!,
                name: "Blockchains, LLC",
                issuer: ["Blockchains, LLC."],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5F6B8637-D24D-4245-B360-005046E55C70")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FB9C083F-8F5F-42EE-A9A6-8C51A7E5A963")!,
                name: "Fathom",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Fathom", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Fathom", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7403E02F-7CDE-435E-A7A3-74262230979C")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FB9F7BF4-2F57-42F8-BD80-023C1F53B8C2")!,
                name: "Threshold",
                issuer: ["Threshold"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "391C7F84-6909-4019-A1C2-5DC208364ACE")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FBA0F493-CB2A-4F84-914A-CE26B1145782")!,
                name: "CoinStats",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "CoinStats", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "816E759C-2C73-45B7-AD93-702C184CFF77")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FBB55C4D-AAC4-4AA6-BDEE-92290594F0D0")!,
                name: "Cointraffic",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Cointraffic", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Cointraffic", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "01D512E6-F0C1-4744-8015-EC73085575B9")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FBD38226-1C28-4466-B238-54305ED57F3A")!,
                name: "MS 365",
                issuer: nil,
                tags: ["MICROSOFT"],
                matchingRules: [.init(field: .issuer, text: "Microsoft 365", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Microsoft 365", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "246ABEC1-9301-4973-B3F3-428A3BC06D48")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FBEC07EF-F5A6-4754-A160-D151ACE83A20")!,
                name: "Brandwatch",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Brandwatch", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Brandwatch", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "9701F706-B728-4F2F-810C-055EF72F8A5F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FBF7BD09-937B-48F2-81E1-4FF1F3215247")!,
                name: "Technic",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Technic", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Technic", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E7D8C8AC-F74D-45BF-A2A1-5A210DEFC060")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FC65EEAC-5E2C-4134-9EEF-AD4CEC5E7A6F")!,
                name: "Huawei",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Huawei", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Huawei", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "AA50B4AF-BD32-4E4E-98C5-5EC7E046A49A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FC74CD86-C86B-4F8A-963E-BDDC59C4E1C6")!,
                name: "Frame",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Frame", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Frame", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "73AFC6D8-4C4D-46E6-9B36-5862B9B5CCB7")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FC766EFB-E6CB-4718-85B3-8FD1DE572ABE")!,
                name: "BlueSnap",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "BlueSnap", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "BlueSnap", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "633B3D2F-B8C8-4219-83F8-4C3ACCBE4657")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FC7EAF24-EB31-4A86-85C5-D86471EABD11")!,
                name: "System76",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "System76", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "System76", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "0550EC18-8151-446A-B7DF-A0ACDC0B857A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FD322BAB-6431-4E6D-80C7-96A8559543F9")!,
                name: "Pocket",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Pocket", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Pocket", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "7F42621F-55A9-4EE8-A978-3AC9F0797893")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FD842CD6-1CE0-4B09-A7D7-EE10F30845B2")!,
                name: "Razer",
                issuer: ["Razer"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "C4E2D69C-F532-4795-990D-FE380BD517BA")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FD8F0A74-239D-42BF-A537-38CF9CF2C7F2")!,
                name: "Qualifio",
                issuer: ["Qualifio"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "284940C6-710D-473A-A7E5-C9F43001033B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FDB95870-569C-471F-84CE-0356D13DA20E")!,
                name: "Google",
                issuer: ["Google"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "66190B0F-9600-4A6F-B06B-33254B5316AD")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FDC49D4E-9001-4734-AE81-214CC74FFA10")!,
                name: "Coincheck",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Coincheck", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Coincheck", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "9F0CF664-B0A5-4174-9F16-E55B49BB8289")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FDE0ED28-9EDB-487A-ACBC-D8C5E91DAF7D")!,
                name: "Kite",
                issuer: ["kite"],
                tags: ["ZERODHA"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "1A0ADFA5-37EA-4315-8B48-EE1D7297B1B1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FDF8841C-9B3B-46DB-9E9F-5315015B733D")!,
                name: "hide.me VPN",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "hide.me VPN", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "hide.me VPN", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "226E9A72-47BB-455A-8F08-92A26740723A")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FE4A7604-1485-4F78-81EA-2DAE5C34FC2A")!,
                name: "Dext Prepare",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Dext Prepare", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "Dext Prepare", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "07EB5464-2DD9-4E65-831D-F349652D2A5F")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FEDBF513-6136-460B-970D-FC468637C64E")!,
                name: "InMotion Hosting",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "InMotion Hosting", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "InMotion Hosting", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "92636822-E01F-4479-B079-833A32F52103")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FF0B65AA-FF15-4E42-BA4C-BD04A281F509")!,
                name: "Parallels",
                issuer: ["Parallels"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "EC02758E-B344-4E99-8AA6-BB4436CAD989")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FF0ED7B6-0716-46FA-8646-052883572F1F")!,
                name: "Roberts Space Industries",
                issuer: ["Roberts Space Industries"],
                tags: ["RSI"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7C4A3FA2-5A2D-43E0-B87E-5C3628EAE326")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FF328FDC-AE0B-4D95-92D4-7B7CA4266F65")!,
                name: "CoinTracking",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "CoinTracking", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "CoinTracking", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "52074C1A-8FEA-49AB-BDA7-E2551021D957")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "FFE11441-947F-47EB-97EB-C4FE99F2CCFA")!,
                name: "University of Groningen",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "University of Groningen", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "University of Groningen", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "1A570717-7B28-4311-B1AA-B1CB265C1B27")!
            )]}()
}
// swiftlint:enable all