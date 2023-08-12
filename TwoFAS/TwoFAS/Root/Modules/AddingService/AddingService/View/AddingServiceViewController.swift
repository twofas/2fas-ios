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

protocol AddingServiceViewControlling: AnyObject {
    func updateHeight(_ height: CGFloat)
    func embedViewController(_ newVC: UIViewController)
}

final class AddingServiceViewController: UIViewController {
    var presenter: AddingServicePresenter?
    
    private let animTime = Theme.Animations.Timing.quick
    
    private var currentViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Colors.Fill.System.second
        
        presenter?.viewDidLoad()
        
        if let sheet = sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.preferredCornerRadius = Theme.Metrics.modalCornerRadius
        }
    }
}

extension AddingServiceViewController: AddingServiceViewControlling {
    func embedViewController(_ newVC: UIViewController) {
        removeCurrentViewController { [weak self] in
            self?.addNewChildController(with: newVC)
        }
    }
    
    func updateHeight(_ height: CGFloat) {
        guard let sheet = currentViewController?.sheetPresentationController else { return }
        sheet.animateChanges {
            sheet.detents = [
                .custom(resolver: { context in
                    let margin = 4 * Theme.Metrics.standardMargin
                    return min(height + margin, context.maximumDetentValue)
                })
            ]
        }
        UIView.animate(withDuration: animTime) {
            self.currentViewController?.view.alpha = 1
        }
    }
}

private extension AddingServiceViewController {
    func removeCurrentViewController(completion: @escaping () -> Void) {
        guard let currentViewController else {
            completion()
            return
        }
        UIView.animate(withDuration: animTime) {
            currentViewController.view.alpha = 0
        } completion: { _ in
            currentViewController.willMove(toParent: nil)
            currentViewController.view.removeFromSuperview()
            currentViewController.removeFromParent()
            currentViewController.didMove(toParent: nil)
            self.currentViewController = nil
            completion()
        }
    }
    
    func addNewChildController(with newVC: UIViewController) {
        let margin = Theme.Metrics.standardMargin
        let top = 3 * margin
        newVC.willMove(toParent: self)
        addChild(newVC)
        view.addSubview(newVC.view)
        newVC.view.backgroundColor = Theme.Colors.Fill.System.second
        newVC.view.pinToParent(with: .init(
            top: top,
            left: 0,
            bottom: margin,
            right: 0)
        )
        newVC.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        newVC.didMove(toParent: self)
        currentViewController = newVC
    }
}
