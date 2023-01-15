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

final class PINPadKeyboard: UIView {
    var numberButtonAction: ((Int) -> Void)?
    
    private let spacing: CGFloat = 28
    private let verticalSpacing: CGFloat = 17
    
    private var buttons: [PINPadKey] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        var stacks: [UIStackView] = []
        let dimension = Theme.Metrics.PINButtonDimensionLarge
        
        createButtons(buttonDimension: dimension)
        
        for rowIndex in 0...3 {
            let offset = rowIndex * 3
            let range: Range<Int> = Range<Int>((0 + offset)...(2 + offset)).clamped(to: 0..<buttons.count)
            let row = Array(buttons[range])
            let horizontalStack = UIStackView(arrangedSubviews: row)
            horizontalStack.translatesAutoresizingMaskIntoConstraints = false
            horizontalStack.alignment = .center
            horizontalStack.distribution = .equalSpacing
            horizontalStack.spacing = spacing
            horizontalStack.axis = .horizontal
            stacks.append(horizontalStack)
        }
        
        let verticalStack = UIStackView(arrangedSubviews: stacks)
        verticalStack.alignment = .center
        verticalStack.distribution = .equalSpacing
        verticalStack.axis = .vertical
        addSubview(verticalStack)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            verticalStack.heightAnchor.constraint(equalToConstant: 4 * dimension + 3 * verticalSpacing),
            verticalStack.widthAnchor.constraint(equalToConstant: 3 * dimension + 2 * spacing),
            verticalStack.topAnchor.constraint(equalTo: topAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func createButtons(buttonDimension dimension: CGFloat) {
        for i in 1..<10 {
            let button = PINPadKey(number: i, dimension: dimension, action: buttonWasPressed)
            buttons.append(button)
        }
        
        let button = PINPadKey(number: 0, dimension: dimension, action: buttonWasPressed)
        buttons.append(button)
        
        buttons.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
    }
    
    private func buttonWasPressed(id: Int) {
        numberButtonAction?(id)
    }
}
