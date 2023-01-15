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

final class CommonSearchBar: UISearchBar {
    private var shouldEndEditing = true
    
    var dataSource: CommonSearchDataSourceSearchable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        placeholder = T.Tokens.searchServiceTitle
        delegate = self
        barStyle = .default
        searchBarStyle = .minimal
        tintColor = Theme.Colors.Fill.theme
        barTintColor = Theme.Colors.Fill.theme
        sizeToFit()
    }
    
    func dismiss() {
        guard let text, !text.isEmpty else {
            clear()
            return
        }
        shouldEndEditing = true
        resignFirstResponder()
    }
    
    func clear() {
        text = ""
        shouldEndEditing = true
        dataSource?.clearSearchPhrase()
        resignFirstResponder()
    }
}

extension CommonSearchBar: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        shouldEndEditing = false
        dataSource?.setSearchPhrase(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        shouldEndEditing = true
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clear()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        if shouldEndEditing {
            return true
        } else {
            shouldEndEditing = true
            return false
        }
    }
}
