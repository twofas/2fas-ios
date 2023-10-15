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
import Common

final class UUIDGroupInput: UIView {
    // 8 4 4 4 12    0-9, a-f
    private let firstTextField = UUIDInputContainer()
    private let secondTextField = UUIDInputContainer()
    private let thirdTextField = UUIDInputContainer()
    private let forthTextField = UUIDInputContainer()
    private let fifthTextField = UUIDInputContainer()
    
    private let spacing = Theme.Metrics.standardSpacing
    
    private var containerWidth: CGFloat = 0
    private var containerHeight: CGFloat = 0
    
    private var isReadOnly = false
    
    private lazy var elements = [
        firstTextField,
        secondTextField,
        thirdTextField,
        forthTextField,
        fifthTextField
    ]
    
    var value: String {
        // swiftlint:disable line_length
        "\(firstTextField.input.text ?? "")-\(secondTextField.input.text ?? "")-\(thirdTextField.input.text ?? "")-\(forthTextField.input.text ?? "")-\(fifthTextField.input.text ?? "")"
        // swiftlint:enable line_length
    }
    
    var valueChanged: ((String) -> Void)?
    var actionCallback: Callback?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        elements.forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        })
        
        firstTextField.setLength(.eight)
        secondTextField.setLength(.four)
        thirdTextField.setLength(.four)
        forthTextField.setLength(.four)
        fifthTextField.setLength(.twelve)
        
        firstTextField.input.overText = { [weak secondTextField] in secondTextField?.input.carryOverflow($0) }
        secondTextField.input.overText = { [weak thirdTextField] in thirdTextField?.input.carryOverflow($0) }
        thirdTextField.input.overText = { [weak forthTextField] in forthTextField?.input.carryOverflow($0) }
        forthTextField.input.overText = { [weak fifthTextField] in fifthTextField?.input.carryOverflow($0) }
        
        fifthTextField.input.overDelete = { [weak forthTextField] in forthTextField?.input.carryDeletition() }
        forthTextField.input.overDelete = { [weak thirdTextField] in thirdTextField?.input.carryDeletition() }
        thirdTextField.input.overDelete = { [weak secondTextField] in secondTextField?.input.carryDeletition() }
        secondTextField.input.overDelete = { [weak firstTextField] in firstTextField?.input.carryDeletition() }
        
        firstTextField.input.textChanged = { [weak self] _ in self?.textChanged() }
        secondTextField.input.textChanged = { [weak self] _ in self?.textChanged() }
        thirdTextField.input.textChanged = { [weak self] _ in self?.textChanged() }
        forthTextField.input.textChanged = { [weak self] _ in self?.textChanged() }
        fifthTextField.input.textChanged = { [weak self] _ in self?.textChanged() }
        
        fifthTextField.input.actionButtonTapped = { [weak self] in self?.actionCallback?() }
    }
    
    private func textChanged() {
        valueChanged?(value)
    }
    
    func setReadOnlyValue(_ uuid: UUID) {
        isReadOnly = true
        let strList = uuid
            .uuidString
            .uppercased()
            .split(separator: "-")
        guard strList.count == 5,
              strList[0].count == UUIDInputLength.eight.rawValue,
              strList[1].count == UUIDInputLength.four.rawValue,
              strList[2].count == UUIDInputLength.four.rawValue,
              strList[3].count == UUIDInputLength.four.rawValue,
              strList[4].count == UUIDInputLength.twelve.rawValue
        else { return }
        
        firstTextField.input.setTextAndDisable(String(strList[0]))
        secondTextField.input.setTextAndDisable(String(strList[1]))
        thirdTextField.input.setTextAndDisable(String(strList[2]))
        forthTextField.input.setTextAndDisable(String(strList[3]))
        fifthTextField.input.setTextAndDisable(String(strList[4]))
        
        valueChanged?(value)
    }
    
    func start(clearCode: Bool) {
        if clearCode {
            firstTextField.input.text = nil
            secondTextField.input.text = nil
            thirdTextField.input.text = nil
            forthTextField.input.text = nil
            fifthTextField.input.text = nil
        }
        
        firstTextField.becomeFirstResponder()
    }
    
    func stop() {
        firstTextField.input.resignFirstResponder()
        secondTextField.input.resignFirstResponder()
        thirdTextField.input.resignFirstResponder()
        forthTextField.input.resignFirstResponder()
        fifthTextField.input.resignFirstResponder()
    }
    
    func showKeyboard() {
        guard !isReadOnly else { return }
        firstTextField.input.becomeFirstResponder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var row: Int = 0
        var rowHeight: CGFloat = 0
        var xOffset: CGFloat = 0
        
        let currentWidth = frame.width
        let totalWidth = elements.map({
            $0.layoutIfNeeded()
            return $0.frame.width
        })
            .reduce(0) { $0 + $1 } + CGFloat(elements.count - 1) * spacing
        
        let startingXOffset: CGFloat = {
            if totalWidth <= currentWidth {
                return round((currentWidth - totalWidth) / 2.0)
            }
            return 0
        }()
        xOffset = startingXOffset
        
        for input in elements {
            if rowHeight < input.frame.height {
                rowHeight = input.frame.height
            }
            let inputWidth = input.frame.width
            var possibleWidth = xOffset + inputWidth
            if possibleWidth > currentWidth {
                row += 1
                xOffset = startingXOffset
                possibleWidth = inputWidth
            }
            input.frame = CGRect(
                origin: .init(x: xOffset, y: CGFloat(row) * (rowHeight + spacing)),
                size: input.frame.size
            )
            
            xOffset = possibleWidth + spacing
        }
        
        containerWidth = currentWidth
        containerHeight = CGFloat(row + 1) * rowHeight + CGFloat(row) * spacing
        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: containerWidth, height: containerHeight)
    }
}
