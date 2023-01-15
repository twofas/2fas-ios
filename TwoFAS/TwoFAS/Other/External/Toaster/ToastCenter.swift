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

open class ToastCenter: NSObject {
    
    // MARK: Properties
    
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    open var currentToast: Toast? {
        return self.queue.operations.first { !$0.isCancelled && !$0.isFinished } as? Toast
    }
    
    /// If this value is `true` and the user is using VoiceOver,
    /// VoiceOver will announce the text in the toast when `ToastView` is displayed.
    @objc public var isSupportAccessibility: Bool = true
    
    /// By default, queueing for toast is enabled.
    /// If this value is `false`, only the last requested toast will be shown.
    @objc public var isQueueEnabled: Bool = true
    
    @objc public static let `default` = ToastCenter()
    
    
    // MARK: Initializing
    
    override init() {
        super.init()
        let name = UIDevice.orientationDidChangeNotification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.deviceOrientationDidChange),
            name: name,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: Adding Toasts
    
    open func add(_ toast: Toast) {
        if !isQueueEnabled {
            cancelAll()
        }
        self.queue.addOperation(toast)
    }
    
    
    // MARK: Cancelling Toasts
    
    @objc open func cancelAll() {
        queue.cancelAllOperations()
    }
    
    
    // MARK: Notifications
    
    @objc dynamic func deviceOrientationDidChange() {
        if let lastToast = self.queue.operations.first as? Toast {
            lastToast.view.setNeedsLayout()
        }
    }
    
}
