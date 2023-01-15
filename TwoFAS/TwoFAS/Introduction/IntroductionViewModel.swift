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
import Common

protocol IntroductionViewModelDelegate: AnyObject {
    func moveToPage(_ num: Int)
}

final class IntroductionViewModel {
    weak var delegate: IntroductionViewModelDelegate?
    var didFinish: Callback?
    
    private var currentPage: Int = 0
    
    func didAppear() {
        delegate?.moveToPage(0)
    }
    
    func actionButtonPressed() {
        let next = currentPage + 1
        if next < IntroductionCommons.pageCount {
            currentPage = next
            delegate?.moveToPage(next)
            return
        }
        
        didFinish?()
    }
    
    func didMoveToPage(_ page: Int) {
        currentPage = page
    }
    
    func tosPressed() {
        UIApplication.shared.open(Config.tosURL, completionHandler: nil)
    }
    
    func previousButtonPressed() {
        let prev = currentPage - 1
        if prev >= 0 {
            currentPage = prev
            delegate?.moveToPage(prev)
        }
    }
    
    func skipPressed() {
        didFinish?()
    }
}
