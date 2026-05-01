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
        let img = UIImageView(image: Asset.introductionEmptyHeader.image)
        img.contentMode = .scaleAspectFit
        img.setContentCompressionResistancePriority(.defaultLow - 1, for: .vertical)
        return img
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = Theme.Colors.Text.main
        label.font = Theme.Fonts.Text.content
        label.text = T.Introduction.descriptionTitle
        return label
    }()
    
    private let pairNewServiceButton: LoadingContentButton = {
        let button = LoadingContentButton()
        button.apply(MainContainerButtonStyling.filledInDecoratedContainerLightText.value)
        button.update(title: T.Introduction.pairNewService)
        return button
    }()
    
    private let importButton: LoadingContentButton = {
        let button = LoadingContentButton()
        button.apply(MainContainerButtonStyling.textOnly.value)
        button.update(title: T.Introduction.importExternalApp)
        return button
    }()
    
    private let helpButton: LoadingContentButton = {
        let button = LoadingContentButton()
        button.apply(MainContainerButtonStyling.textOnly.value)
        button.update(title: T.Introduction.whatToDo)
        button.configure(Theme.Fonts.Controls.smallTitle)
        return button
    }()
    
    private let buttonsStackView: UIStackView = {
       let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = Theme.Metrics.mediumSpacing
        return sv
    }()
    
    private let headerStackView: UIStackView = {
       let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = Theme.Metrics.mediumSpacing
        return sv
    }()
    
    private let mainStackView: UIStackView = {
       let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 2 * Theme.Metrics.doubleSpacing
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
        backgroundColor = Theme.Colors.Fill.background
        
        addSubview(trashWarning, with: [
            trashWarning.topAnchor.constraint(equalTo: safeTopAnchor, constant: Theme.Metrics.doubleMargin),
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
            constant: Theme.Metrics.standardMargin
        )
        mainStackTopFromTrashWarning = mainStackView.topAnchor.constraint(
            greaterThanOrEqualTo: trashWarning.bottomAnchor,
            constant: Theme.Metrics.doubleMargin
        )
        mainStackTopFromSafeArea.isActive = true

        mainStackView.addArrangedSubviews([headerStackView, buttonsStackView])
        headerStackView.addArrangedSubviews([iconImage, headerLabel])
        buttonsStackView.addArrangedSubviews([pairNewServiceButton, importButton])
        
        addSubview(helpButton, with: [
            helpButton.topAnchor.constraint(
                greaterThanOrEqualTo: mainStackView.bottomAnchor,
                constant: Theme.Metrics.standardMargin
            ),
            helpButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            helpButton.widthAnchor.constraint(equalToConstant: Theme.Metrics.componentWidth),
            helpButton.bottomAnchor.constraint(
                lessThanOrEqualTo: safeBottomAnchor,
                constant: -Theme.Metrics.standardMargin
            )
        ])
        
        pairNewServiceButton.action = { [weak self] in self?.pairNewService?() }
        importButton.action = { [weak self] in self?.importFromExternalService?() }
        helpButton.action = { [weak self] in self?.help?() }
        
        trashWarning.addTarget(self, action: #selector(trashWarningAction), for: .touchUpInside)
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
    private let horizontalMargin: CGFloat = Theme.Metrics.doubleMargin
    private let verticalMargin: CGFloat = Theme.Metrics.mediumMargin
    private static let fontSize: CGFloat = 16
    
    private let trashIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: fontSize, weight: .semibold)
        let img = UIImageView(image: UIImage(systemName: "trash"))
        img.tintColor = Theme.Colors.Text.main
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private let arrowIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: fontSize, weight: .regular)
        let img = UIImageView(image: UIImage(systemName: "arrow.up.forward"))
        img.tintColor = Theme.Colors.Text.theme
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics(forTextStyle: .headline)
            .scaledFont(for: .systemFont(ofSize: fontSize, weight: .semibold))
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.6
        label.allowsDefaultTighteningForTruncation = true
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.textColor = Theme.Colors.Text.main
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
        label.font = UIFontMetrics(forTextStyle: .headline)
            .scaledFont(for: .systemFont(ofSize: fontSize, weight: .regular))
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.7
        label.allowsDefaultTighteningForTruncation = true
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        label.textColor = Theme.Colors.Text.theme
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
        let baseFont = UIFontMetrics(forTextStyle: .headline)
            .scaledFont(for: .systemFont(ofSize: Self.fontSize, weight: .semibold))
        let boldFont = UIFontMetrics(forTextStyle: .headline)
            .scaledFont(for: .systemFont(ofSize: Self.fontSize, weight: .bold))

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
        mutable.addAttribute(.foregroundColor, value: Theme.Colors.Text.main, range: fullRange)

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
