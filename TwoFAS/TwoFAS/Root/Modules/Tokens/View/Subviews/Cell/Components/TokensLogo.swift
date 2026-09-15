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

final class TokensLogo: UIView {
    private let circleView = UIView()
    private let gradientLayer = CAGradientLayer()
    private let imageView = UIImageView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = TextStyle.title3.uiFont()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.textColor = AppColor.graysWhite.uiColor
        return label
    }()

    private var circleSizeConstraints: [NSLayoutConstraint] = []
    private var imageSizeConstraints: [NSLayoutConstraint] = []

    private var currentKind: TokensCellKind = .normal

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addSubview(circleView)
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.clipsToBounds = true
        circleView.layer.addSublayer(gradientLayer)

        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0).cgColor,
            UIColor.black.withAlphaComponent(0.1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.isHidden = true

        circleView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        circleView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            circleView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            circleView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            circleView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            circleView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),

            imageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: circleView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: circleView.trailingAnchor, constant: -4)
        ])

        applyKindConstraints()

        setContentHuggingPriority(.defaultHigh + 2, for: .horizontal)
        setContentHuggingPriority(.defaultLow - 2, for: .vertical)

        isAccessibilityElement = false
        accessibilityElementsHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let dimension = currentKind.iconDimension
        circleView.layer.cornerRadius = dimension / 2
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
        CATransaction.commit()
    }

    func setKind(_ kind: TokensCellKind) {
        guard kind != currentKind else { return }
        currentKind = kind
        applyKindConstraints()
        switch kind {
        case .normal:
            titleLabel.font = TextStyle.title3.uiFont()
        case .compact, .edit:
            titleLabel.font = TextStyle.subheadline.uiFont(.emphasized)
        case .pass:
            break
        }
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    func configure(with logoType: LogoType) {
        switch logoType {
        case .image(let image):
            imageView.image = image
            imageView.isHidden = false
            titleLabel.isHidden = true
            circleView.backgroundColor = AppColor.backgroundsSecondary.uiColor
            gradientLayer.isHidden = true
        case .label(let text, let tintColor):
            imageView.image = nil
            imageView.isHidden = true
            titleLabel.isHidden = false
            titleLabel.text = normalizedLabel(text)
            circleView.backgroundColor = tintColor.color
            gradientLayer.isHidden = false
        }
    }

    override var intrinsicContentSize: CGSize {
        let size = currentKind.iconDimension
        return CGSize(width: size, height: size)
    }

    private func applyKindConstraints() {
        NSLayoutConstraint.deactivate(circleSizeConstraints)
        NSLayoutConstraint.deactivate(imageSizeConstraints)

        let circleDim = currentKind.iconDimension
        let imageDim = currentKind.iconImageDimension

        circleSizeConstraints = [
            circleView.widthAnchor.constraint(equalToConstant: circleDim),
            circleView.heightAnchor.constraint(equalToConstant: circleDim)
        ]
        imageSizeConstraints = [
            imageView.widthAnchor.constraint(equalToConstant: imageDim),
            imageView.heightAnchor.constraint(equalToConstant: imageDim)
        ]

        NSLayoutConstraint.activate(circleSizeConstraints)
        NSLayoutConstraint.activate(imageSizeConstraints)
    }

    private func normalizedLabel(_ text: String) -> String {
        var newText = text.uppercased()
        if newText.count > 2 {
            newText = String(newText.prefix(2))
        }
        return newText
    }
}
