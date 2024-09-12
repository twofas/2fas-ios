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

final class SelectionOption: UIView {
    var accessibilityText: String = "" {
        didSet {
            updateAccessibility()
        }
    }
    
    private let iconDimension: CGFloat = 40
    private let iconContainer = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme.Colors.Text.main
        label.font = Theme.Fonts.Text.info
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    private let radio = Radio()
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = Theme.Metrics.standardSpacing
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        accessibilityTraits = .button
        isAccessibilityElement = true
        
        addSubview(stackView)
        stackView.addArrangedSubviews([
            iconContainer, titleLabel, radio
        ])
        stackView.pinToParent()
        
        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: iconDimension),
            iconContainer.heightAnchor.constraint(equalToConstant: iconDimension)
        ])
    }
    
    func setIconHandler(_ iconHandler: UIView) {
        iconContainer.addSubview(iconHandler)
        iconHandler.pinToParentCenter()
    }
    
    func hideIconContainer() {
        iconContainer.isHidden = true
    }
    
    func setSelected(_ selected: Bool) {
        radio.setSelected(selected)
        updateAccessibility()
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
        updateAccessibility()
    }
    
    private func updateAccessibility() {
        let selected: String = {
            if radio.isSelected {
                return T.Voiceover.selected
            }
            return T.Voiceover.notSelected
        }()
        accessibilityLabel = accessibilityText + ". " + selected
    }
}

private final class Radio: UIView {
    private let dimension: CGFloat = 20
    
    private let deselectedImage: UIImageView = {
        let imgView = UIImageView(image: Asset.radioSelectionDeselected.image
            .withRenderingMode(.alwaysTemplate)
        )
        imgView.tintColor = Theme.Colors.Controls.inactive
        imgView.contentMode = .center
        return imgView
    }()
    private let selectedImage: UIImageView = {
        let imgView = UIImageView(image: Asset.radioSelectionSelected.image
            .withRenderingMode(.alwaysTemplate)
        )
        imgView.tintColor = Theme.Colors.Controls.active
        imgView.contentMode = .center
        return imgView
    }()
    
    private(set) var isSelected = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(deselectedImage)
        deselectedImage.pinToParent()
        
        addSubview(selectedImage)
        selectedImage.pinToParent()
        
        NSLayoutConstraint.activate([
            deselectedImage.widthAnchor.constraint(equalToConstant: dimension),
            deselectedImage.heightAnchor.constraint(equalToConstant: dimension),
            selectedImage.widthAnchor.constraint(equalToConstant: dimension),
            selectedImage.heightAnchor.constraint(equalToConstant: dimension)
        ])
        
        selectedImage.alpha = 0
    }
    
    func setSelected(_ selected: Bool) {
        isSelected = selected
        let duration = Theme.Animations.Timing.quick
        if selected {
            UIView.animate(withDuration: duration) {
                self.selectedImage.alpha = 1
                self.deselectedImage.alpha = 0
            }
        } else {
            UIView.animate(withDuration: duration) {
                self.selectedImage.alpha = 0
                self.deselectedImage.alpha = 1
            }
        }
    }
    
    override var intrinsicContentSize: CGSize { CGSize(width: dimension, height: dimension) }
}
