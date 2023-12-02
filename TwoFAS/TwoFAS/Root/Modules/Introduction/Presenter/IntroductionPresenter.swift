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
import Common

final class IntroductionPresenter {
    weak var view: IntroductionViewControlling?
    
    private let flowController: IntroductionFlowControlling
    private let interactor: IntroductionModuleInteracting
    
    init(
        flowController: IntroductionFlowControlling,
        interactor: IntroductionModuleInteracting
    ) {
        self.flowController = flowController
        self.interactor = interactor
    }
    
    private var currentPage: Int = 0
    
    func viewDidAppear() {
        view?.moveToPage(currentPage)
    }
    
    func handleButtonPressed() {
        let next = currentPage + 1
        if next < IntroductionCommons.pageCount {
            currentPage = next
            view?.moveToPage(next)
            return
        }
        
        close()
    }
    
    func handleAdditionalButtonPressed() {
        flowController.toCloudInfo()
    }
    
    func handleDidMoveToPage(_ page: Int) {
        currentPage = page
    }
    
    func handleTOSPressed() {
        flowController.toTOS()
    }
    
    func handlePreviousButtonPressed() {
        let prev = currentPage - 1
        if prev >= 0 {
            currentPage = prev
            view?.moveToPage(prev)
        }
    }
    
    func handleSkipPressed() {
        close()
    }
    
    func handleRefresh() {
        view?.moveToPage(currentPage)
    }
}

private extension IntroductionPresenter {
    func close() {
        interactor.markIntroAsShown()
        flowController.toClose()
    }
}
