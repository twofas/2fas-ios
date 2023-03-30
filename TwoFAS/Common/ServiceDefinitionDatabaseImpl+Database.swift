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
                serviceTypeID: UUID(uuidString: "002FD04D-4046-4629-952B-EE92F17E2E09")!,
                name: "IONOS",
                issuer: ["IONOS"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A70BEA5A-EA3A-46C0-BAAF-E837A66AAC19")!
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
                serviceTypeID: UUID(uuidString: "0336ADDA-650E-4082-A24B-4A2165C3A043")!,
                name: "USPTO",
                issuer: ["MyUSPTO"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "13838D86-6882-4851-81C1-272B128FEB5D")!
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
                serviceTypeID: UUID(uuidString: "03BC1020-723F-445E-B9A8-530B8C37CC71")!,
                name: "Stackhero",
                issuer: ["Stackhero"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "236F8CE2-36D4-4C65-A7DB-645B2BE0261E")!
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
                serviceTypeID: UUID(uuidString: "0642640D-52F8-4D2A-BA7F-B2E98DCC4760")!,
                name: "Tibia",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Tibia", matcher: .equals, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "9A59764B-6E14-469C-AA17-D78652774DBE")!
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
                serviceTypeID: UUID(uuidString: "0847B922-D5EE-478D-8705-FC661DC2E83A")!,
                name: "Upwork",
                issuer: ["Upwork"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "890AD18D-FF18-4AAC-BEB4-9311D9941019")!
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
                serviceTypeID: UUID(uuidString: "0A48F587-2D81-494A-BCDB-A01569F81453")!,
                name: "SimpleLogin",
                issuer: ["SimpleLogin"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2ED9942B-DAEC-491A-871E-0C01E77E0722")!
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
                serviceTypeID: UUID(uuidString: "0C9BC1B5-147A-41AF-A9AC-68687275A9D7")!,
                name: "Hypixel",
                issuer: ["Hypixel - Minecraft Server and Maps"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "942FDE6E-E260-4C0A-8C60-3EBAE7251352")!
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
                serviceTypeID: UUID(uuidString: "0E479FCD-6A38-4431-9605-8A3D8B260E29")!,
                name: "HMRC",
                issuer: ["Government Gateway", "HMRC", "GovernmentGateway"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E176C886-93FE-44F9-B6D8-A22BD522A396")!
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
                serviceTypeID: UUID(uuidString: "137459FD-0F05-489A-95AF-FD0245C3FA0E")!,
                name: "Bitpay",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "[bitpay]", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "D85626DD-C037-44CF-B841-425AF012457C")!
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
                serviceTypeID: UUID(uuidString: "14E45151-0724-48C1-8D71-F262202307C7")!,
                name: "(ISC)2",
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
                serviceTypeID: UUID(uuidString: "15FC4637-25C0-416E-9FCC-AFE99DAB8ABE")!,
                name: "Drupal",
                issuer: ["drupal"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "07F84AB8-8A93-4F0B-BC3B-00C20A3DFEC9")!
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
                serviceTypeID: UUID(uuidString: "1B35B8EE-DE08-4623-8BE9-9A52D3606A08")!,
                name: "Activision",
                issuer: ["Activision"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D4FEF7D5-65CF-4156-BC04-98F9767B78BF")!
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
                serviceTypeID: UUID(uuidString: "1C6EF27D-7D4B-4827-9D8F-8AECCE460008")!,
                name: "Docker",
                issuer: ["hub.docker.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "8D3B0A32-4A3E-445C-B1C3-0529BDE24AA5")!
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
                serviceTypeID: UUID(uuidString: "1D3774AA-BD1A-4D57-B453-5EF78943233B")!,
                name: "Arbeitsagentur",
                issuer: ["arbeitsagentur.de"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "323F26E2-52A2-438D-89C7-8318133499BB")!
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
                serviceTypeID: UUID(uuidString: "1EAFB2B3-17D9-417F-8D1D-AFB6D9ACA878")!,
                name: "Pulseway",
                issuer: ["Pulseway"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "12A96D37-ECC7-4DCE-B36E-9249A89D343C")!
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
                serviceTypeID: UUID(uuidString: "1FBB656A-53A2-4FA1-AA1C-3D04E8A7A122")!,
                name: "Hostinger",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Hostinger", matcher: .contains, ignoreCase: true),
.init(field: .issuer, text: "Hostinger", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "6BC04722-2A84-4320-BB7A-B2FEE8C8368E")!
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
                serviceTypeID: UUID(uuidString: "234BE581-45E1-41D5-98FB-D8EC4201B33E")!,
                name: "WIX",
                issuer: ["WIX"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "386356BA-0FEB-4ACA-8074-DD9B38E0E664")!
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
                serviceTypeID: UUID(uuidString: "24C038C9-41B6-46B2-BAFD-046FC074EF54")!,
                name: "Karatbit",
                issuer: ["Karatbit"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "B887CA8F-06DC-4D85-9990-03C1DEA2060F")!
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
                serviceTypeID: UUID(uuidString: "26AC0A8E-28AB-43E0-B93A-C728DF165800")!,
                name: "Telderi",
                issuer: ["Telderi"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "C5981A81-FF16-4D3F-ABB2-E297140DB537")!
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
                serviceTypeID: UUID(uuidString: "29266734-6296-49CE-BF2E-B346762B5B42")!,
                name: "Mercado Livre",
                issuer: ["Mercado Livre"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5CB7030D-45E2-45A4-B8C6-2B5D61A3783E")!
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
                serviceTypeID: UUID(uuidString: "29A9BB30-C40F-4B43-8877-2460915178C5")!,
                name: "1Password",
                issuer: ["1Password"],
                tags: ["ONE", "PASSWORD"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "13ADF493-63A7-4582-9FFA-B1BBAC783D67")!
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
                serviceTypeID: UUID(uuidString: "2BBA5977-2AD5-4F10-A576-9B536FFDB99B")!,
                name: "ARIN",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "arin", matcher: .startsWith, ignoreCase: true),
.init(field: .label, text: "arin", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BB32B5EA-54FB-4D7F-AE6A-85FC5D319EB9")!
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
                tags: nil,
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
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "780EE78B-A61B-46F3-9FAA-0B6CF3F7479D")!
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
                serviceTypeID: UUID(uuidString: "35498C4E-19AE-4E2B-92DE-B110BAACE547")!,
                name: "WhiteBIT",
                issuer: ["WhiteBIT"],
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "WhiteBIT", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DF2FF12E-CE9B-4F16-842E-7D1C33960E89")!
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
                serviceTypeID: UUID(uuidString: "3842FBA8-47C3-45BB-9700-932E86721063")!,
                name: "Norton",
                issuer: ["NortonLifeLock"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A659E300-C8B3-4DB3-8D11-2DDB1C46CEB8")!
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
                serviceTypeID: UUID(uuidString: "3A26C02C-1C6E-49BA-B282-C640F6C05804")!,
                name: "WEB.DE",
                issuer: ["WEB.DE"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3AF6D11F-D879-4649-B183-20C5742F20DD")!
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
                serviceTypeID: UUID(uuidString: "3B0C488C-BD30-4EDF-9441-8A6F97791124")!,
                name: "Proxmox",
                issuer: ["Proxmox"],
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Proxmox", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "EF5373E1-D53A-44C2-8DF8-FDB35BD76CCC")!
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
                serviceTypeID: UUID(uuidString: "3C9FB79F-A473-47EB-AA75-F5EF5B35829B")!,
                name: "Ubisoft",
                issuer: ["Ubisoft"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "EAC7EF2F-0DB9-4227-9D59-2745DC99ADB5")!
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
                serviceTypeID: UUID(uuidString: "3EC08D85-D803-4B6A-A2F4-F5D24C9BBA67")!,
                name: "GitHub",
                issuer: ["GitHub"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "FFF32440-F5BE-4B9C-B471-F37D421F10C3")!
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
                serviceTypeID: UUID(uuidString: "3EEE1A70-692E-4105-8DB8-3628A7B6A590")!,
                name: "Todoist",
                issuer: ["Todoist"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D45EAD47-367B-44C0-B258-69D73FF7443C")!
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
                serviceTypeID: UUID(uuidString: "413A4CC5-BA05-4004-BC54-06DF1A671926")!,
                name: "Matomo",
                issuer: nil,
                tags: ["ANALYTICS"],
                matchingRules: [.init(field: .issuer, text: "Matomo Analytics", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C5D27BFB-74AC-4459-9C73-2E58A106ADE3")!
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
                serviceTypeID: UUID(uuidString: "450CAB07-490E-4645-A336-126A798314AE")!,
                name: "Kraken",
                issuer: ["kraken.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "96D6723E-B5D2-4B90-9CE3-BCCB3F919642")!
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
                serviceTypeID: UUID(uuidString: "46D677EA-9678-4D03-A737-D53750C97F91")!,
                name: "Ubuntu",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "UbuntuSSO", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "DBF20573-1304-4D12-BE11-13C590FF1FC1")!
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
                serviceTypeID: UUID(uuidString: "49B75004-2EE0-46DE-934E-F62E9271BD02")!,
                name: "Synology",
                issuer: ["Synology DSM", "Synology Account"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "1287CDAB-814B-469F-A718-8C7775643099")!
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
                serviceTypeID: UUID(uuidString: "4C1FAA51-FEFB-4AB5-9201-C54B794D32BA")!,
                name: "Zendesk",
                issuer: ["Zendesk"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "96F65174-F24D-4A85-A89E-89FCF4CC7EE3")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "4CB1849D-650C-48FF-BD99-420859F3D1C8")!,
                name: "EA",
                issuer: ["Electronic Arts"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "0B032D00-41C4-4821-90A9-B18B8C27074A")!
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
                serviceTypeID: UUID(uuidString: "510E06DE-8861-44A0-A4B4-831F8392B097")!,
                name: "Hostpoint",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "Hostpoint", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "F70FF97E-E4B1-46AE-B8DE-69795CD9EF04")!
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
                serviceTypeID: UUID(uuidString: "5318083F-0330-4384-869F-8C76AD862337")!,
                name: "Chargebee",
                issuer: ["Chargebee"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "400FCED8-6FAC-488A-8154-85BE47D84ABE")!
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
                serviceTypeID: UUID(uuidString: "54F6272F-E6C1-4A88-8E2C-A1B0A490C55D")!,
                name: "BackBlaze",
                issuer: ["Backblaze"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D92BDE37-A6D6-475E-B71E-ADB362EFA18A")!
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
                serviceTypeID: UUID(uuidString: "56CC9FC0-0F57-4777-A3E0-CCAAD03234A8")!,
                name: "Mercado Libre",
                issuer: ["Mercado Libre"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5CB7030D-45E2-45A4-B8C6-2B5D61A3783E")!
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
                serviceTypeID: UUID(uuidString: "588921BF-6DF7-4D92-A881-9AF92E15642B")!,
                name: "Instagram",
                issuer: ["Instagram"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "F4CAD0B9-00D5-420C-804C-D41CE8825EED")!
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
                serviceTypeID: UUID(uuidString: "5B545E9A-9F41-4296-93A7-10B5336B8845")!,
                name: "Call of Duty",
                issuer: nil,
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3A70FCC1-A406-4212-BD0C-440DBE6AE824")!
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
                serviceTypeID: UUID(uuidString: "5D4710E6-1EB7-4D29-B1AA-1C416A20773D")!,
                name: "ClouDNS",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "ClouDNS", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "E4CA9FB2-281D-4146-9DD3-083899D1515D")!
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
                serviceTypeID: UUID(uuidString: "5FAC27E0-E0E4-4E5C-BA7C-54CA0C5F1482")!,
                name: "Coinbase",
                issuer: ["Coinbase"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5BD3CBD6-32B6-41F0-BAA3-3FCCAF624269")!
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
                serviceTypeID: UUID(uuidString: "62E56D6C-C438-4949-A033-C7588B92E403")!,
                name: "Trello",
                issuer: ["Trello"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "AF39F910-F20F-4210-9F02-4D91AE108FC7")!
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
                serviceTypeID: UUID(uuidString: "63F0BDAF-94FE-4B4C-983F-90442877F0EC")!,
                name: "Uber",
                issuer: ["Uber"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "B73CC164-8763-4826-8603-0C79F08A1EB5")!
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
                serviceTypeID: UUID(uuidString: "66917FB1-38A9-4AE7-95E6-F0EC44746D05")!,
                name: "Storj",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "STORJ", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "C6360125-33FE-492A-A2CD-57DD72C18CD3")!
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
                serviceTypeID: UUID(uuidString: "699C584E-79CF-414B-94D5-64784459F7ED")!,
                name: "Bitrise",
                issuer: ["bitrise.io"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7EB65E52-5408-4F85-8500-1DA6AECAC467")!
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
                serviceTypeID: UUID(uuidString: "6BE22AFD-1D40-4375-B5DA-5581B886EDB8")!,
                name: "Bitvavo",
                issuer: ["Bitvavo"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D0785C6F-C7B9-4F15-8521-2162F44F645C")!
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
                serviceTypeID: UUID(uuidString: "6DC6C359-75A2-48CA-82E7-CF6AC8D98A68")!,
                name: "Poloniex",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "@poloniex.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "BB70EE48-AE34-40C2-BF4C-E941ED9E04F1")!
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
                serviceTypeID: UUID(uuidString: "7143FD13-09A8-4256-9BEF-B1055689A8B5")!,
                name: "Neeva",
                issuer: ["login.neeva.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5D6912B0-60C3-4794-848C-A15EED8BAA65")!
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
                serviceTypeID: UUID(uuidString: "744E788D-3975-43AC-8166-0029C9A0871C")!,
                name: "Facebook",
                issuer: ["Facebook"],
                tags: ["FB"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2100A131-7869-4CA6-B476-F1FC0EF103BF")!
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
                serviceTypeID: UUID(uuidString: "79549405-BA55-4C7B-9D48-3B15002B5B30")!,
                name: "EnZona",
                issuer: ["ENZONA"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D506BFDD-D5CA-4AB4-A4C1-960B445226F4")!
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
                serviceTypeID: UUID(uuidString: "7BD710EA-F376-48D8-AD1F-A0C02ECC3037")!,
                name: "NeoGAF",
                issuer: ["NeoGAF"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "50B56493-7D97-48BF-AE85-CAFB69265FE5")!
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
                serviceTypeID: UUID(uuidString: "7D012425-7019-4320-90A5-38963E4A022E")!,
                name: "Brave",
                issuer: ["Brave+Rewards", "Brave Rewards"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E4E7DA2F-3D8B-4686-8C2C-FD94A23864AD")!
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
                serviceTypeID: UUID(uuidString: "7EC6284A-152F-4AC6-A702-95A21BFB7E02")!,
                name: "IFTTT",
                issuer: ["IFTTT"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "C5879187-E23D-4700-93F3-A6F868ACABAC")!
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
                serviceTypeID: UUID(uuidString: "7FC06C13-D09B-40DA-A740-099CC0743DA8")!,
                name: "Help Scout",
                issuer: ["Help Scout"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "DBEDB8F2-02A7-48C5-A41F-A009B989430C")!
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
                serviceTypeID: UUID(uuidString: "82577EDC-F9B1-4B6F-9FB8-C242A35E2408")!,
                name: "HS Fulda",
                issuer: ["horstl"],
                tags: ["HOCHSCHULE", "FULDA"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "EC2DF1EC-7B6E-4BB7-A220-37DCCA841030")!
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
                tags: nil,
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
                serviceTypeID: UUID(uuidString: "87243AA3-1FA8-4263-B6B1-DC4659BB5AEF")!,
                name: "GM",
                issuer: ["General Motors Security Team"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A2B78D57-46C7-49F9-9D28-0F3C58E35BE5")!
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
                serviceTypeID: UUID(uuidString: "882C9046-B11F-4F4F-9F66-7095202A03A7")!,
                name: "RoboForm",
                issuer: ["RoboForm"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "B541B6BB-1921-418B-91C8-AD911062B736")!
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
                serviceTypeID: UUID(uuidString: "8BA7B1EB-C080-444D-815F-BF05CB909D00")!,
                name: "Termius",
                issuer: ["Termius"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "4436B171-7E38-4AD8-9E5F-D0D5CE411EB4")!
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
                serviceTypeID: UUID(uuidString: "8D2B7CFD-2D6E-4A82-AF14-4D60924ABF84")!,
                name: "Skrill",
                issuer: ["Skrill"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "6F8B55B6-D7BB-4691-BDA2-2B1DE39FB448")!
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
                serviceTypeID: UUID(uuidString: "8E6B9EEA-CE00-4371-884A-B540B3467950")!,
                name: "Figma",
                issuer: ["Figma"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "3F24378A-AB65-4034-AE7F-B13F624DE766")!
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
                serviceTypeID: UUID(uuidString: "90A4ED41-A143-4681-A324-B57F21683061")!,
                name: "Quickbooks Online",
                issuer: nil,
                tags: ["INTUIT"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "DBCCF2F4-2073-479C-A655-FE19DAF4AC2C")!
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
                serviceTypeID: UUID(uuidString: "94712FF8-BBE1-41BC-8B81-0F0395463E88")!,
                name: "Login.gov",
                issuer: ["Login.gov"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "8AD7697B-6782-47E4-A9FB-8E07499825BA")!
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
                serviceTypeID: UUID(uuidString: "97B7C609-EDCE-400D-B0CE-A1894AC4305B")!,
                name: "OpenVPN",
                issuer: ["OpenVPN"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "91A3EDA0-5906-4BA9-BA03-5C6C584C55AB")!
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
                serviceTypeID: UUID(uuidString: "9DA37985-6D4E-4E30-A2CC-449BA401D8CF")!,
                name: "Opera",
                issuer: ["auth.opera.com"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7D835694-5335-41C1-985D-EEC3A1836FEE")!
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
                serviceTypeID: UUID(uuidString: "9E654A3A-DE47-4BFE-8014-1680FCE77452")!,
                name: "Hotbit",
                issuer: ["HOTBIT"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "6BB5522A-8979-4A04-8C72-A59552268A23")!
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
                serviceTypeID: UUID(uuidString: "A074D141-F92E-4521-971F-63304A45FEDF")!,
                name: "Skiff",
                issuer: ["Skiff"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "75595AD0-66C7-4BFC-A47D-99C001A4DF12")!
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
                serviceTypeID: UUID(uuidString: "A2987AB4-AC5C-48CE-863C-D3D3D1220FDB")!,
                name: "Twitter",
                issuer: ["Twitter"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "9889F776-434D-46AB-97EE-EF2AD88FE615")!
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
                serviceTypeID: UUID(uuidString: "A5ED7742-3798-40F6-AFFC-8BB459AF80EA")!,
                name: "Uphold",
                issuer: ["Uphold"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "4A3BF3C0-68C8-4AA7-809C-C3962EA0C564")!
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
                serviceTypeID: UUID(uuidString: "A7516A9C-2DBD-4ABA-8E9D-50A6D8815C7D")!,
                name: "Fly",
                issuer: ["Fly.io"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "75D24465-2516-4598-A709-D28BBC17337B")!
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
                serviceTypeID: UUID(uuidString: "AB5170D5-098B-4D87-A248-64BADB66CFB3")!,
                name: "Parsec",
                issuer: ["Parsec"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A850B2E8-1F72-4A6E-85F7-9023BC57C75F")!
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
                serviceTypeID: UUID(uuidString: "B235239B-0FF5-4D74-BABB-3A76E8DCE4EB")!,
                name: "GMX",
                issuer: ["GMX"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "DCFA66E0-BEEE-4560-9946-1096A804C913")!
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
                serviceTypeID: UUID(uuidString: "B6B72488-1F7B-431D-AFE0-4889496DEB70")!,
                name: "Oracle Cloud",
                issuer: ["Oracle"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "910890DB-0DA8-4D54-B0A0-D7BABF811ADE")!
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
                serviceTypeID: UUID(uuidString: "B78BBA1B-4733-42BC-A1D5-CA18D53E291F")!,
                name: "Paxful",
                issuer: ["Paxful"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "AD3E5352-FBDA-400D-B891-E21DDEC8295E")!
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
                serviceTypeID: UUID(uuidString: "B8869267-E0A5-407C-9B77-8C664896B252")!,
                name: "Windscribe",
                issuer: ["Windscribe"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A538ADE5-25F9-4D84-B908-39495B168B47")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "B8CCC448-1C97-4D5C-A781-25C48996B00F")!,
                name: "Sony",
                issuer: ["Sony"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2DC7DD80-1B1E-420B-92EE-838298DE29A9")!
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
                serviceTypeID: UUID(uuidString: "BB0CF5E7-D66F-442A-9F15-1623CFCFC57E")!,
                name: "cPanel",
                issuer: nil,
                tags: ["HOSTING", "PANEL"],
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "AE7EBA01-F217-4138-9389-0DBAC94A8F7E")!
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
                serviceTypeID: UUID(uuidString: "BD82B421-51CF-436F-86E9-B9C98487F439")!,
                name: "Filen",
                issuer: ["Filen"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "5C7ADBB7-3438-424B-A7D9-F82B7360516C")!
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
                tags: nil,
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
                serviceTypeID: UUID(uuidString: "C103519F-E4FE-4C5A-9C75-E55B42D94A17")!,
                name: "AnonAddy",
                issuer: ["AnonAddy"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "928647E4-14DE-434A-8210-817202D36D73")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C1CA5186-2E6D-4D70-B8C9-A5410B791664")!,
                name: "Stake",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Stake.com", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5430258C-8064-46BB-9ADF-9A36E276407B")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "C27A237E-D224-402E-B40C-FC307942EAA6")!,
                name: "Huawei",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "huawei", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "5425AC27-455D-42EB-9163-3A1262B11698")!
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
                serviceTypeID: UUID(uuidString: "C3CF42DF-5F28-4812-A954-7364473D5723")!,
                name: "VMware",
                issuer: ["VMware+Cloud+Services", "VMware Cloud Services"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "91779097-9EE2-4E9D-A208-20D3D01D1643")!
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
                serviceTypeID: UUID(uuidString: "C62E1EA9-E2D8-4742-A6A9-D9B3527A068A")!,
                name: "15Five",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .issuer, text: "15Five", matcher: .contains, ignoreCase: true),
.init(field: .label, text: "15Five", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "978354B2-AF33-440D-BC4D-97D95024ED31")!
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
                serviceTypeID: UUID(uuidString: "C748E680-902E-42CE-AB81-251C01759C52")!,
                name: "Wealthify",
                issuer: ["Wealthify"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "67628C98-1593-453F-B0D8-E0DED0F9947B")!
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
                serviceTypeID: UUID(uuidString: "C8EBF624-C4D2-4E6A-AEAC-FC235494AB92")!,
                name: "Cloudflare",
                issuer: ["Cloudflare"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7E40BA1B-12C4-46B5-B74D-AB362C21494A")!
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
                serviceTypeID: UUID(uuidString: "D0304FA7-F304-40E2-93C4-B4D4D3E95486")!,
                name: "Cisco Meraki",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "Meraki", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "30D5083A-E9FD-43C0-A011-698E431FB409")!
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
                serviceTypeID: UUID(uuidString: "D1F4FD42-38E0-4D8D-9FF4-4F1F7D9F0A8E")!,
                name: "Rubrik",
                issuer: ["Rubrik"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "E4C14F12-668C-49FC-B0B5-DEC9830E5CE1")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "D241EDFF-480F-4201-840A-5A1C1D1323C2")!,
                name: "STEAM",
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
                serviceTypeID: UUID(uuidString: "D4EABA7A-4FB0-4447-96B1-005FBF8CDF38")!,
                name: "Heroku",
                issuer: ["Heroku"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "EAFABE79-26CB-43F3-B2CF-027D155407A9")!
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
                serviceTypeID: UUID(uuidString: "D6570704-868F-4CCA-990F-3F0FDCEAE277")!,
                name: "Bybit",
                issuer: ["Bybit"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "0187C518-0EDC-4892-9FB5-46C10C7AC16B")!
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
                serviceTypeID: UUID(uuidString: "DAD21619-8E8D-44FD-9B85-A4CC8D6B56DA")!,
                name: "MyAnimeList",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "myanimelist", matcher: .startsWith, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "90BB2F2C-C3CE-4B07-9A12-44FCEBD6170E")!
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
                serviceTypeID: UUID(uuidString: "DEEAD8DD-C9E3-463A-8C73-1E75C5EC13CF")!,
                name: "Rockstar Games",
                issuer: ["Rockstar+Games", "Rockstar Games"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "FCB5345A-DACD-4898-884D-162C8263FD62")!
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
                serviceTypeID: UUID(uuidString: "E0D3D638-1FA2-4AA4-8242-4920BD151226")!,
                name: "Blockchain.com",
                issuer: ["blockchain.info"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "01F35A89-4444-4208-A405-C914340DF362")!
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
                serviceTypeID: UUID(uuidString: "E3A1EE7B-B689-43A7-A88C-DE98C793B2A5")!,
                name: "Zapier",
                issuer: ["Zapier"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7F76CD41-6022-409A-9253-E399CDE29B88")!
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
                serviceTypeID: UUID(uuidString: "E5DEE7B9-C921-41ED-8B24-E74C6B72DAA8")!,
                name: "Square Enix",
                issuer: ["Square Enix ID"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "02B0A535-36C4-46D3-9273-22DBF5236CE8")!
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
                serviceTypeID: UUID(uuidString: "E899321B-2AA9-44C6-B619-5AACB7955954")!,
                name: "CoinList",
                issuer: ["CoinList"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "D5CAA96F-FC26-4B31-94E7-49A17DE8080E")!
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
                serviceTypeID: UUID(uuidString: "EC0D13E2-3479-49FB-AEAA-67DAB162CADD")!,
                name: "LastPass",
                issuer: ["LastPass"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7D4E81CD-EC45-491D-BE61-18C0652FCF8B")!
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
                serviceTypeID: UUID(uuidString: "F028CE41-346F-48A4-B83C-50A51F2D701E")!,
                name: "Choice",
                issuer: ["Choice By Kingdom Trust"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "A85B05BC-2A16-4C57-8A08-17E6C7DBC5F4")!
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
                name: "Meta Oculus",
                issuer: ["Meta"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "7D7C381B-7FEB-4155-991F-074AE53E6BD9")!
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
                serviceTypeID: UUID(uuidString: "F3DAE646-0CFA-467D-9ECC-06790E1AA6D2")!,
                name: "Samsung",
                issuer: nil,
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "6FFEB8A0-4031-482A-8E00-83262509C864")!
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
                serviceTypeID: UUID(uuidString: "F5A9A8E5-3167-4B11-A680-03D8AAD50784")!,
                name: "Joomla",
                issuer: ["Joomla"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "FB3F31B8-6EA6-44F9-9129-9094F54FF8F5")!
            ),
            .init(
                serviceTypeID: UUID(uuidString: "F6DE2CAF-AA67-4E98-A6AA-3682B826A21C")!,
                name: "BTCMarkets",
                issuer: ["BtcMarkets"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "2F4917CA-8E34-4271-9E6C-5D234A181A94")!
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
                serviceTypeID: UUID(uuidString: "FBA0F493-CB2A-4F84-914A-CE26B1145782")!,
                name: "CoinStats",
                issuer: nil,
                tags: nil,
                matchingRules: [.init(field: .label, text: "CoinStats", matcher: .contains, ignoreCase: true)],
                iconTypeID: UUID(uuidString: "816E759C-2C73-45B7-AD93-702C184CFF77")!
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
                serviceTypeID: UUID(uuidString: "FDB95870-569C-471F-84CE-0356D13DA20E")!,
                name: "Google",
                issuer: ["Google"],
                tags: nil,
                matchingRules: nil,
                iconTypeID: UUID(uuidString: "66190B0F-9600-4A6F-B06B-33254B5316AD")!
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
            )]}()
}