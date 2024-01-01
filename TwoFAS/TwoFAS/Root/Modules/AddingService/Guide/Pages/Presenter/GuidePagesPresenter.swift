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

final class GuidePagesPresenter: ObservableObject {
    var totalPages: Int {
        content.pages.count
    }
    
    var pages: [GuideDescription.Page] {
        content.pages
    }

    var buttonTitle: String {
        switch buttonType {
        case .manually(let title, _): return title
        case .scanner(let title): return title
        case .next: return T.Commons.next
        }
    }
    
    var serviceName: String {
        content.serviceName
    }
    
    var buttonIcon: UIImage? {
        switch buttonType {
        case .scanner: return Asset.smallQRCodeIcon.image
        default: return nil
        }
    }
        
    private var buttonType: GuideDescription.Page.CTA {
        content.pages[currentPage].cta
    }
    
    private let flowController: GuidePagesFlowControlling
    private let content: GuideDescription.MenuPosition
    @Published var currentPage: Int = 0
    
    init(flowController: GuidePagesFlowControlling, content: GuideDescription.MenuPosition) {
        self.flowController = flowController
        self.content = content
    }
    
    func handleAction() {
        switch buttonType {
        case .manually(_, let data):
            flowController.toAddManually(with: data)
        case .scanner:
            flowController.toCodeScanner()
        case .next:
            let nextPageNumber = currentPage + 1
            guard nextPageNumber < totalPages else { return }
            currentPage = nextPageNumber
        }
    }
    
    func handleGoBack() {
        flowController.toMenu()
    }
}
