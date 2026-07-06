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

final class TokensViewEmptyListScreen: UIView {
    var goToTrashAction: Callback?
    var pairNewService: Callback?
    var importFromExternalService: Callback?
    var help: Callback?
    
    private let trashWarning = TrashWarning(frame: .zero)
    private var mainStackTopFromSafeArea: NSLayoutConstraint!
    private var mainStackTopFromTrashWarning: NSLayoutConstraint!
    
    private let iconImage: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 41, weight: .semibold)
        let img = UIImageView(image: UIImage(systemName: "qrcode", withConfiguration: config))
        img.tintColor = AppColor.accentsBrand.uiColor
        img.contentMode = .scaleAspectFit
        img.setContentCompressionResistancePriority(.defaultLow - 1, for: .vertical)
        return img
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.allowsDefaultTighteningForTruncation = true
        label.textColor = AppColor.labelsPrimary.uiColor
        label.font = TextStyle.title2.uiFont(.emphasized)
        label.text = "Add first service"
        return label
    }()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = AppColor.labelsSecondary.uiColor
        label.font = TextStyle.callout.uiFont()
        label.text = T.Introduction.descriptionTitle
        return label
    }()

    private let pairNewServiceButton: LoadingContentButton = {
        let button = LoadingContentButton()
        button.titleColor = AppColor.graysWhite.uiColor
        button.highlightedTitleColor = AppColor.graysWhite.uiColor
        button.disabledTitleColor = AppColor.labelsTertiary.uiColor
        button.normalColor = AppColor.accentsBrand.uiColor
        button.highlightedColor = AppColor.accentsBrand.uiColor
        button.inactiveColor = AppColor.fillsTertiary.uiColor
        button.updateStyle()
        button.update(title: T.Introduction.pairNewService)
        button.applyCornerRadius(Theme.Metrics.buttonHeight / 2)
        return button
    }()

    private let importButton: LoadingContentButton = {
        let button = LoadingContentButton()
        button.titleColor = AppColor.accentsBrand.uiColor
        button.highlightedTitleColor = AppColor.accentsBrand.uiColor
        button.disabledTitleColor = AppColor.labelsTertiary.uiColor
        button.normalColor = .clear
        button.highlightedColor = .clear
        button.inactiveColor = .clear
        button.updateStyle()
        button.update(title: T.Introduction.importExternalApp)
        return button
    }()

    private let helpButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = AppColor.fillsTertiary.uiColor
        config.baseForegroundColor = AppColor.labelsPrimary.uiColor
        config.background.cornerRadius = TFCornerRadius.medium.rawValue
        config.contentInsets = NSDirectionalEdgeInsets(
            top: Spacing.M.rawValue,
            leading: Spacing.ML.rawValue,
            bottom: Spacing.M.rawValue,
            trailing: Spacing.ML.rawValue
        )
        var container = AttributeContainer()
        container.font = TextStyle.subheadline.uiFont(.emphasized)
        config.attributedTitle = AttributedString(T.Introduction.whatToDo, attributes: container)
        return UIButton(configuration: config)
    }()
    
    private let buttonsStackView: UIStackView = {
       let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = Spacing.XL.rawValue
        return sv
    }()
    
    private let headerStackView: UIStackView = {
       let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = Spacing.XL.rawValue
        return sv
    }()
    
    private let mainStackView: UIStackView = {
       let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = Spacing.XXXXXL.rawValue
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
        backgroundColor = AppColor.backgroundsPrimary.uiColor

        addSubview(trashWarning, with: [
            trashWarning.topAnchor.constraint(equalTo: safeTopAnchor, constant: Spacing.XL.rawValue),
            trashWarning.centerXAnchor.constraint(equalTo: centerXAnchor),
            trashWarning.widthAnchor.constraint(equalToConstant: Theme.Metrics.componentWidth)
        ])
        trashWarning.isHidden = true

        addSubview(mainStackView, with: [
            mainStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainStackView.widthAnchor.constraint(equalToConstant: Theme.Metrics.componentWidth),
            mainStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        mainStackTopFromSafeArea = mainStackView.topAnchor.constraint(
            greaterThanOrEqualTo: safeTopAnchor,
            constant: Spacing.M.rawValue
        )
        mainStackTopFromTrashWarning = mainStackView.topAnchor.constraint(
            greaterThanOrEqualTo: trashWarning.bottomAnchor,
            constant: Spacing.XL.rawValue
        )
        mainStackTopFromSafeArea.isActive = true

        mainStackView.addArrangedSubviews([headerStackView, buttonsStackView])
        headerStackView.addArrangedSubviews([iconImage, titleLabel, headerLabel])
        headerStackView.setCustomSpacing(Spacing.L.rawValue, after: iconImage)
        headerStackView.setCustomSpacing(Spacing.SM.rawValue, after: titleLabel)
        buttonsStackView.addArrangedSubviews([pairNewServiceButton, importButton])

        addSubview(helpButton, with: [
            helpButton.topAnchor.constraint(
                greaterThanOrEqualTo: mainStackView.bottomAnchor,
                constant: Spacing.M.rawValue
            ),
            helpButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            helpButton.bottomAnchor.constraint(
                lessThanOrEqualTo: safeBottomAnchor,
                constant: -Spacing.XXXXXXL.rawValue
            )
        ])

        pairNewServiceButton.action = { [weak self] in self?.pairNewService?() }
        importButton.action = { [weak self] in self?.importFromExternalService?() }
        helpButton.addTarget(self, action: #selector(helpButtonAction), for: .touchUpInside)

        trashWarning.addTarget(self, action: #selector(trashWarningAction), for: .touchUpInside)
    }

    @objc
    private func helpButtonAction() {
        help?()
    }

    func setItemsInTrashCount(_ count: Int) {
        let show = count > 0
        if show { trashWarning.setCount(count) }
        trashWarning.isHidden = !show
        mainStackTopFromSafeArea.isActive = !show
        mainStackTopFromTrashWarning.isActive = show
    }
    
    @objc
    private func trashWarningAction() {
        goToTrashAction?()
    }
}

private final class TrashWarning: UIButton {
    private let horizontalMargin: CGFloat = Spacing.XL.rawValue
    private let verticalMargin: CGFloat = Spacing.L.rawValue
    private static let fontSize: CGFloat = 16
    
    private let trashIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: fontSize, weight: .semibold)
        let img = UIImageView(image: UIImage(systemName: "trash"))
        img.tintColor = AppColor.labelsPrimary.uiColor
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private let arrowIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: fontSize, weight: .regular)
        let img = UIImageView(image: UIImage(systemName: "arrow.up.forward"))
        img.tintColor = AppColor.accentsBrand.uiColor
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = TextStyle.subheadline.uiFont()
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.6
        label.allowsDefaultTighteningForTruncation = true
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.textColor = AppColor.labelsPrimary.uiColor
        label.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        label.accessibilityTraits = .staticText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let linkLabel: UILabel = {
        let label = UILabel()
        label.font = TextStyle.callout.uiFont()
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.7
        label.allowsDefaultTighteningForTruncation = true
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        label.textColor = AppColor.accentsBrand.uiColor
        label.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        label.accessibilityTraits = .staticText
        label.text = T.Commons.goToTrash
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        refreshBackground()
        
        let linkStack = UIStackView(arrangedSubviews: [linkLabel, arrowIcon, UIView()])
        linkStack.spacing = ThemeMetrics.spacing
        linkStack.alignment = .leading
        linkStack.axis = .horizontal
        
        let verticalStack = UIStackView(arrangedSubviews: [summaryLabel, linkStack])
        verticalStack.spacing = ThemeMetrics.spacing
        verticalStack.alignment = .leading
        verticalStack.axis = .vertical
        
        let containerStack = UIStackView(arrangedSubviews: [trashIcon, verticalStack])
        containerStack.spacing = ThemeMetrics.spacing
        containerStack.alignment = .leading
        containerStack.axis = .horizontal
        
        addSubview(containerStack, with: [
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalMargin),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalMargin),
            containerStack.topAnchor.constraint(equalTo: topAnchor, constant: verticalMargin),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalMargin)
        ])
        containerStack.isUserInteractionEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshBackground()
    }
    
    func setCount(_ count: Int) {
        let baseFont = TextStyle.subheadline.uiFont()
        let boldFont = TextStyle.subheadline.uiFont(.emphasized)

        guard let attrString = try? AttributedString(
            markdown: T.Tokens.emptyScreenInTrash(count),
            options: .init(),
            baseURL: nil
        ) else {
            summaryLabel.text = T.Tokens.emptyScreenInTrash(count)
            return
        }

        let mutable = NSMutableAttributedString(attrString)
        let fullRange = NSRange(location: 0, length: mutable.length)

        mutable.addAttribute(.font, value: baseFont, range: fullRange)
        mutable.addAttribute(.foregroundColor, value: AppColor.labelsPrimary.uiColor, range: fullRange)

        NSAttributedString(attrString).enumerateAttribute(.font, in: fullRange, options: []) { value, range, _ in
            guard let font = value as? UIFont,
                  font.fontDescriptor.symbolicTraits.contains(.traitBold) else { return }
            mutable.addAttribute(.font, value: boldFont, range: range)
        }

        summaryLabel.attributedText = mutable
    }
    
    private func refreshBackground() {
        applyRoundedCorners(withBackgroundColor: ThemeColor.infoField, cornerRadius: 2 * Theme.Metrics.cornerRadius)
    }
}
