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

protocol ContentNavigationControllerHideNavibar: AnyObject {}

final class ContentNavigationController: CommonNavigationController {
    private var navigationBarObserver: NSKeyValueObservation?

    private var shouldHide: Bool {
        guard let root = viewControllers.first else { return false }
        return root is ContentNavigationControllerHideNavibar
    }
    
    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        let hide = shouldHide ? true : hidden
        super.setNavigationBarHidden(hide, animated: animated)
    }
        
    func setRootViewController(_ vc: UIViewController) {
        setViewControllers([vc], animated: false)
        if shouldHide {
            if !navigationBar.isHidden {
                setNavigationBarHidden(true, animated: false)
            }
        } else {
            if navigationBar.isHidden {
                setNavigationBarHidden(false, animated: false)
            }
        }
    }
        
    deinit {
        navigationBarObserver = nil
    }
    
    // swiftlint:disable vertical_parameter_alignment_on_call
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarObserver = navigationController?.observe(
            \.navigationBar.isHidden,
             options: [.new]
        ) { [weak self] _, isHidden in
            guard let self, isHidden.newValue == !self.shouldHide else { return }
            self.navigationBar.isHidden = !self.shouldHide
        }
    }
    // swiftlint:enable vertical_parameter_alignment_on_call
}
