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

class ContainerViewController: UIViewController {
    
    enum AnimationType {
        
        case move
        case moveBack
        case alpha
    }
    
    private var lastUsedViewController: UIViewController?
    
    func present(_ viewController: UIViewController, immediately: Bool = false, animationType: AnimationType = .move) {
        
        let frame = view.frame
        viewController.willMove(toParent: self)
        view.addSubview(viewController.view)
        addChild(viewController)
        viewController.didMove(toParent: self)
        
        guard !immediately else {
            
            viewController.view.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            removeLastUsedViewContoller()
            lastUsedViewController = viewController
            
            return
        }
        
        switch animationType {
        case .move:
            moveAnimation(viewController, backwards: false)
        case .moveBack:
            moveAnimation(viewController, backwards: true)
        case .alpha:
            alphaAnimation(viewController)
        }
    }
    
    func hideLastPresentedViewController() {
        
        removeLastUsedViewContoller()
    }
    
    func removeLastUsedViewContoller() {
        
        guard let last = lastUsedViewController else { return }
        
        Log("Removed \(last)")
        
        last.willMove(toParent: nil)
        last.view.removeFromSuperview()
        last.removeFromParent()
        last.didMove(toParent: nil)
        lastUsedViewController = nil
    }
    
    private func moveAnimation(_ viewController: UIViewController, backwards: Bool) {
        
        let sign: CGFloat = {
            guard backwards else { return 1.0 }
            return -1.0
        }()
        
        let frame = view.frame
        viewController.view.frame = CGRect(x: sign * frame.width, y: 0, width: frame.width, height: frame.height)
        
        UIView.animate(
            withDuration: Theme.Animations.Timing.rootNextScreen,
            delay: 0,
            options: [Theme.Animations.Curve.rootNextScreen],
            animations: { [weak self] in
            guard let self else { return }
            
            viewController.view.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            self.lastUsedViewController?.view.frame = CGRect(
                x: -sign * frame.width / 4.0,
                y: 0,
                width: frame.width,
                height: frame.height
            )
        }) { [weak self] _ in
            guard let self else { return }
            
            self.removeLastUsedViewContoller()
            self.lastUsedViewController = viewController
        }
    }
    
    private func alphaAnimation(_ viewController: UIViewController) {
        
        let frame = view.frame
        viewController.view.alpha = 0
        viewController.view.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        UIView.animate(
            withDuration: Theme.Animations.Timing.rootNextScreen,
            delay: 0,
            options: [Theme.Animations.Curve.rootNextScreen],
            animations: {
            viewController.view.alpha = 1
        }) { [weak self] _ in
            guard let self else { return }
            
            self.removeLastUsedViewContoller()
            self.lastUsedViewController = viewController
        }
    }
}
