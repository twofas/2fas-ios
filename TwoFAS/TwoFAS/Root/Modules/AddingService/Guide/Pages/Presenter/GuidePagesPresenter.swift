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

final class GuidePagesPresenter {
    enum Action: Equatable {
        case manually(String?)
        case scanner
        case next
    }
    
    var totalPages: Int {
        content.pages.count
    }
    
    var pages: [GuideDescription.Page] {
        content.pages
    }
    
    var serviceName: String {
        content.serviceName
    }
    
    private let flowController: GuidePagesFlowControlling
    private let content: GuideDescription.MenuPosition
    
    init(flowController: GuidePagesFlowControlling, content: GuideDescription.MenuPosition) {
        self.flowController = flowController
        self.content = content
    }
    
    func buttonAction(for pageNumber: Int) -> Action {
        switch content.pages[pageNumber].cta {
        case .manually(_, let data): .manually(data)
        case .scanner: .scanner
        case .next: .next
        }
    }
    
    func buttonTitle(for pageNumber: Int) -> String {
        switch content.pages[pageNumber].cta {
        case .manually(let title, _): return title
        case .scanner(let title): return title
        case .next: return T.Commons.next
        }
    }
    
    func onBack() {
        flowController.toMenu()
    }
    
    func onClose() {
        flowController.close()
    }
    
    func onManually(data: String?) {
        flowController.toAddManually(with: data)
    }
    
    func onScanner() {
        flowController.toCodeScanner()
    }
}
