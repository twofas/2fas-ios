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
    func collapseAction(with section: GridSection)
    func moveDown(_ section: GridSection)
    func moveUp(_ section: GridSection)
    func rename(_ section: GridSection, with title: String)
    func delete(_ section: GridSection)
}

final class GridSectionHeader: UICollectionReusableView {
    static let reuseIdentifier = "GridSectionHeader"
    
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
    
//    private var editLabelLeading: NSLayoutConstraint?
    
    private let normalContainer = UIView()
    private let editContainer = UIView()
        
    private var config: GridSection?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = Theme.Colors.Fill.System.forth
        
//        accessoryView = menuButton
        menuButton.menu = menu()
        
        collapseButton.userChangedCollapse = { [weak self] in self?.collapseAction() }
        
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
            counter.topAnchor.constraint(equalTo: topAnchor, constant: Theme.Metrics.standardMargin),
            counter.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.Metrics.standardMargin),
            counter.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Theme.Metrics.doubleMargin)
        ])
        
        setupNormalContainer()
        setupEditContainer()
        
        upDown.moveUp = { [weak self] in
            guard let config = self?.config else { return }
            self?.dataSource?.moveUp(config)
        }
        
        upDown.moveDown = { [weak self] in
            guard let config = self?.config else { return }
            self?.dataSource?.moveDown(config)
        }
        
        //ServiceRules.isSectionNameValid(sectionName: newText.trim())
    }
        
    func setIsEditing(_ isEditing: Bool) {
        normalContainer.isHidden = isEditing
        editContainer.isHidden = !isEditing
        // switch anchors for title label!
    }
    
    func setConfiguration(_ config: GridSection) {
        self.config = config
        updateCollapsedState()
        
        let isNilSection = (config.sectionID == nil)
        
        upDown.isHidden = isNilSection || config.position == .notUsed
//        if isNilSection {
//            editLabelLeading?.constant = Theme.Metrics.doubleMargin
//        } else {
//            editLabelLeading?.constant = Theme.Metrics.doubleMargin + UpDown.totalWidth
//        }
        
        setTitle(config.title ?? T.Tokens.myTokens, numberOfItems: config.elementCount)
        upDown.setState(config.position)
        
        setTitle(config.title ?? "", numberOfItems: config.elementCount)
    }
    
    private func updateCollapsedState() {
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
    
    private func setupNormalContainer() {
        addSubview(normalContainer, with: [
            normalContainer.topAnchor.constraint(equalTo: topAnchor, constant: Theme.Metrics.standardMargin),
            normalContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.Metrics.standardMargin),
            normalContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Metrics.standardMargin)
        ])
        
        normalContainer.addSubview(collapseButton)
        collapseButton.pinToParent()
                
        normalContainer.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(normalContainerTapAction))
        )
    }
    
    private func setupEditContainer() {
        addSubview(editContainer, with: [
            editContainer.topAnchor.constraint(equalTo: topAnchor, constant: Theme.Metrics.standardMargin),
            editContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.Metrics.standardMargin),
            editContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Metrics.standardMargin)
        ])
        
        editContainer.addSubview(upDown, with: [
            upDown.topAnchor.constraint(equalTo: editContainer.topAnchor),
            upDown.bottomAnchor.constraint(equalTo: editContainer.bottomAnchor),
            upDown.leadingAnchor.constraint(equalTo: editContainer.leadingAnchor)
        ])
        
        editContainer.addSubview(menuButton, with: [
            menuButton.topAnchor.constraint(equalTo: editContainer.topAnchor),
            menuButton.bottomAnchor.constraint(equalTo: editContainer.bottomAnchor),
            menuButton.leadingAnchor.constraint(equalTo: upDown.trailingAnchor, constant: Theme.Metrics.standardMargin),
            menuButton.trailingAnchor.constraint(equalTo: editContainer.trailingAnchor)
        ])
    }
    
    @objc
    private func normalContainerTapAction() {
        collapseAction()
    }
    
//    @objc
//    private func doneAction() {
//        titleInput.resignFirstResponder()
//        editContainer.isHidden = false
//        editSectionContainer.isHidden = true
//        guard
//            let config,
//            let newTitle = titleInput.text?.trim(),
//            newTitle != config.title,
//            !newTitle.isEmpty
//        else { return }
//        dataSource?.rename(config, with: newTitle)
//    }
    
    private func collapseAction() {
        guard let config, collapseButton.isActive else { return }
        // Called here so changes in collection view won't animate it into "X"
        if config.isCollapsed {
            collapseButton.setState(.expaned)
        } else {
            collapseButton.setState(.collapsed)
        }
        dataSource?.collapseAction(with: config)
    }
    
    private func setTitle(_ title: String, numberOfItems: Int) {
        titleLabel.text = title.uppercased()
    }
    
    private func menu() -> UIMenu {
        let edit = UIAction(
            title: T.Commons.edit,
            image: UIImage(systemName: "pencil")
        ) { [weak self] _ in
            guard let config = self?.config else { return }
//            guard let currentIndexPath = self?.currentIndexPath else { return }
//            self?.restore?(currentIndexPath)
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
