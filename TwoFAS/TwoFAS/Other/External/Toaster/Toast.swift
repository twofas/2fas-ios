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

public final class Delay: NSObject {
    @available(*, unavailable) private override init() {}
    // `short` and `long` (lowercase) are reserved words in Objective-C
    // so we capitalize them instead of the default `short_` and `long_`
    @objc(Short) public static let short: TimeInterval = 2.0
    @objc(Long) public static let long: TimeInterval = 3.5
}

open class Toast: Operation {
    
    // MARK: Properties
    
    @objc public var text: String? {
        get { return self.view.text }
        set { self.view.text = newValue }
    }
    
    @objc public var attributedText: NSAttributedString? {
        get { return self.view.attributedText }
        set { self.view.attributedText = newValue }
    }
    
    @objc public var delay: TimeInterval
    @objc public var duration: TimeInterval
    
    private var _executing = false
    override open var isExecuting: Bool {
        get {
            return self._executing
        }
        set {
            self.willChangeValue(forKey: "isExecuting")
            self._executing = newValue
            self.didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var _finished = false
    override open var isFinished: Bool {
        get {
            return self._finished
        }
        set {
            self.willChangeValue(forKey: "isFinished")
            self._finished = newValue
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    
    // MARK: UI
    
    @objc public var view: ToastView = ToastView()
    
    
    // MARK: Initializing
    
    /// Initializer.
    /// Instantiates `self.view`, so must be called on main thread.
    @objc public init(text: String?, delay: TimeInterval = 0, duration: TimeInterval = Delay.short) {
        self.delay = delay
        self.duration = duration
        super.init()
        self.text = text
    }
    
    @objc public init(attributedText: NSAttributedString?, delay: TimeInterval = 0, duration: TimeInterval = Delay.short) {
        self.delay = delay
        self.duration = duration
        super.init()
        self.attributedText = attributedText
    }
    
    // MARK: Showing
    
    @objc public func show() {
        ToastCenter.default.add(self)
    }
    
    
    // MARK: Cancelling
    
    open override func cancel() {
        super.cancel()
        self.finish()
        self.view.removeFromSuperview()
    }
    
    
    // MARK: Operation Subclassing
    
    override open func start() {
        let isRunnable = !self.isFinished && !self.isCancelled && !self.isExecuting
        guard isRunnable else { return }
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.start()
            }
            return
        }
        main()
    }
    
    override open func main() {
        self.isExecuting = true
        
        DispatchQueue.main.async {
            self.view.setNeedsLayout()
            self.view.alpha = 0
            ToastWindow.shared.addSubview(self.view)
            
            UIView.animate(
                withDuration: 0.5,
                delay: self.delay,
                options: .beginFromCurrentState,
                animations: {
                    self.view.alpha = 1
                },
                completion: { completed in
                    if ToastCenter.default.isSupportAccessibility {
                        UIAccessibility.post(notification: .announcement, argument: self.view.text)
                    }
                    UIView.animate(
                        withDuration: self.duration,
                        animations: {
                            self.view.alpha = 1.0001
                        },
                        completion: { completed in
                            self.finish()
                            UIView.animate(
                                withDuration: 0.5,
                                animations: {
                                    self.view.alpha = 0
                                },
                                completion: { completed in
                                    self.view.removeFromSuperview()
                                }
                            )
                        }
                    )
                }
            )
        }
    }
    
    func finish() {
        self.isExecuting = false
        self.isFinished = true
    }
    
}
