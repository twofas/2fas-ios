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

final class FormLine: UIView {
    private var active: UIColor?
    private var inactive: UIColor?
    private var focus: UIColor?
    
    private var normalHeight: CGFloat = 1
    private var focusedHeight: CGFloat = 3
    
    private var currentHeight: CGFloat = 0
    
    func setColors(active: UIColor, inactive: UIColor, focus: UIColor? = nil) {
        
        self.active = active
        self.inactive = inactive
        self.focus = focus
        
        backgroundColor = active
    }
    
    func setLineHeight(normal: CGFloat, focused: CGFloat) {
        normalHeight = normal
        focusedHeight = focused
        currentHeight = normalHeight
        invalidateIntrinsicContentSize()
    }
    
    func enable() {
        guard let active else { return }
        
        quickAnim { [weak self] in self?.backgroundColor = active }
    }
    
    func disable() {
        guard let inactive else { return }
        
        quickAnim { [weak self] in self?.backgroundColor = inactive }
    }
    
    func setFocus(_ value: Bool) {
        guard let focus, let active else { return }
        
        if value {
            quickAnim { [weak self] in
                guard let self else { return }
                
                self.currentHeight = self.focusedHeight
                self.invalidateIntrinsicContentSize()
                self.backgroundColor = focus
            }
        } else {
            quickAnim { [weak self] in
                guard let self else { return }
                
                self.currentHeight = self.normalHeight
                self.invalidateIntrinsicContentSize()
                self.backgroundColor = active
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = Theme.Colors.Line.separator
        isUserInteractionEnabled = false
        currentHeight = normalHeight
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: currentHeight)
    }
}
