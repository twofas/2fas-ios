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

extension UIViewController {
    func configureAsModal() {
        if UIDevice.isSmallScreen {
            modalPresentationStyle = .fullScreen
        } else {
            modalPresentationStyle = .formSheet
        }
        isModalInPresentation = true
        definesPresentationContext = true
    }
    
    func configureAsLargeModal() {
        if UIDevice.isSmallScreen {
            modalPresentationStyle = .fullScreen
        } else {
            modalPresentationStyle = .pageSheet
        }
        isModalInPresentation = true
        definesPresentationContext = true
    }
    
    func configureAsPhoneFullscreenModal() {
        if UIDevice.isiPad {
            modalPresentationStyle = .formSheet
        } else {
            modalPresentationStyle = .fullScreen
        }
        isModalInPresentation = true
        definesPresentationContext = true
    }
    
    func configureAsFullscreenModal() {
        modalPresentationStyle = .fullScreen
        isModalInPresentation = true
        definesPresentationContext = true
    }
    
    func setCustomLeftBackButton() {
        navigationItem.leftBarButtonItem = createCustomLeftBackButton()
    }
    
    func setCustomBackButton(systemBack: Bool = true) {
        let target = (systemBack) ? navigationController : self
        let sel = (systemBack) ? #selector(navigationController?.popViewController) : #selector(customBackButtonAction)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Asset.iconArrowLeft.image,
            style: .plain,
            target: target,
            action: sel
        )
    }
    
    func createCustomLeftBackButton() -> UIBarButtonItem {
        UIBarButtonItem(
            image: Asset.iconArrowLeft.image,
            style: .plain,
            target: navigationController,
            action: #selector(navigationController?.popViewController)
        )
    }
    
    func setCustomCancelButton() {
        navigationItem.leftBarButtonItem = createCustomCancelButton()
    }
    
    func createCustomCancelButton() -> UIBarButtonItem {
        UIBarButtonItem(
            title: T.Commons.cancel,
            style: .plain,
            target: self,
            action: #selector(cancelButtonAction)
        )
    }
    
    @objc
    func cancelButtonAction() { }
    
    @objc
    func customBackButtonAction() { }
        
    // Keyboard Safe Area adjustment
    
    func startSafeAreaKeyboardAdjustment() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardFrameWillChangeNotificationReceived(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    func stopSafeAreaKeyboardAdjustment() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    @objc
    private func onKeyboardFrameWillChangeNotificationReceived(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else { return }
        
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)
        
        let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        let animationDuration: TimeInterval = keyboardAnimationDuration?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: animationCurve,
                       animations: { [weak self] in
                        self?.additionalSafeAreaInsets.bottom = intersection.height
                        self?.view.layoutIfNeeded()
        }, completion: nil)
    }
}
