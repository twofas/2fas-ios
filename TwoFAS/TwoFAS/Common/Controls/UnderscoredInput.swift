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

protocol UnderscoredInputType: AnyObject {
    
    typealias TextDidChange = (String) -> Void
    typealias FirstResponderChange = (Bool) -> Void
    
    func enable()
    func disable()
    @discardableResult
    func becomeFirstResponder() -> Bool
    @discardableResult
    func resignFirstResponder() -> Bool
    var text: String? { get }
    var textDidChange: TextDidChange? { get set }
    var actionButtonTapped: Callback? { get set }
    func setText(_ text: String)
    var firstResponderChange: FirstResponderChange? { get set }
}

final class UnderscoredInput: LimitedTextField, UnderscoredInputType {
    var textDidChange: TextDidChange?
    var firstResponderChange: FirstResponderChange?
    
    private let underscoreOffset: CGFloat = 6
    private var underscore: FormLine!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override func enable() {
        super.enable()
        
        underscore.enable()
    }
    
    override func disable() {
        super.disable()
        
        underscore.disable()
    }
    
    private func commonInit() {
        
        underscore = FormLine()
        addSubview(underscore)
        underscore.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            underscore.leadingAnchor.constraint(equalTo: leadingAnchor),
            underscore.trailingAnchor.constraint(equalTo: trailingAnchor),
            underscore.topAnchor.constraint(equalTo: bottomAnchor, constant: underscoreOffset)
        ])
        
        underscore.setColors(active: Theme.Colors.Line.primaryLine, inactive: Theme.Colors.Line.primaryLineDisabled)
    }
    
    func hideUnderscore() {
        underscore.isHidden = true
    }
    
    func setText(_ text: String) {
        self.text = text
    }
    
    override func textDidChange(newString: String) {
        textDidChange?(newString)
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        let value = super.becomeFirstResponder()
        if value {
            firstResponderChange?(true)
        }
        return value
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        let value = super.resignFirstResponder()
        if value {
            firstResponderChange?(false)
        }
        return value
    }
}
