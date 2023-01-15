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

enum ToastNotification {
    static func show(title: String, customView: UIView? = nil) {
        let toast = Toast(title: title, customView: customView, offset: NotificationBottomOffset.offset)
        toast.view.backgroundColor = Theme.Colors.Line.primaryLine.withAlphaComponent(0.8)
        toast.view.textColor = Theme.Colors.Text.onBackground
        toast.show()
    }
    
    static func hideAll() {
        ToastCenter.default.cancelAll()
    }
}

private extension Toast {
    convenience init(title: String, customView: UIView?, offset: CGFloat?) {
        self.init(text: title, delay: 0, duration: Theme.Animations.Timing.displayNotification)
        
        if let customView {
            var textInsets = view.textInsets
            let customViewSize = customView.frame.size
            let margin = textInsets.left
            
            textInsets.left = 2 * margin + customViewSize.width
            
            var shouldRepeat = true
            
            while shouldRepeat {
                view.textInsets = textInsets
                view.layoutSubviews()
                
                if view.frame.size.height < (2 * margin) + customViewSize.height {
                    textInsets.top += 0.5 * margin
                    textInsets.bottom += 0.5 * margin
                } else {
                    
                    shouldRepeat = false
                }
            }
            
            view.addSubview(customView)
            customView.frame.origin = CGPoint(x: margin, y: (view.frame.size.height - customViewSize.height) / 2.0)
        }
        
        if let o = offset {
            view.bottomOffsetPortrait = o + Theme.Metrics.notificationMargin
            view.bottomOffsetLandscape = o + Theme.Metrics.notificationMargin
        }
    }
}
