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
import Data

final class GuidePagePresenter: ObservableObject {
    var totalPages: Int {
        menu.pages.count
    }

    var image: UIImage {
        currentPage.image.icon
    }
    
    var buttonTitle: String {
        switch buttonType {
        case .manually(let title, _): return title
        case .scanner(let title): return title
        case .next: return T.Commons.next
        }
    }
    
    var serviceName: String {
        menu.serviceName
    }
    
    var buttonIcon: UIImage? {
        switch buttonType {
        case .scanner: return Asset.smallQRCodeIcon.image
        default: return nil
        }
    }
    
    var content: AttributedString {
        var str = currentPage.content
        str.foregroundColor = Theme.Colors.Text.main
        return str
    }
    
    private var buttonType: GuideDescription.Page.CTA {
        currentPage.cta
    }
    
    private var currentPage: GuideDescription.Page {
        menu.pages[pageNumber]
    }
    
    private let flowController: GuidePageFlowControlling
    private let menu: GuideDescription.MenuPosition
    let pageNumber: Int
    
    init(flowController: GuidePageFlowControlling, menu: GuideDescription.MenuPosition, pageNumber: Int) {
        self.flowController = flowController
        self.menu = menu
        self.pageNumber = pageNumber
    }
    
    func handleAction() {
        switch buttonType {
        case .manually(_, let data):
            flowController.toAddManually(with: data)
        case .scanner:
            flowController.toCodeScanner()
        case .next:
            let nextPageNumber = pageNumber + 1
            guard nextPageNumber < totalPages else { return }
            flowController.toPage(pageNumber: nextPageNumber, in: menu)
        }
    }
}
