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

final class TokensPassCell: UICollectionViewCell {
    var cancelAction: Callback?
    var gotoStoreAction: Callback?
    
    static let reuseIdentifier = "TokensPassCell"
    static let height: CGFloat = 185
    private static let cornerRadius: CGFloat = 16
    
    private let contentMargin: CGFloat = 22
    private let buttonVerticalMargin: CGFloat = 4
    private let buttonHorizontalMargin: CGFloat = 10
    private let pressedAnimDuration: CGFloat = 0.1
    private let releaseAnimDuration: CGFloat = 0.15
    
    private let size = CGSize(width: 328, height: 163)
    private let imageFrame = UIImage(asset: Asset.passFrameLight)
    private let imageDecoration = UIImage(asset: Asset.framePassDecoration)
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics(forTextStyle: .headline)
            .scaledFont(for: .systemFont(ofSize: 14, weight: .medium))
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.7
        label.allowsDefaultTighteningForTruncation = true
        label.textAlignment = .center
        label.textColor = Theme.Colors.Text.main
        label.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        label.accessibilityTraits = .header
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics(forTextStyle: .body)
            .scaledFont(for: .systemFont(ofSize: 12, weight: .regular))
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 5
        label.minimumScaleFactor = 0.7
        label.allowsDefaultTighteningForTruncation = true
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.textColor = Theme.Colors.Text.main
        label.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        label.accessibilityTraits = .staticText
        return label
    }()
    
    private let cancelButtonLabel: UILabel = {
        let label = UILabel()
        label.text = T.passPromoBannerNegativeCta
        label.textColor = Theme.Colors.Text.main
        label.font = UIFontMetrics(forTextStyle: .body)
            .scaledFont(for: .systemFont(ofSize: 13, weight: .bold))
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.applyRoundedBorder(withBorderColor: Theme.Colors.Text.main, width: 1, cornerRadius: cornerRadius)
        return button
    }()
    
    private let gotoStoreButtonLabel: UILabel = {
        let label = UILabel()
        label.text = T.passPromoBannerPositiveCta
        label.textColor = Theme.Colors.Text.light
        label.font = UIFontMetrics(forTextStyle: .body)
            .scaledFont(for: .systemFont(ofSize: 13, weight: .bold))
        return label
    }()
    
    private let gotoStoreButton: UIButton = {
        let button = UIButton()
        button.applyRoundedCorners(withBackgroundColor: .blue, cornerRadius: cornerRadius)
        return button
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
        let img = UIImageView(image: imageFrame)
        img.contentMode = .center
        contentView.addSubview(img, with: [
            img.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            img.topAnchor.constraint(equalTo: contentView.topAnchor),
            img.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        let decoration = UIImageView(image: imageDecoration)
        contentView.addSubview(decoration, with: [
            decoration.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            decoration.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentMargin)
        ])
        
        contentView.addSubview(titleLabel, with: [
            titleLabel.topAnchor.constraint(equalTo: decoration.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: img.leadingAnchor, constant: contentMargin),
            titleLabel.trailingAnchor.constraint(equalTo: img.trailingAnchor, constant: -contentMargin)
        ])
        titleLabel.text = T.passPromoBannerTitle
        
        contentView.addSubview(descriptionLabel, with: [
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: img.leadingAnchor, constant: contentMargin),
            descriptionLabel.trailingAnchor.constraint(equalTo: img.trailingAnchor, constant: -contentMargin)
        ])
        
        let attrString = try? AttributedString(
            markdown: T.passPromoBannerMsg,
            options: .init(),
            baseURL: nil
        )
        if let attrString {
            descriptionLabel.attributedText = NSAttributedString(attrString)
        } else {
            descriptionLabel.text = T.passPromoBannerMsg
        }
        cancelButton.addSubview(cancelButtonLabel, with: [
            cancelButtonLabel.topAnchor.constraint(
                equalTo: cancelButton.topAnchor,
                constant: buttonVerticalMargin
            ),
            cancelButtonLabel.bottomAnchor.constraint(
                equalTo: cancelButton.bottomAnchor,
                constant: -buttonVerticalMargin
            ),
            cancelButtonLabel.leadingAnchor.constraint(
                equalTo: cancelButton.leadingAnchor,
                constant: buttonHorizontalMargin
            ),
            cancelButtonLabel.trailingAnchor.constraint(
                equalTo: cancelButton.trailingAnchor,
                constant: -buttonHorizontalMargin
            )
        ])
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchDown)
        cancelButton.addTarget(
            self,
            action: #selector(cancelButtonReleased),
            for: [
                .touchUpInside,
                .touchUpOutside,
                .touchCancel
            ]
        )
        
        gotoStoreButton.addSubview(gotoStoreButtonLabel, with: [
            gotoStoreButtonLabel.topAnchor.constraint(
                equalTo: gotoStoreButton.topAnchor,
                constant: buttonVerticalMargin
            ),
            gotoStoreButtonLabel.bottomAnchor.constraint(
                equalTo: gotoStoreButton.bottomAnchor,
                constant: -buttonVerticalMargin
            ),
            gotoStoreButtonLabel.leadingAnchor.constraint(
                equalTo: gotoStoreButton.leadingAnchor,
                constant: buttonHorizontalMargin
            ),
            gotoStoreButtonLabel.trailingAnchor.constraint(
                equalTo: gotoStoreButton.trailingAnchor,
                constant: -buttonHorizontalMargin
            )
        ])
        gotoStoreButton.addTarget(self, action: #selector(gotoStoreButtonPressed), for: .touchDown)
        gotoStoreButton.addTarget(
            self,
            action: #selector(gotoStoreButtonReleased),
            for: [
                .touchUpInside,
                .touchUpOutside,
                .touchCancel
            ]
        )
        
        let stackView = UIStackView(arrangedSubviews: [cancelButton, gotoStoreButton])
        stackView.axis = .horizontal
        stackView.spacing = 5
        contentView.addSubview(stackView, with: [
            stackView.topAnchor.constraint(
                greaterThanOrEqualTo: descriptionLabel.bottomAnchor,
                constant: buttonHorizontalMargin
            ),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentMargin),
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        cancelButton.alpha = 0
        UIView.animate(
            withDuration: Theme.Animations.Timing.quick,
            delay: Theme.Animations.Timing.quick
        ) { [weak self] in
            self?.cancelButton.alpha = 1
        }
        
        gotoStoreButton.alpha = 0
        gotoStoreButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(
            withDuration: Theme.Animations.Timing.quick,
            delay: 2 * Theme.Animations.Timing.quick,
            options: [.curveEaseInOut]
        ) { [weak self] in
            self?.gotoStoreButton.alpha = 1
            self?.gotoStoreButton.transform = CGAffineTransform.identity
        }
    }
    
    @objc private func cancelButtonPressed() {
        UIView.animate(withDuration: pressedAnimDuration) {
            self.cancelButton.backgroundColor = Theme.Colors.Text.main
            self.cancelButtonLabel.textColor = Theme.Colors.Fill.background
            self.cancelAction?()
        }
    }
    
    @objc private func cancelButtonReleased() {
        UIView.animate(withDuration: releaseAnimDuration) {
            self.cancelButton.backgroundColor = .clear
            self.cancelButtonLabel.textColor = Theme.Colors.Text.main
        }
    }
    
    @objc private func gotoStoreButtonPressed() {
        UIView.animate(withDuration: pressedAnimDuration) {
            self.gotoStoreButton.backgroundColor = .white
            self.gotoStoreButtonLabel.textColor = .blue
            self.gotoStoreAction?()
        }
    }
    
    @objc private func gotoStoreButtonReleased() {
        UIView.animate(withDuration: releaseAnimDuration) {
            self.gotoStoreButton.backgroundColor = .blue
            self.gotoStoreButtonLabel.textColor = Theme.Colors.Text.light
        }
    }
}
