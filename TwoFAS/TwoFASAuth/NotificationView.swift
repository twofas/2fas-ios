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

final class NotificationView: UIView {
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = ThemeMetrics.spacing * 2
        return sv
    }()
    
    private let stackViewText: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .leading
        sv.distribution = .fill
        sv.spacing = ThemeMetrics.spacing * 2
        return sv
    }()
    
    private let logo: UIImageView = {
        // swiftlint:disable discouraged_object_literal
        let imgView = UIImageView(image: #imageLiteral(resourceName: "LogoGrid"))
        // swiftlint:enable discouraged_object_literal
        imgView.contentMode = .center
        imgView.frame.size = imgView.image?.size ?? CGSize.zero
        return imgView
    }()
    
    private let header: UILabel = {
        let l = UILabel()
        l.font = UIFont.preferredFont(forTextStyle: .title3).withTraits(traits: .traitBold)
        l.textAlignment = .left
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        l.minimumScaleFactor = 0.5
        l.adjustsFontSizeToFitWidth = true
        return l
    }()
    
    private let content: UILabel = {
        let l = UILabel()
        l.font = UIFont.preferredFont(forTextStyle: .body)
        l.textAlignment = .left
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        return l
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
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4 * ThemeMetrics.margin),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4 * ThemeMetrics.margin),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2 * ThemeMetrics.margin),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2 * ThemeMetrics.margin)
        ])
        stackView.addArrangedSubview(logo)
        stackView.addArrangedSubview(stackViewText)
        stackViewText.addArrangedSubview(header)
        stackViewText.addArrangedSubview(content)
    }
    
    func setText(header: String, content: String?) {
        self.header.text = header
        if let content {
            self.content.text = content
            self.content.isHidden = false
        } else {
            self.content.isHidden = true
        }
    }
    
    func setText(header: String, domain: String, extensionName: String) {
        self.header.text = header
        
        let bold = [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body).withTraits(traits: .traitBold)
        ]
        let txt = NSAttributedString.create(
            text: T.Extension.sendQuestionContent(extensionName, domain),
            emphasis: extensionName,
            standardAttributes: [:],
            emphasisAttributes: bold
        )
        let secondPartTxt = NSMutableAttributedString(attributedString: txt)
        secondPartTxt.decorate(textToDecorate: domain, attributes: bold)
        content.attributedText = secondPartTxt
    }
}
