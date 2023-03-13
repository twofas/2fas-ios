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

final class UserIconInfoViewController: UIViewController {
    var presenter: UserIconInfoPresenter!
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        return sv
    }()
    
    private let contentContainer = UIView()
    private let upperContainer = UIView()
    private let bottomContainer = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = T.Tokens.requestIconPageTitle
        
        view.addSubview(scrollView)
        scrollView.pinToParent()

        view.backgroundColor = Theme.Colors.Fill.background
        scrollView.backgroundColor = Theme.Colors.Fill.background
        
        scrollView.addSubview(contentContainer, with: [
            contentContainer.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentContainer.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentContainer.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        let margin = Theme.Metrics.doubleMargin
        
        // MARK: - Upper Container
        
        contentContainer.addSubview(upperContainer, with: [
            upperContainer.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 2 * margin),
            upperContainer.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
            upperContainer.widthAnchor.constraint(equalToConstant: Theme.Metrics.pageWidth)
        ])
        
        let socialIcon: UIImageView = {
            let icon = UIImageView(image: Asset.requestSocial.image)
            icon.tintColor = Theme.Colors.Icon.theme
            icon.contentMode = .center
            return icon
        }()
        
        upperContainer.addSubview(socialIcon, with: [
            socialIcon.topAnchor.constraint(equalTo: upperContainer.topAnchor),
            socialIcon.centerXAnchor.constraint(equalTo: upperContainer.centerXAnchor)
        ])
        
        let socialTitle: UILabel = {
            let label = UILabel()
            label.font = Theme.Fonts.orderTitle
            label.textColor = Theme.Colors.Text.main
            label.textAlignment = .center
            label.text = T.Tokens.requestIconSocialTitle
            return label
        }()
        
        upperContainer.addSubview(socialTitle, with: [
            socialTitle.topAnchor.constraint(equalTo: socialIcon.bottomAnchor, constant: margin),
            socialTitle.leadingAnchor.constraint(equalTo: upperContainer.leadingAnchor),
            socialTitle.trailingAnchor.constraint(equalTo: upperContainer.trailingAnchor)
        ])
        
        let socialLink: UILabel = {
            let label = UILabel()
            label.font = Theme.Fonts.Text.content
            label.textColor = Theme.Colors.Text.theme
            label.textAlignment = .center
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            
            let str = NSMutableAttributedString(string: T.Tokens.requestIconSocialLink)
            
            let space = NSAttributedString(string: " ")
            str.append(space)
            
            let img = Asset.externalLinkIcon.image
                .withTintColor(Theme.Colors.Icon.theme)
            let iconAttachment = NSTextAttachment()
            iconAttachment.image = img
            iconAttachment.bounds = CGRect(x: 0, y: -3, width: img.size.width, height: img.size.height)
            
            let iconString = NSAttributedString(attachment: iconAttachment)
            str.append(iconString)
            
            let newLine = NSAttributedString(string: "\n")
            str.append(newLine)
            
            let desc = NSAttributedString(string: T.Tokens.requestIconSocialDescription, attributes: [
                .foregroundColor: Theme.Colors.Text.main
            ])
            str.append(desc)

            let paragraph = NSMutableParagraphStyle()
            paragraph.lineHeightMultiple = 1.2
            paragraph.alignment = .center
            str.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: str.length))
            
            label.attributedText = str
            
            label.isUserInteractionEnabled = true
            return label
        }()
        
        socialLink.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(socialLinkAction)))
        
        upperContainer.addSubview(socialLink, with: [
            socialLink.topAnchor.constraint(equalTo: socialTitle.bottomAnchor, constant: margin),
            socialLink.leadingAnchor.constraint(equalTo: upperContainer.leadingAnchor),
            socialLink.trailingAnchor.constraint(equalTo: upperContainer.trailingAnchor),
            socialLink.bottomAnchor.constraint(equalTo: upperContainer.bottomAnchor)
        ])
        
        // MARK: - Middle
        
        let lineColor = Theme.Colors.Line.secondaryLine
        let lineSize: CGFloat = 1.0
        
        let leftLine: UIView = {
            let view = UIView()
            view.backgroundColor = lineColor
            return view
        }()
        
        let orLabel: UILabel = {
            let label = UILabel()
            label.font = Theme.Fonts.Text.info
            label.textColor = Theme.Colors.Text.inactive
            label.textAlignment = .center
            label.text = T.Tokens.requestIconMiddle
            return label
        }()
        
        let rightLine: UIView = {
            let view = UIView()
            view.backgroundColor = lineColor
            return view
        }()
        
        contentContainer.addSubview(leftLine, with: [
            leftLine.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            leftLine.heightAnchor.constraint(equalToConstant: lineSize)
        ])
        
        contentContainer.addSubview(orLabel, with: [
            orLabel.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
            orLabel.topAnchor.constraint(equalTo: upperContainer.bottomAnchor, constant: margin),
            orLabel.centerYAnchor.constraint(equalTo: leftLine.centerYAnchor),
            orLabel.leadingAnchor.constraint(equalTo: leftLine.trailingAnchor, constant: Theme.Metrics.halfSpacing)
        ])
        
        contentContainer.addSubview(rightLine, with: [
            rightLine.leadingAnchor.constraint(equalTo: orLabel.trailingAnchor, constant: Theme.Metrics.halfSpacing),
            rightLine.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            rightLine.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            rightLine.heightAnchor.constraint(equalToConstant: lineSize)
        ])
        
        // MARK: - Bottom Container
        
        contentContainer.addSubview(bottomContainer, with: [
            bottomContainer.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 2 * margin),
            bottomContainer.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
            bottomContainer.widthAnchor.constraint(equalToConstant: Theme.Metrics.pageWidth),
            bottomContainer.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -margin)
        ])
        
        let providerIcon: UIImageView = {
            let img = Asset.requestProvider.image
                .withAlignmentRectInsets(.init(top: 0, left: 0, bottom: 0, right: 7))
            let icon = UIImageView(image: img)
            icon.tintColor = Theme.Colors.Icon.theme
            icon.contentMode = .center
            return icon
        }()
        
        bottomContainer.addSubview(providerIcon, with: [
            providerIcon.topAnchor.constraint(equalTo: bottomContainer.topAnchor),
            providerIcon.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor)
        ])
        
        let providerTitle: UILabel = {
            let label = UILabel()
            label.font = Theme.Fonts.orderTitle
            label.textColor = Theme.Colors.Text.main
            label.textAlignment = .center
            label.text = T.Tokens.requestIconProviderTitle
            return label
        }()
        
        bottomContainer.addSubview(providerTitle, with: [
            providerTitle.topAnchor.constraint(equalTo: providerIcon.bottomAnchor, constant: margin),
            providerTitle.leadingAnchor.constraint(equalTo: upperContainer.leadingAnchor),
            providerTitle.trailingAnchor.constraint(equalTo: upperContainer.trailingAnchor)
        ])
        
        let providerDescription: UILabel = {
            let label = UILabel()
            label.font = Theme.Fonts.Text.content
            label.textColor = Theme.Colors.Text.main
            label.textAlignment = .center
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.text = T.Tokens.requestIconProviderDescription
            
            return label
        }()
                
        bottomContainer.addSubview(providerDescription, with: [
            providerDescription.topAnchor.constraint(equalTo: providerTitle.bottomAnchor, constant: margin),
            providerDescription.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor),
            providerDescription.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor)
        ])
        
        // MARK: Frame
        
        let frameView: UIView = {
            let view = UIView()
            view.applyRoundedBorder(withBorderColor: lineColor, width: lineSize)
            return view
        }()
        
        frameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(frameViewAction)))
        
        bottomContainer.addSubview(frameView, with: [
            frameView.topAnchor.constraint(equalTo: providerDescription.bottomAnchor, constant: 2 * margin),
            frameView.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor),
            frameView.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor)
        ])
        
        let providerLink: UILabel = {
            let label = UILabel()
            label.font = Theme.Fonts.Text.content
            label.textColor = Theme.Colors.Text.main
            label.textAlignment = .left
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            
            let str = NSMutableAttributedString(string: T.Tokens.requestIconProviderMessage)
            str.decorate(
                textToDecorate: T.Tokens.requestIconProviderMessageLink,
                attributes: [.foregroundColor: Theme.Colors.Text.theme]
            )
            
            label.attributedText = str
            
            return label
        }()
        
        let vLine: UIView = {
            let view = UIView()
            view.backgroundColor = lineColor
            return view
        }()
        
        let providerShareIcon: UIImageView = {
            let img = Asset.shareIcon.image
            let icon = UIImageView(image: img)
            icon.tintColor = Theme.Colors.Icon.theme
            icon.contentMode = .center
            return icon
        }()
        
        frameView.addSubview(providerLink, with: [
            providerLink.leadingAnchor.constraint(equalTo: frameView.leadingAnchor, constant: margin),
            providerLink.topAnchor.constraint(equalTo: frameView.topAnchor, constant: margin),
            providerLink.bottomAnchor.constraint(equalTo: frameView.bottomAnchor, constant: -margin)
        ])
        
        frameView.addSubview(vLine, with: [
            vLine.widthAnchor.constraint(equalToConstant: lineSize),
            vLine.topAnchor.constraint(equalTo: frameView.topAnchor),
            vLine.bottomAnchor.constraint(equalTo: frameView.bottomAnchor),
            vLine.leadingAnchor.constraint(equalTo: providerLink.trailingAnchor, constant: margin)
        ])
        
        frameView.addSubview(providerShareIcon, with: [
            providerShareIcon.topAnchor.constraint(equalTo: frameView.topAnchor),
            providerShareIcon.bottomAnchor.constraint(equalTo: frameView.bottomAnchor),
            providerShareIcon.leadingAnchor.constraint(equalTo: vLine.trailingAnchor, constant: margin),
            providerShareIcon.trailingAnchor.constraint(equalTo: frameView.trailingAnchor, constant: -margin)
        ])
        
        let footnote: UILabel = {
            let label = UILabel()
            label.font = Theme.Fonts.Text.note
            label.textColor = Theme.Colors.Text.main
            label.textAlignment = .center
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping

            let img = Asset.warningSmall.image
                .withTintColor(Theme.Colors.Text.main)
            let iconAttachment = NSTextAttachment()
            iconAttachment.image = img
            iconAttachment.bounds = CGRect(x: 0, y: -2, width: img.size.width, height: img.size.height)
            
            let str = NSMutableAttributedString(attachment: iconAttachment)
            
            let space = NSAttributedString(string: " ")
            str.append(space)
                        
            let text = NSAttributedString(string: T.Tokens.requestIconProviderFootnote)
            str.append(text)
                        
            label.attributedText = str
            
            return label
        }()
        
        // MARK: Footer
        
        bottomContainer.addSubview(footnote, with: [
            footnote.topAnchor.constraint(equalTo: frameView.bottomAnchor, constant: margin),
            footnote.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor),
            footnote.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor),
            footnote.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor, constant: -2 * margin)
        ])
    }
    
    @objc
    private func socialLinkAction() {
        presenter.handleSocial()
    }
    
    @objc
    private func frameViewAction() {
        presenter.handleShare()
    }
}
