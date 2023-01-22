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

protocol ServiceAddedViewControlling: AnyObject {
    func set(
        _ serviceName: String,
        actionText: String,
        iconImage: UIImage,
        serviceTypeName: String?,
        secret: String,
        showEditIcon: Bool
    )
}

final class ServiceAddedViewController: UIViewController {
    var presenter: ServiceAddedPresenter!
    var serviceContainer: (UIView & ServiceAddedViewContaining)!
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        l.font = Theme.Fonts.Text.boldContent
        l.textColor = Theme.Colors.Text.main
        return l
    }()
    private let actionLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        l.font = Theme.Fonts.Text.description
        l.textColor = Theme.Colors.Text.subtitle
        l.setContentHuggingPriority(.defaultHigh + 1, for: .vertical)
        return l
    }()
    private let line1: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.Colors.Line.secondaryLine
        return v
    }()
    
    private let line2: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.Colors.Line.secondaryLine
        return v
    }()
    private let customizeButton: LoadingContentButton = {
        let button = LoadingContentButton()
        button.update(title: T.Commons.customize)
        button.apply(MainContainerButtonStyling.filledInDecoratedContainerLightText.value)
        return button
    }()
    private let closeButton: LoadingContentButton = {
        let button = LoadingContentButton()
        button.configure(style: .noBackground, title: T.Commons.close)
        button.apply(MainContainerButtonStyling.text.value)
        return button
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad()
        
        setupLayout()
        setupEvents()
        setupAccessibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIAccessibility.post(notification: .screenChanged, argument: view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        presenter.viewWillDisappear()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let contentSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        preferredContentSize = contentSize
        sheetPresentationController?.presentedViewController.preferredContentSize = contentSize
    }
}

private extension ServiceAddedViewController {
    func setupLayout() {
        let margin = Theme.Metrics.doubleMargin
        view.backgroundColor = Theme.Colors.Fill.System.third
        
        view.addSubview(titleLabel, with: [
            titleLabel.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 2.5 * margin),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin)
        ])
        view.addSubview(actionLabel, with: [
            actionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: margin / 4.0),
            actionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            actionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin)
        ])
        view.addSubview(line1, with: [
            line1.topAnchor.constraint(equalTo: actionLabel.bottomAnchor, constant: 2.5 * margin),
            line1.heightAnchor.constraint(equalToConstant: Theme.Metrics.lineWidth),
            line1.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            line1.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        view.addSubview(serviceContainer, with: [
            serviceContainer.topAnchor.constraint(equalTo: line1.bottomAnchor),
            serviceContainer.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
            serviceContainer.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            serviceContainer.heightAnchor.constraint(equalToConstant: 110),
            serviceContainer.widthAnchor.constraint(equalToConstant: Theme.Metrics.componentWidth),
            serviceContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        view.addSubview(line2, with: [
            line2.topAnchor.constraint(equalTo: serviceContainer.bottomAnchor),
            line2.heightAnchor.constraint(equalToConstant: Theme.Metrics.lineWidth),
            line2.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            line2.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        view.addSubview(customizeButton, with: [
            customizeButton.topAnchor.constraint(equalTo: line2.bottomAnchor, constant: 2.5 * margin),
            customizeButton.heightAnchor.constraint(equalToConstant: Theme.Metrics.buttonHeight),
            customizeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customizeButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
            customizeButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor)
        ])
        view.addSubview(closeButton, with: [
            closeButton.topAnchor.constraint(equalTo: customizeButton.bottomAnchor, constant: margin / 2.0),
            closeButton.heightAnchor.constraint(equalToConstant: Theme.Metrics.buttonHeight),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -margin)
        ])
    }
    
    func setupEvents() {
        customizeButton.action = { [weak self] in self?.presenter.handleEditService() }
        closeButton.action = { [weak self] in self?.presenter.handleClose() }
        
        serviceContainer.serviceContainerTapped = { [weak self] in self?.presenter.handleCopy() }
        serviceContainer.editIconTapped = { [weak self] in self?.presenter.handleEditIcon() }
        serviceContainer.didTapRefreshCounter = { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + Theme.Animations.Timing.quick) {
                self?.presenter.handleRefresh()
            }
        }
    }
    
    func setupAccessibility() {
        isAccessibilityElement = false
        accessibilityElements = [titleLabel, actionLabel, serviceContainer!, customizeButton, closeButton]
    }
}

extension ServiceAddedViewController: ServiceAddedViewControlling {
    func set(
        _ serviceName: String,
        actionText: String,
        iconImage: UIImage,
        serviceTypeName: String?,
        secret: String,
        showEditIcon: Bool
    ) {
        titleLabel.text = T.Tokens.numAdded(serviceName)
        actionLabel.text = actionText
        serviceContainer.configure(
            iconImage: iconImage,
            serviceTypeName: serviceTypeName,
            secret: secret,
            showEditIcon: showEditIcon
        )
    }
}
