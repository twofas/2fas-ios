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
        
        addSubview(mainStackView, with: [
            mainStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainStackView.widthAnchor.constraint(equalToConstant: Theme.Metrics.componentWidth),
            mainStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            mainStackView.topAnchor.constraint(
                greaterThanOrEqualTo: safeTopAnchor,
                constant: Theme.Metrics.standardMargin
            )
        ])
        
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
        trashWarning.goToTrashAction = { [weak self] in self?.goToTrashAction?() }
    }
    
    func setItemsInTrashCount(_ count: Int) {
        if count > 0 {
            trashWarning.setCount(count)
            mainStackView.insertArrangedSubview(trashWarning, at: 0)
        } else {
            if mainStackView.arrangedSubviews.contains(trashWarning) {
                mainStackView.removeArrangedSubview(trashWarning)
            }
        }
    }
}

private final class TrashWarning: UIView {
    var goToTrashAction: Callback?
    
    private let goToTrash: LoadingContentButton = {
        let button = LoadingContentButton()
        button.apply(MainContainerButtonStyling.borderOnly.value)
        button.update(title: T.Commons.goToTrash)
        return button
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics(forTextStyle: .headline)
            .scaledFont(for: .systemFont(ofSize: 18, weight: .regular))
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        refreshBorder()
        
        addSubview(label, with: [
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ThemeMetrics.margin),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ThemeMetrics.margin),
            label.topAnchor.constraint(equalTo: topAnchor, constant: ThemeMetrics.margin)
        ])
        addSubview(goToTrash, with: [
            goToTrash.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ThemeMetrics.margin),
            goToTrash.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ThemeMetrics.margin),
            goToTrash.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 2 * ThemeMetrics.margin),
            goToTrash.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ThemeMetrics.margin)
        ])
        
        goToTrash.action = { [weak self] in
            self?.goToTrashAction?()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshBorder()
    }
    
    func setCount(_ count: Int) {
        let baseFont = UIFontMetrics(forTextStyle: .headline)
            .scaledFont(for: .systemFont(ofSize: 18, weight: .regular))
        let boldFont = UIFontMetrics(forTextStyle: .headline)
            .scaledFont(for: .systemFont(ofSize: 18, weight: .bold))

        guard let attrString = try? AttributedString(
            markdown: T.Tokens.emptyScreenInTrash(count),
            options: .init(),
            baseURL: nil
        ) else {
            label.text = T.Tokens.emptyScreenInTrash(count)
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

        label.attributedText = mutable
    }
    
    private func refreshBorder() {
        applyRoundedBorder(
            withBorderColor: Theme.Colors.Line.theme.withAlphaComponent(0.5),
            width: 1,
            cornerRadius: Theme.Metrics.cornerRadius
        )
    }
}
