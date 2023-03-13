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

final class IntroductionViewController: UIViewController {
    private let doubleMargin = Theme.Metrics.doubleMargin
    private let singleMargin = Theme.Metrics.standardMargin
    private let naviContainer = NaviContainer()
    private let mainActionButton = LoadingContentButton()
    private let scrollView = IntroductionScrollView()
    private let backButton = CustomBackButton()
    
    private var mainButtonAdditionalAction: Callback?
    
    var viewModel: IntroductionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        view.backgroundColor = Theme.Colors.Fill.background
        
        view.addSubview(scrollView, with: [
            scrollView.topAnchor.constraint(equalTo: view.safeTopAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.addSubview(naviContainer, with: [
            naviContainer.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
            naviContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            naviContainer.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        view.addSubview(mainActionButton, with: [
            mainActionButton.topAnchor.constraint(equalTo: naviContainer.bottomAnchor, constant: singleMargin),
            mainActionButton.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: 2 * doubleMargin
            ),
            mainActionButton.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -2 * doubleMargin
            ),
            mainActionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainActionButton.heightAnchor.constraint(equalToConstant: Theme.Metrics.buttonHeight),
            mainActionButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -singleMargin)
        ])
        
        naviContainer.alpha = 1
        naviContainer.configure(pagesNum: IntroductionCommons.pageCount)
        naviContainer.openTOS = { [weak self] in self?.viewModel.tosPressed() }
        mainActionButton.apply(MainContainerButtonStyling.filledInDecoratedContainerLightText.value)
        mainActionButton.alpha = 1
        mainActionButton.action = { [weak self] in self?.mainActionButtonAction() }
        
        scrollView.didChangePage = { [weak self] in
            self?.viewModel.didMoveToPage($0)
            self?.didChangePage($0)
        }
        
        backButton.addTarget(self, action: #selector(prevAction), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.didAppear()
    }
    
    @objc
    private func skipAction() {
        viewModel.skipPressed()
    }
    
    @objc
    private func prevAction() {
        viewModel.previousButtonPressed()
    }
    
    private func mainActionButtonAction() {
        mainButtonAdditionalAction?()
        viewModel.actionButtonPressed()
    }
}

extension IntroductionViewController: IntroductionViewModelDelegate {
    func moveToPage(_ num: Int) {
        scrollView.moveToPage(num: num)
        didChangePage(num)
    }
    
    func didChangePage(_ num: Int) {
        mainActionButton.update(title: scrollView.container.mainButtonTitle(for: num))
        mainButtonAdditionalAction = scrollView.container.mainButtonAdditionalAction(for: num)
        naviContainer.navigateToPage(num)
        if scrollView.container.showSkip(for: num) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: T.Commons.skip,
                style: .plain,
                target: self,
                action: #selector(skipAction)
            )
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        
        if scrollView.container.showBack(for: num) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }
}

private final class CustomBackButton: UIButton {
    private let spacing: CGFloat = 4
    private let imgView: UIImageView = {
        let img = UIImage(
            systemName: "chevron.backward",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        )
        let image = UIImageView(image: img)
        image.contentMode = .left
        return image
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
        addSubview(imgView, with: [
            imgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -spacing),
            imgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing),
            imgView.topAnchor.constraint(equalTo: topAnchor),
            imgView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                imgView.tintColor = Theme.Colors.Controls.highlighed
            } else {
                imgView.tintColor = Theme.Colors.Controls.active
            }
        }
    }
}
