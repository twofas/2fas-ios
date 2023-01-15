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

final class MainContainerViewController: UIViewController {
    private let spacing: CGFloat = Theme.Metrics.doubleMargin
    
    private let top = UIView()
    private let middle = CenteringScrollView()
    private let middleContainer = UIView()
    private let bottom = UIView()
    
    private var topAnchor: NSLayoutConstraint!
    private var middleAnchor: NSLayoutConstraint!
    private var bottomAnchor: NSLayoutConstraint!
    
    private var configuration: Configuration?
    
    private var customBackAction: Callback?
    private var customRightAction: Callback?
    private var userDidUseEnterKey: Callback?
    
    private var hidesNavigationBar = false
    
    private var hideStatusBar = false
    private var preferredStatusBar: UIStatusBarStyle = .default
    
    var dismissKeyboardOnTap = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Theme.Colors.Fill.background
        
        topAnchor = top.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: spacing)
        middleAnchor = middle.topAnchor.constraint(equalTo: top.bottomAnchor, constant: spacing)
        bottomAnchor = bottom.topAnchor.constraint(equalTo: middle.bottomAnchor, constant: spacing)
        
        view.addSubview(top, with: [
            topAnchor,
            top.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing),
            top.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -spacing)
        ])
        
        view.addSubview(middle, with: [
            middleAnchor,
            middle.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            middle.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.addSubview(bottom, with: [
            bottomAnchor,
            bottom.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing),
            bottom.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -spacing),
            bottom.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -spacing)
        ])
        
        middle.addSubview(middleContainer, with: [
            middleContainer.topAnchor.constraint(
                equalTo: middle.contentLayoutGuide.topAnchor
            ),
            middleContainer.leadingAnchor.constraint(
                equalTo: middle.contentLayoutGuide.leadingAnchor,
                constant: spacing
            ),
            middleContainer.trailingAnchor.constraint(
                equalTo: middle.contentLayoutGuide.trailingAnchor,
                constant: -spacing),
            middleContainer.bottomAnchor.constraint(
                equalTo: middle.contentLayoutGuide.bottomAnchor
            ),
            middleContainer.widthAnchor.constraint(
                equalTo: middle.frameLayoutGuide.widthAnchor,
                constant: -2 * spacing
            )
        ])
        
        if let configuration {
            applyConfiguration(with: configuration)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard hidesNavigationBar else { return }
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard hidesNavigationBar else { return }
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }
        
        switch key.keyCode {
        case .keyboardReturn, .keyboardReturnOrEnter:
            userDidUseEnterKey?()
        default:
            super.pressesEnded(presses, with: event)
        }
    }
    
    func configure(with configuration: Configuration) {
        applyBarConfiguration(with: configuration)
        if isViewLoaded {
            applyConfiguration(with: configuration)
        } else {
            self.configuration = configuration
        }
    }
    
    @objc
    private func dismissKeyboard() {
        guard dismissKeyboardOnTap else { return }
        view.endEditing(true)
    }
    
    private func applyConfiguration(with configuration: Configuration) {
        setupView(
            for: configuration.contentTop,
            in: top,
            hideIfNeeded: top,
            spacingAnchror: topAnchor
        )
        setupView(
            for: configuration.contentMiddle,
            in: middleContainer,
            hideIfNeeded: middle,
            spacingAnchror: middleAnchor
        )
        setupView(
            for: configuration.contentBottom,
            in: bottom,
            hideIfNeeded: bottom,
            spacingAnchror: bottomAnchor
        )
        
        if let general = configuration.generalConfiguration {
            overrideUserInterfaceStyle = general.interfaceStyle
            userDidUseEnterKey = general.userDidUseEnterKey
            middle.isScrollEnabled = general.isScrollEnabled
            if !general.isScrollEnabled {
                NSLayoutConstraint.activate([
                    middle.frameLayoutGuide.topAnchor.constraint(equalTo: middle.contentLayoutGuide.topAnchor),
                    middle.frameLayoutGuide.bottomAnchor.constraint(equalTo: middle.contentLayoutGuide.bottomAnchor),
                    middleContainer.heightAnchor.constraint(equalTo: middle.frameLayoutGuide.heightAnchor)
                ])
            }
        }
        
        self.configuration = nil
    }
    
    private func applyBarConfiguration(with configuration: Configuration) {
        guard let barConfiguration = configuration.barConfiguration else { return }
        configureBars(with: barConfiguration)
        guard let statusBar = barConfiguration.statusBar else { return }
        configureStatusBar(statusBar)
    }
    
    private func setupView(
        for configuration: MainContainerContentGeneratable?,
        in parent: UIView,
        hideIfNeeded viewToHide: UIView,
        spacingAnchror: NSLayoutConstraint
    ) {
        guard let configuration else {
            hide(view: viewToHide, with: spacingAnchror)
            return
        }
        
        let generatedView = configuration.generate()
        switch configuration.placement {
        case .centerHorizontally:
            centerHorizontally(view: generatedView, in: parent)
        case .pinToParent:
            pin(view: generatedView, to: parent)
        case .centerHorizontallyLimitWidth:
            centerHorizontallyLimitWidth(with: generatedView, in: parent)
        case .centerLimitWidth:
            centerLimitWidth(with: generatedView, in: parent)
        }
    }
    
    private func centerHorizontally(view viewToCenter: UIView, in parent: UIView) {
        parent.addSubview(viewToCenter, with: [
            viewToCenter.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            viewToCenter.leadingAnchor.constraint(greaterThanOrEqualTo: parent.leadingAnchor),
            viewToCenter.trailingAnchor.constraint(lessThanOrEqualTo: parent.trailingAnchor),
            viewToCenter.topAnchor.constraint(equalTo: parent.topAnchor),
            viewToCenter.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ])
    }
    
    private func pin(view viewToPin: UIView, to parent: UIView) {
        parent.addSubview(viewToPin, with: [
            viewToPin.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            viewToPin.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            viewToPin.topAnchor.constraint(equalTo: parent.topAnchor),
            viewToPin.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ])
    }
    
    private func centerHorizontallyLimitWidth(with viewToCenter: UIView, in parent: UIView) {
        parent.addSubview(viewToCenter, with: [
            viewToCenter.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            viewToCenter.leadingAnchor.constraint(greaterThanOrEqualTo: parent.leadingAnchor),
            viewToCenter.trailingAnchor.constraint(lessThanOrEqualTo: parent.trailingAnchor),
            viewToCenter.topAnchor.constraint(equalTo: parent.topAnchor),
            viewToCenter.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            viewToCenter.widthAnchor.constraint(equalToConstant: Theme.Metrics.componentWidth)
        ])
    }
    
    private func centerLimitWidth(with viewToCenter: UIView, in parent: UIView) {
        parent.addSubview(viewToCenter, with: [
            viewToCenter.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            viewToCenter.centerYAnchor.constraint(equalTo: parent.centerYAnchor),
            viewToCenter.leadingAnchor.constraint(greaterThanOrEqualTo: parent.leadingAnchor),
            viewToCenter.trailingAnchor.constraint(lessThanOrEqualTo: parent.trailingAnchor),
            viewToCenter.topAnchor.constraint(equalTo: parent.topAnchor),
            viewToCenter.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            viewToCenter.widthAnchor.constraint(equalToConstant: Theme.Metrics.componentWidth)
        ])
    }
    
    private func hide(view viewToHidden: UIView, with spacingAnchor: NSLayoutConstraint) {
        viewToHidden.heightAnchor.constraint(equalToConstant: 0).isActive = true
        spacingAnchor.constant = 0
    }
    
    private func configureBars(with configuration: MainContainerBarConfigurable) {
        if let title = configuration.title {
            self.title = title
        }
        
        if let left = configuration.left {
            switch left {
            case .noButtons:
                navigationItem.hidesBackButton = true
            case .customBack(let callback):
                setCustomBackButton(systemBack: false)
                customBackAction = callback
            case .systemBack:
                setCustomBackButton(systemBack: true)
            case .cancel(let callback):
                setCustomCancelButton()
                customBackAction = callback
            }
        }
        
        if let right = configuration.right {
            switch right {
            case .skip(let callback):
                navigationItem.rightBarButtonItem = UIBarButtonItem(
                    title: T.Commons.skip,
                    style: .plain,
                    target: self,
                    action: #selector(skipAction)
                )
                customRightAction = callback
            default:
                break
            }
        }
        
        if let hideTabBar = configuration.hideTabBar {
            hidesBottomBarWhenPushed = hideTabBar
        }
        
        if let hideNavigationBar = configuration.hideNavigationBar {
            hidesNavigationBar = hideNavigationBar
        }
    }
    
    private func configureStatusBar(_ statusBar: MainContainerViewController.StatusBar) {
        switch statusBar {
        case .dark: preferredStatusBar = .darkContent
        case .light: preferredStatusBar = .lightContent
        case .hide: hideStatusBar = true
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden: Bool { hideStatusBar }
    override var preferredStatusBarStyle: UIStatusBarStyle { preferredStatusBar }
    override var childForStatusBarHidden: UIViewController? { self }
    
    @objc
    private func skipAction() {
        customRightAction?()
    }
    
    @objc
    override func customBackButtonAction() {
        customBackAction?()
    }
    
    @objc
    override func cancelButtonAction() {
        customBackAction?()
    }
}

extension MainContainerViewController {
    enum ViewPlacement {
        case centerHorizontally
        case pinToParent
        case centerHorizontallyLimitWidth
        case centerLimitWidth
    }
    
    struct Configuration {
        let barConfiguration: MainContainerBarConfigurable?
        let contentTop: MainContainerContentGeneratable?
        let contentMiddle: MainContainerContentGeneratable?
        let contentBottom: MainContainerContentGeneratable?
        let generalConfiguration: MainContainerGeneralConfigurable?
        
        init(
            barConfiguration: MainContainerBarConfigurable?,
            contentTop: MainContainerContentGeneratable?,
            contentMiddle: MainContainerContentGeneratable?,
            contentBottom: MainContainerContentGeneratable?,
            generalConfiguration: MainContainerGeneralConfigurable? = nil
        ) {
            self.barConfiguration = barConfiguration
            self.contentTop = contentTop
            self.contentMiddle = contentMiddle
            self.contentBottom = contentBottom
            self.generalConfiguration = generalConfiguration
        }
    }
    
    enum LeftBarButton {
        case noButtons
        case systemBack
        case customBack(callback: Callback)
        case cancel(callback: Callback)
    }
    
    enum RightBarButton {
        case noButtons
        case skip(callback: Callback)
    }
    
    enum StatusBar {
        case hide
        case light
        case dark
    }
}

protocol MainContainerBarConfigurable {
    var title: String? { get }
    var left: MainContainerViewController.LeftBarButton? { get }
    var right: MainContainerViewController.RightBarButton? { get }
    var hideTabBar: Bool? { get }
    var hideNavigationBar: Bool? { get }
    var statusBar: MainContainerViewController.StatusBar? { get }
}

protocol MainContainerContentGeneratable {
    var placement: MainContainerViewController.ViewPlacement { get }
    func generate() -> UIView
}

protocol MainContainerGeneralConfigurable {
    var interfaceStyle: UIUserInterfaceStyle { get }
    var userDidUseEnterKey: Callback? { get set }
    var isScrollEnabled: Bool { get }
}

extension MainContainerGeneralConfigurable {
    var isScrollEnabled: Bool { true }
}
