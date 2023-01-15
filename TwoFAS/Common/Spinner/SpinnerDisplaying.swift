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

public protocol SpinnerDisplaying {
    func showSpinner()
    func hideSpinner()
}

public extension SpinnerDisplaying where Self: UIViewController {
    func showSpinner() {
        view.showSpinner()
    }
    
    func hideSpinner() {
        view.hideSpinner()
    }
}

public extension UIView {
    func showSpinner() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let spinners = self.subviews.compactMap { $0 as? SpinnerView }
            guard spinners.isEmpty else { return }
            
            let bg = SpinnerBackground()
            self.addSubview(bg)
            bg.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bg.topAnchor.constraint(equalTo: self.topAnchor),
                bg.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                bg.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                bg.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
            
            let spinner = SpinnerView()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(spinner)
            
            self.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            self.centerYAnchor.constraint(equalTo: spinner.centerYAnchor).isActive = true
            
            bg.startAnimating()
            spinner.startAnimating()
            self.isUserInteractionEnabled = false
            UIAccessibility.post(notification: .layoutChanged, argument: spinner)
        }
    }
    
    func hideSpinner() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let spinners = self.subviews.compactMap {
                $0 as? SpinnerView
            }
            
            let bg = self.subviews.compactMap {
                $0 as? SpinnerBackground
            }
            
            bg.forEach {
                $0.removeFromSuperview()
            }
            
            spinners.forEach {
                $0.stopAnimating()
                $0.removeFromSuperview()
            }
            
            self.isUserInteractionEnabled = true
            UIAccessibility.post(notification: .layoutChanged, argument: self)
        }
    }
}
