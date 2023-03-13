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

final class IconSelectorOrderIconReusableView: UICollectionReusableView {
    static let reuseIdentifier = "IconSelectorOrderIconCell"
    static let dimension: CGFloat = 156
    
    var didTapLink: Callback?
    
    private let iconSize: CGFloat = 64
    
    private let lineWidth = Theme.Metrics.separatorHeight
    private let largeMargin = Theme.Metrics.doubleMargin
    
    private let topHeader: IconSelectorHeader = {
        let header = IconSelectorHeader()
        header.setTitle(T.Tokens.orderIconLink)
        return header
    }()
    
    private let iconPlaceholder: UIImageView = {
        let iv = UIImageView(image: Asset.orderIconFrame.image)
        iv.contentMode = .left
        iv.tintColor = Theme.Colors.Line.separator
        return iv
    }()
    
    private let line: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.Colors.Line.separator
        return v
    }()
    
    private let vStackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.distribution = .fill
        s.alignment = .leading
        s.spacing = Theme.Metrics.halfSpacing
        return s
    }()
    
    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.textColor = Theme.Colors.Text.main
        l.font = Theme.Fonts.sectionHeader
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        l.text = T.Tokens.orderIconDescription
        return l
    }()
    
    private let linkLabel: UILabel = {
        let l = UILabel()
        l.textColor = Theme.Colors.Text.theme
        l.font = Theme.Fonts.Text.content
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        l.allowsDefaultTighteningForTruncation = true
        l.minimumScaleFactor = 0.7
        l.text = T.Tokens.orderIconLink
        l.setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
        return l
    }()
    
    private let bottomHeader = IconSelectorHeader()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = Theme.Colors.Fill.System.first
        
        let hSpacing = 2 * Theme.Metrics.doubleMargin
        
        addSubview(topHeader, with: [
            topHeader.leadingAnchor.constraint(equalTo: leadingAnchor),
            topHeader.topAnchor.constraint(equalTo: topAnchor),
            topHeader.trailingAnchor.constraint(equalTo: trailingAnchor),
            topHeader.heightAnchor.constraint(equalToConstant: IconSelectorHeader.dimension)
        ])
        
        addSubview(bottomHeader, with: [
            bottomHeader.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomHeader.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomHeader.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomHeader.heightAnchor.constraint(equalToConstant: IconSelectorHeader.dimension)
        ])
        
        addSubview(iconPlaceholder, with: [
            iconPlaceholder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: hSpacing),
            iconPlaceholder.topAnchor.constraint(equalTo: topHeader.bottomAnchor, constant: largeMargin),
            iconPlaceholder.bottomAnchor.constraint(equalTo: bottomHeader.topAnchor, constant: -largeMargin),
            iconPlaceholder.heightAnchor.constraint(equalToConstant: iconPlaceholder.image?.size.height ?? iconSize)
        ])
        
        addSubview(line, with: [
            line.leadingAnchor.constraint(equalTo: iconPlaceholder.trailingAnchor, constant: largeMargin),
            line.topAnchor.constraint(equalTo: iconPlaceholder.topAnchor),
            line.bottomAnchor.constraint(equalTo: iconPlaceholder.bottomAnchor),
            line.widthAnchor.constraint(equalToConstant: lineWidth)
        ])
                
        addSubview(vStackView, with: [
            vStackView.leadingAnchor.constraint(equalTo: line.trailingAnchor, constant: largeMargin),
            vStackView.topAnchor.constraint(greaterThanOrEqualTo: line.topAnchor),
            vStackView.bottomAnchor.constraint(lessThanOrEqualTo: line.bottomAnchor),
            vStackView.centerYAnchor.constraint(equalTo: line.centerYAnchor),
            vStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -hSpacing)
        ])
        
        vStackView.addArrangedSubviews([
            descriptionLabel,
            linkLabel
        ])
        
        linkLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        linkLabel.isUserInteractionEnabled = true
    }
    
    func setTitle(_ title: String) {
        bottomHeader.setTitle(title)
    }
    
    @objc
    private func tapAction() {
        didTapLink?()
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: IconSelectorOrderIconReusableView.dimension)
    }
}
