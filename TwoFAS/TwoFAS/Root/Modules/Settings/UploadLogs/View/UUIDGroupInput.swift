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

final class UUIDGroupInput: UIView {
    // 8 4 4 4 12    0-9, a-f
    private let firstTextField = UUIDInputField()
    private let secondTextField = UUIDInputField()
    private let thirdTextField = UUIDInputField()
    private let forthTextField = UUIDInputField()
    private let fifthTextField = UUIDInputField()
    
    private let line1 = FormLine()
    private let line2 = FormLine()
    private let line3 = FormLine()
    private let line4 = FormLine()
    private let line5 = FormLine()
    
    private let dash1 = DashLabel()
    private let dash2 = DashLabel()
    private let dash3 = DashLabel()
    private let dash4 = DashLabel()
    
    var value: String {
        // swiftlint:disable line_length
        "\(firstTextField.text ?? "")-\(secondTextField.text ?? "")-\(thirdTextField.text ?? "")-\(forthTextField.text ?? "")-\(fifthTextField.text ?? "")"
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
        let group = UIView()
        
        let scrollView = CenteringScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        addSubview(scrollView, with: [
            scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: widthAnchor),
            scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: topAnchor),
            scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        scrollView.addSubview(group, with: [
            scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: group.leadingAnchor),
            scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: group.trailingAnchor),
            scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: group.topAnchor),
            scrollView.contentLayoutGuide.bottomAnchor.constraint(lessThanOrEqualTo: group.bottomAnchor),
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: group.widthAnchor),
            scrollView.frameLayoutGuide.heightAnchor.constraint(equalTo: group.heightAnchor)
        ])
        
        let elements = [
            firstTextField,
            dash1,
            secondTextField,
            dash2,
            thirdTextField,
            dash3,
            forthTextField,
            dash4,
            fifthTextField
        ]
        
        let spacing = Theme.Metrics.standardSpacing
        var previous: UIView?
        for current in elements {
            group.addSubview(current, with: [
                current.topAnchor.constraint(equalTo: group.topAnchor),
                current.bottomAnchor.constraint(equalTo: group.bottomAnchor)
            ])
            if let previous {
                NSLayoutConstraint.activate([
                    current.leadingAnchor.constraint(equalTo: previous.trailingAnchor, constant: spacing)
                ])
            }
            
            previous = current
        }
        
        let eightChars: CGFloat = 80
        let oneChar: CGFloat = 5
        let fourChars: CGFloat = 40
        let twelveChars: CGFloat = 120
        
        NSLayoutConstraint.activate([
            firstTextField.leadingAnchor.constraint(equalTo: group.leadingAnchor, constant: 2 * spacing),
            fifthTextField.trailingAnchor.constraint(equalTo: group.trailingAnchor, constant: -2 * spacing),
            firstTextField.widthAnchor.constraint(equalToConstant: eightChars),
            dash1.widthAnchor.constraint(equalToConstant: oneChar),
            secondTextField.widthAnchor.constraint(equalToConstant: fourChars),
            dash2.widthAnchor.constraint(equalToConstant: oneChar),
            thirdTextField.widthAnchor.constraint(equalToConstant: fourChars),
            dash3.widthAnchor.constraint(equalToConstant: oneChar),
            forthTextField.widthAnchor.constraint(equalToConstant: fourChars),
            dash4.widthAnchor.constraint(equalToConstant: oneChar),
            fifthTextField.widthAnchor.constraint(equalToConstant: twelveChars)
        ])
        
        let lines: [UIView: UIView] = [
            firstTextField: line1,
            secondTextField: line2,
            thirdTextField: line3,
            forthTextField: line4,
            fifthTextField: line5
        ]
        
        lines.forEach { textField, line in
            group.addSubview(line, with: [
                line.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
                line.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
                line.bottomAnchor.constraint(equalTo: textField.bottomAnchor)
            ])
        }
        
        firstTextField.setLength(.eight)
        secondTextField.setLength(.four)
        thirdTextField.setLength(.four)
        forthTextField.setLength(.four)
        fifthTextField.setLength(.twelve)
        
        firstTextField.overText = { [weak secondTextField] in secondTextField?.carryOverflow($0) }
        secondTextField.overText = { [weak thirdTextField] in thirdTextField?.carryOverflow($0) }
        thirdTextField.overText = { [weak forthTextField] in forthTextField?.carryOverflow($0) }
        forthTextField.overText = { [weak fifthTextField] in fifthTextField?.carryOverflow($0) }
        
        fifthTextField.overDelete = { [weak forthTextField] in forthTextField?.carryDeletition() }
        forthTextField.overDelete = { [weak thirdTextField] in thirdTextField?.carryDeletition() }
        thirdTextField.overDelete = { [weak secondTextField] in secondTextField?.carryDeletition() }
        secondTextField.overDelete = { [weak firstTextField] in firstTextField?.carryDeletition() }
        
        firstTextField.textChanged = { [weak self] _ in self?.textChanged() }
        secondTextField.textChanged = { [weak self] _ in self?.textChanged() }
        thirdTextField.textChanged = { [weak self] _ in self?.textChanged() }
        forthTextField.textChanged = { [weak self] _ in self?.textChanged() }
        fifthTextField.textChanged = { [weak self] _ in self?.textChanged() }
        
        fifthTextField.actionButtonTapped = { [weak self] in self?.actionCallback?() }
    }
    
    private func textChanged() {
        valueChanged?(value)
    }
    
    func setReadOnlyValue(_ uuid: UUID) {
        let strList = uuid
            .uuidString
            .uppercased()
            .split(separator: "-")
        guard strList.count == 5,
              strList[0].count == UUIDInputField.Length.eight.rawValue,
              strList[1].count == UUIDInputField.Length.four.rawValue,
              strList[2].count == UUIDInputField.Length.four.rawValue,
              strList[3].count == UUIDInputField.Length.four.rawValue,
              strList[4].count == UUIDInputField.Length.twelve.rawValue
        else { return }
        
        firstTextField.setTextAndDisable(String(strList[0]))
        secondTextField.setTextAndDisable(String(strList[1]))
        thirdTextField.setTextAndDisable(String(strList[2]))
        forthTextField.setTextAndDisable(String(strList[3]))
        fifthTextField.setTextAndDisable(String(strList[4]))
        
        valueChanged?(value)
    }
    
    func start(clearCode: Bool) {
        if clearCode {
            firstTextField.text = nil
            secondTextField.text = nil
            thirdTextField.text = nil
            forthTextField.text = nil
            fifthTextField.text = nil
        }
        
        firstTextField.becomeFirstResponder()
    }
    
    func stop() {
        firstTextField.resignFirstResponder()
        secondTextField.resignFirstResponder()
        thirdTextField.resignFirstResponder()
        forthTextField.resignFirstResponder()
        fifthTextField.resignFirstResponder()
    }
}

private final class DashLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        textColor = Theme.Colors.Text.inactive
        font = Theme.Fonts.Form.uuidInput
        text = "-"
        textAlignment = .center
    }
}
