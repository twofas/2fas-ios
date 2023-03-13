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

class GridCollectionViewCell: UICollectionViewCell {
    enum IconType: Equatable {
        case image(UIImage)
        case label(String, TintColor)
    }
    
    enum Consts {
        static let categoryWidth: CGFloat = 5
        static let margin: CGFloat = 20
        static let imageSize: CGFloat = 40
        static let smallHeight: CGFloat = 15
    }
    let categoryView = UIView()
    
    let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .leading
        sv.distribution = .equalSpacing
        sv.spacing = 0
        return sv
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    
    private let labelRenderer = LabelRenderer()
    private(set) var currentAccessibilityIcon: UIView?
    let labelRendererContainer = UIView()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.TokenCell.description
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 1
        label.allowsDefaultTighteningForTruncation = true
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let infoNextToken = InfoNextTokenView()
    
    private let spacingLineView: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.Colors.Line.secondaryLine
        return v
    }()
    
    private let rightBorderLineView: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.Colors.Line.secondaryLine
        return v
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
        contentView.backgroundColor = Theme.Colors.Fill.background
        backgroundColor = Theme.Colors.Fill.background
        
        setupLayout()
    }
    
    func configureIcon(with iconType: IconType, serviceTypeName: String?) {
        switch iconType {
        case .image(let image):
            iconImageView.image = image
            iconImageView.accessibilityLabel = serviceTypeName
            
            iconImageView.isHidden = false
            labelRenderer.isHidden = true
            
            iconImageView.isAccessibilityElement = true
            labelRenderer.isAccessibilityElement = false
            
            currentAccessibilityIcon = iconImageView
        case .label(let title, let color):
            labelRenderer.setText(title)
            labelRenderer.setColor(color, animated: false)
            
            labelRenderer.isHidden = false
            iconImageView.isHidden = true
            
            iconImageView.isAccessibilityElement = false
            labelRenderer.isAccessibilityElement = true
            
            currentAccessibilityIcon = labelRenderer
        }
    }
    
    func setupLayout() {
        contentView.addSubview(spacingLineView, with: [
            spacingLineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            spacingLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            spacingLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            spacingLineView.heightAnchor.constraint(equalToConstant: Theme.Metrics.lineWidth)
        ])
        contentView.addSubview(rightBorderLineView, with: [
            rightBorderLineView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rightBorderLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            rightBorderLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rightBorderLineView.widthAnchor.constraint(equalToConstant: Theme.Metrics.lineWidth)
        ])
        
        addSubview(categoryView, with: [
            categoryView.topAnchor.constraint(equalTo: topAnchor),
            categoryView.bottomAnchor.constraint(equalTo: bottomAnchor),
            categoryView.leadingAnchor.constraint(equalTo: leadingAnchor),
            categoryView.widthAnchor.constraint(equalToConstant: Consts.categoryWidth)
        ])
        
        labelRendererContainer.addSubview(labelRenderer, with: [
            labelRenderer.centerXAnchor.constraint(equalTo: labelRendererContainer.centerXAnchor),
            labelRenderer.centerYAnchor.constraint(equalTo: labelRendererContainer.centerYAnchor)
        ])
    }
    
    func setupAccessibility() {
        categoryView.isAccessibilityElement = true
        nameLabel.isAccessibilityElement = true
        nameLabel.accessibilityLabel = T.Voiceover.serviceName(nameLabel.text ?? "")
        
        isAccessibilityElement = false
    }
}
