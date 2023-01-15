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

final class ToastWindow: UIWindow {
    
    // MARK: - Public Property
    
    public static let shared = ToastWindow(frame: UIScreen.main.bounds, mainWindow: UIApplication.keyWindow)
    
    override var rootViewController: UIViewController? {
        get {
            guard !self.isShowing else {
                isShowing = false
                return nil
            }
            guard let firstWindow = UIApplication.shared.delegate?.window else { return nil }
            return firstWindow is ToastWindow ? nil : firstWindow?.rootViewController
        }
        set { /* Do nothing */ }
    }
    
    override var isHidden: Bool {
        willSet {
            isShowing = true
        }
        didSet {
            isShowing = false
        }
    }
    
    /// Don't rotate manually if the application:
    ///
    /// - is running on iPad
    /// - is running on iOS 9
    /// - supports all orientations
    /// - doesn't require full screen
    /// - has launch storyboard
    ///
    var shouldRotateManually: Bool {
        let iPad = UIDevice.current.userInterfaceIdiom == .pad
        let application = UIApplication.shared
        let window = application.delegate?.window ?? nil
        let supportsAllOrientations = application.supportedInterfaceOrientations(for: window) == .all
        
        let info = Bundle.main.infoDictionary
        let requiresFullScreen = (info?["UIRequiresFullScreen"] as? NSNumber)?.boolValue == true
        let hasLaunchStoryboard = info?["UILaunchStoryboardName"] != nil
        
        if #available(iOS 9, *), iPad && supportsAllOrientations && !requiresFullScreen && hasLaunchStoryboard {
            return false
        }
        return true
    }
    
    
    // MARK: - Private Property
    
    /// Will not return `rootViewController` while this value is `true`. Needed for iOS 13.
    private var isShowing = false
    
    /// Returns original subviews. `ToastWindow` overrides `addSubview()` to add a subview to the
    /// top window instead itself.
    private var originalSubviews = NSPointerArray.weakObjects()
    
    private weak var mainWindow: UIWindow?
    
    
    // MARK: - Initializing
    
    public init(frame: CGRect, mainWindow: UIWindow?) {
        super.init(frame: frame)
        self.mainWindow = mainWindow
        self.isUserInteractionEnabled = false
        self.gestureRecognizers = nil
        self.windowLevel = .init(rawValue: .greatestFiniteMagnitude)
        let didBecomeActiveName = UIApplication.didBecomeActiveNotification
        let keyboardWillShowName = UIWindow.keyboardWillShowNotification
        let keyboardDidHideName = UIWindow.keyboardDidHideNotification
        self.backgroundColor = .clear
        self.isHidden = false
        self.handleRotate(Orientation.current)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationSizeWillChange),
            name: Notification.Name.orientationSizeWillChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.applicationDidBecomeActive),
            name: didBecomeActiveName,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: keyboardWillShowName,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardDidHide),
            name: keyboardDidHideName,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented: please use ToastWindow.shared")
    }
    
    
    // MARK: - Public method
    
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        self.originalSubviews.addPointer(Unmanaged.passUnretained(view).toOpaque())
        self.topWindow()?.addSubview(view)
    }
    
    override func becomeKey() {
        super.becomeKey()
        mainWindow?.makeKey()
    }
    
    
    // MARK: - Private method
    
    @objc private func orientationSizeWillChange() {
        let orientation = Orientation.current
        self.handleRotate(orientation)
    }
    
    @objc private func applicationDidBecomeActive() {
        let orientation = Orientation.current
        self.handleRotate(orientation)
    }
    
    @objc private func keyboardWillShow() {
        guard let topWindow = self.topWindow(),
              let subviews = self.originalSubviews.allObjects as? [UIView] else { return }
        for subview in subviews {
            topWindow.addSubview(subview)
        }
    }
    
    @objc private func keyboardDidHide() {
        guard let subviews = self.originalSubviews.allObjects as? [UIView] else { return }
        for subview in subviews {
            super.addSubview(subview)
        }
    }
    
    private func handleRotate(_ orientation: UIInterfaceOrientation) {
        let angle = self.angleForOrientation(orientation)
        if self.shouldRotateManually {
            self.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        }
        
        if let window = UIApplication.keyWindow {
            if orientation.isPortrait || !self.shouldRotateManually {
                self.frame.size.width = window.bounds.size.width
                self.frame.size.height = window.bounds.size.height
            } else {
                self.frame.size.width = window.bounds.size.height
                self.frame.size.height = window.bounds.size.width
            }
        }
        
        self.frame.origin = .zero
        
        DispatchQueue.main.async {
            ToastCenter.default.currentToast?.view.setNeedsLayout()
        }
    }
    
    private func angleForOrientation(_ orientation: UIInterfaceOrientation) -> Double {
        switch orientation {
        case .landscapeLeft: return -.pi / 2
        case .landscapeRight: return .pi / 2
        case .portraitUpsideDown: return .pi
        default: return 0
        }
    }
    
    /// Returns top window that isn't self
    private func topWindow() -> UIWindow? {
        let window =
        UIApplication
            .shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first { KeyboardObserver.shared.didKeyboardShow || $0.isOpaque }
        
        if let window, window !== self {
            return window
        }
        return nil
    }
    
}
