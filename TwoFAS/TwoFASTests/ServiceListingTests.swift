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
@testable import Common
@testable import Storage

final class ServiceListingTests: XCTestCase {
    private struct Item: ServiceListable, Equatable {
        let name: String
        var additionalInfo: String?
        var serviceTypeID: ServiceTypeID?
        
        init(_ name: String, info: String? = nil, type: ServiceTypeID? = nil) {
            self.name = name
            self.additionalInfo = info
            self.serviceTypeID = type
        }
    }
    
    private func names(_ items: [Item]) -> [String] { items.map(\.name) }
    
    func testFilterMatchesNameCaseInsensitively() {
        let items = [Item("Google"), Item("Amazon")]
        XCTAssertEqual(names(ServiceListing.filter(items, phrase: "goo", ids: [])), ["Google"])
    }
    
    func testFilterMatchesAdditionalInfo() {
        let items = [Item("A", info: "john@example.com"), Item("B", info: nil), Item("C", info: "other")]
        XCTAssertEqual(names(ServiceListing.filter(items, phrase: "JOHN", ids: [])), ["A"])
    }
    
    func testFilterHandlesDiacriticsAndEmoji() {
        XCTAssertEqual(names(ServiceListing.filter([Item("ŻÓŁW")], phrase: "żółw", ids: [])), ["ŻÓŁW"])
        XCTAssertTrue(ServiceListing.filter([Item("Żółw")], phrase: "zolw", ids: []).isEmpty)
        XCTAssertEqual(names(ServiceListing.filter([Item("Klucz 🔑")], phrase: "🔑", ids: [])), ["Klucz 🔑"])
    }
    
    func testFilterByIdsOnlyWhenPhraseEmpty() {
        let id = UUID()
        let items = [Item("A", type: id), Item("B", type: UUID()), Item("C")]
        XCTAssertEqual(names(ServiceListing.filter(items, phrase: "", ids: [id])), ["A"])
        XCTAssertEqual(names(ServiceListing.filter(items, phrase: nil, ids: [id])), ["A"])
    }
    
    func testFilterPhraseOrIds() {
        let id = UUID()
        let items = [Item("Google"), Item("Other", type: id), Item("Amazon")]
        XCTAssertEqual(names(ServiceListing.filter(items, phrase: "goo", ids: [id])), ["Google", "Other"])
    }
    
    func testNoFilterWhenPhraseAndIdsEmpty() {
        let items = [Item("A"), Item("B")]
        XCTAssertEqual(ServiceListing.filter(items, phrase: nil, ids: []), items)
        XCTAssertEqual(ServiceListing.filter(items, phrase: "", ids: []), items)
    }
    
    func testSortAZUsesLocalizedStandardCompare() {
        let items = [Item("item 10"), Item("item 2"), Item("Item 1")]
        XCTAssertEqual(names(ServiceListing.sort(items, by: .az)), ["Item 1", "item 2", "item 10"])
    }
    
    func testSortAZTieBreaksByAdditionalInfoNilFirst() {
        let items = [Item("A", info: "b"), Item("A", info: nil), Item("A", info: "a")]
        XCTAssertEqual(ServiceListing.sort(items, by: .az).map(\.additionalInfo), [nil, "a", "b"])
    }
    
    func testSortZAReversesWithNilLast() {
        let items = [Item("A", info: "b"), Item("B"), Item("A", info: nil), Item("A", info: "a")]
        let sorted = ServiceListing.sort(items, by: .za)
        XCTAssertEqual(names(sorted), ["B", "A", "A", "A"])
        XCTAssertEqual(sorted.map(\.additionalInfo), [nil, "b", "a", nil])
    }
    
    func testManualSortKeepsInputOrder() {
        let items = [Item("C"), Item("A"), Item("B")]
        XCTAssertEqual(ServiceListing.sort(items, by: .manual), items)
    }
}
