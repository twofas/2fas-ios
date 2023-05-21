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

protocol TokensSectionHeaderDataSource: AnyObject {
    func collapseAction(with section: TokensSection)
    func moveDown(_ section: TokensSection)
    func moveUp(_ section: TokensSection)
    func rename(_ section: TokensSection)
    func delete(_ section: TokensSection)
}

final class TokensSectionHeader: UICollectionReusableView {
    static let reuseIdentifier = "TokensSectionHeader"
    
    weak var dataSource: TokensSectionHeaderDataSource?
    
    private let spacingLineView: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.Colors.Line.secondaryLine
        return v
    }()
    
    private let titleLabel = StandardLabel()
    private let counter = ElementCounter()
    
    private let collapseButton = CollapseButton()
    private let upDown = UpDown()
    private let menuButton = MenuButton()
    
    private var normalConstraint: NSLayoutConstraint?
    private var editConstraint: NSLayoutConstraint?
    
    private let normalContainer = UIView()
    private let editContainer = UIView()
    
    private let bgView = UIView()
    
    private var isEditing = false
    
    private var config: TokensSection?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupBackground()
        setupLayout()
        setupCallbacks()
        setupMenu()
    }
        
    func setIsEditing(_ isEditing: Bool) {
        self.isEditing = isEditing
        setupContainers()
    }
    
    func setConfiguration(_ config: TokensSection) {
        self.config = config
        updateCollapsedState()
        
        upDown.isHidden = config.isNilSection || config.position == .notUsed

        setupContainers()
        counter.setCount(String(config.elementCount))
        setTitle(config.title ?? T.Tokens.myTokens)
        
        upDown.setState(config.position)
    }
}

private extension TokensSectionHeader {
    func setupBackground() {
        backgroundColor = Theme.Colors.Fill.System.second
    }
    
    func setupLayout() {
        addSubview(spacingLineView, with: [
            spacingLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            spacingLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            spacingLineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            spacingLineView.heightAnchor.constraint(equalToConstant: Theme.Metrics.lineWidth)
        ])
        
        addSubview(counter, with: [
            counter.topAnchor.constraint(equalTo: topAnchor, constant: Theme.Metrics.standardMargin),
            counter.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.Metrics.standardMargin),
            counter.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Metrics.doubleMargin)
        ])
        
        addSubview(titleLabel, with: [
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Theme.Metrics.standardMargin),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.Metrics.standardMargin),
            counter.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -Theme.Metrics.doubleMargin)
        ])
        
        setupNormalContainer()
        setupEditContainer()
        
        normalConstraint = titleLabel.trailingAnchor.constraint(
            equalTo: normalContainer.leadingAnchor,
            constant: -Theme.Metrics.doubleMargin
        )
        editConstraint = titleLabel.trailingAnchor.constraint(
            equalTo: editContainer.leadingAnchor,
            constant: -Theme.Metrics.doubleMargin
        )
        normalConstraint?.isActive = true
        
        counter.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        counter.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        upDown.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        collapseButton.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        menuButton.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
    }
    
    func setupCallbacks() {
        collapseButton.userChangedCollapse = { [weak self] in self?.collapseAction() }
        
        upDown.moveUp = { [weak self] in
            guard let config = self?.config else { return }
            self?.dataSource?.moveUp(config)
        }
        
        upDown.moveDown = { [weak self] in
            guard let config = self?.config else { return }
            self?.dataSource?.moveDown(config)
        }
    }
    
    func setupNormalContainer() {
        let margin = Theme.Metrics.standardMargin
        addSubview(normalContainer, with: [
            normalContainer.topAnchor.constraint(equalTo: topAnchor, constant: margin),
            normalContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin),
            normalContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin)
        ])
        
        normalContainer.addSubview(collapseButton, with: [
            collapseButton.leadingAnchor.constraint(equalTo: normalContainer.leadingAnchor, constant: margin),
            collapseButton.topAnchor.constraint(equalTo: normalContainer.topAnchor),
            collapseButton.bottomAnchor.constraint(equalTo: normalContainer.bottomAnchor),
            collapseButton.trailingAnchor.constraint(equalTo: normalContainer.trailingAnchor, constant: -margin)
        ])
                
        normalContainer.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(normalContainerTapAction))
        )
    }
    
    func setupEditContainer() {
        let margin = Theme.Metrics.standardMargin
        addSubview(editContainer, with: [
            editContainer.topAnchor.constraint(equalTo: topAnchor, constant: margin),
            editContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin),
            editContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin)
        ])
        
        editContainer.addSubview(upDown, with: [
            upDown.topAnchor.constraint(equalTo: editContainer.topAnchor),
            upDown.bottomAnchor.constraint(equalTo: editContainer.bottomAnchor),
            upDown.leadingAnchor.constraint(equalTo: editContainer.leadingAnchor)
        ])
        
        editContainer.addSubview(menuButton, with: [
            menuButton.topAnchor.constraint(equalTo: editContainer.topAnchor),
            menuButton.bottomAnchor.constraint(equalTo: editContainer.bottomAnchor),
            menuButton.leadingAnchor.constraint(equalTo: upDown.trailingAnchor, constant: margin),
            menuButton.trailingAnchor.constraint(equalTo: editContainer.trailingAnchor, constant: -margin)
        ])
    }
    
    func setupContainers() {
        if config?.isNilSection == true {
            normalContainer.isHidden = true
            editContainer.isHidden = true
            
            normalConstraint?.isActive = true
            editConstraint?.isActive = false
        } else {
            normalContainer.isHidden = isEditing
            editContainer.isHidden = !isEditing
            
            normalConstraint?.isActive = !isEditing
            editConstraint?.isActive = isEditing
        }
    }
    
    func updateCollapsedState() {
        guard let config else { return }
        
        if config.elementCount == 0 || config.isSearching {
            collapseButton.setState(.invisible)
        } else {
            if config.isCollapsed {
                collapseButton.setState(.collapsed)
            } else {
                collapseButton.setState(.expaned)
            }
        }
    }
    
    func setupMenu() {
        menuButton.menu = menu()
    }
    
    @objc
    func normalContainerTapAction() {
        collapseAction()
    }
    
    func collapseAction() {
        guard let config, collapseButton.isActive else { return }
        // Called here so changes in collection view won't animate it into "X"
        if config.isCollapsed {
            collapseButton.setState(.expaned)
        } else {
            collapseButton.setState(.collapsed)
        }
        dataSource?.collapseAction(with: config)
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title.uppercased()
    }
    
    func menu() -> UIMenu {
        let edit = UIAction(
            title: T.Commons.edit,
            image: UIImage(systemName: "pencil")
        ) { [weak self] _ in
            guard let config = self?.config else { return }
            self?.dataSource?.rename(config)
        }
        
        let delete = UIAction(
            title: T.Commons.delete,
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            guard let config = self?.config else { return }
            self?.dataSource?.delete(config)
        }
        
        return UIMenu(children: [edit, delete])
    }
}
