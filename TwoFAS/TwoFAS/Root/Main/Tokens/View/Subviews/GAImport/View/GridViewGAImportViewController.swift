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

final class GridViewGAImportViewController: UIViewController {
    var presenter: GridViewGAImportPresenter!

    private let backgroundImage: UIImageView = {
        let img = UIImageView(image: Asset.introductionBackground.image)
        img.contentMode = .center
        img.tintColor = Theme.Colors.Line.secondaryLine
        return img
    }()
    
    private let iconImage: UIImageView = {
        let img = UIImageView(image: Asset.introductionGAImport.image)
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
        label.text = T.Introduction.googleAuthenticatorImportProcess
        return label
    }()
       
    private let scanQRButton: LoadingContentButton = {
        let button = LoadingContentButton()
        button.apply(MainContainerButtonStyling.filledInDecoratedContainerLightText.value)
        button.update(title: T.Introduction.scanQrCode)
        return button
    }()
    
    private let chooseQRButton: LoadingContentButton = {
        let button = LoadingContentButton()
        button.apply(MainContainerButtonStyling.textOnly.value)
        button.update(title: T.Introduction.chooseQrCode)
        return button
    }()
    
    private let stackView: UIStackView = {
       let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 3 * Theme.Metrics.doubleSpacing
        return sv
    }()
    
    private let buttonsStackView: UIStackView = {
       let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = Theme.Metrics.mediumSpacing
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = T.Backup.import
        view.backgroundColor = Theme.Colors.Fill.background
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: T.Commons.cancel,
            style: .plain,
            target: self,
            action: #selector(cancelAction)
        )
        
        view.addSubview(backgroundImage)
        backgroundImage.pinToParentCenter()
        
        view.addSubview(stackView, with: [
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalToConstant: Theme.Metrics.componentWidth),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -4 * Theme.Metrics.doubleMargin)
        ])
        
        stackView.addArrangedSubviews([iconImage, headerLabel, buttonsStackView])
        
        view.addSubview(buttonsStackView, with: [
            buttonsStackView.topAnchor.constraint(
                greaterThanOrEqualTo: stackView.bottomAnchor,
                constant: Theme.Metrics.standardMargin
            ),
            buttonsStackView.widthAnchor.constraint(equalToConstant: Theme.Metrics.componentWidth),
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStackView.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeBottomAnchor,
                constant: -Theme.Metrics.standardMargin
            )
        ])
        
        buttonsStackView.addArrangedSubviews([scanQRButton, chooseQRButton])
        
        scanQRButton.action = { [weak self] in self?.presenter.handleScanQR() }
        chooseQRButton.action = { [weak self] in self?.presenter.handleChooseQR() }
    }
    
    @objc
    private func cancelAction() {
        presenter.handleCancel()
    }
}
