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
    
    private let titleLabelNormal = StandardLabel()
    private let titleLabelEdit = StandardLabel()
    
    private let collapseButton = CollapseButton()
    private let upDown = UpDown()
    
    private let deleteButtonWidth: CGFloat = 35
    private let deleteButton: UIButton = {
        let b = UIButton()
        b.setImage(Asset.deleteIcon.image, for: .normal)
        return b
    }()
    
    private let titleInput: UnderscoredInput = {
        let input = UnderscoredInput()
        input.hideUnderscore()
        input.textColor = Theme.Colors.inactiveInverted
        input.font = Theme.Fonts.sectionHeader
        input.maxLength = ServiceRules.maxSectionNameLenght
        input.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        input.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        return input
    }()
    
    private var editLabelLeading: NSLayoutConstraint?
    
    private let editButton: UIButton = {
        let b = UIButton()
        b.setTitle(T.Commons.edit, for: .normal)
        b.titleLabel?.font = Theme.Fonts.Text.content
        b.setTitleColor(Theme.Colors.Text.theme, for: .normal)
        b.setTitleColor(Theme.Colors.Text.themeHighlighted, for: .highlighted)
        b.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        return b
    }()
    
    private let doneButton: UIButton = {
        let b = UIButton()
        b.setTitle(T.Commons.done, for: .normal)
        b.titleLabel?.font = Theme.Fonts.Text.content
        b.setTitleColor(Theme.Colors.Text.theme, for: .normal)
        b.setTitleColor(Theme.Colors.Text.themeHighlighted, for: .highlighted)
        b.setTitleColor(Theme.Colors.Text.inactive, for: .disabled)
        b.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        return b
    }()
    
    private let normalContainer = UIView()
    private let editContainer = UIView()
    private let editSectionContainer = UIView()
        
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
        
        collapseButton.userChangedCollapse = { [weak self] in self?.collapseAction() }
        
        addSubview(spacingLineView, with: [
            spacingLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            spacingLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            spacingLineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            spacingLineView.heightAnchor.constraint(equalToConstant: Theme.Metrics.lineWidth)
        ])
        
        addSubview(normalContainer)
        normalContainer.pinToParent()
        setupNormalContainerContent()
        
        addSubview(editContainer)
        editContainer.pinToParent()
        setupEditContainerContent()
        
        addSubview(editSectionContainer)
        editSectionContainer.pinToParent()
        setupEditSectionContainerContent()
        
        upDown.moveUp = { [weak self] in
            guard let config = self?.config else { return }
            self?.dataSource?.moveUp(config)
        }
        
        upDown.moveDown = { [weak self] in
            guard let config = self?.config else { return }
            self?.dataSource?.moveDown(config)
        }
        
        titleInput.textDidChange = { [weak self] newText in
            self?.doneButton.isEnabled = ServiceRules.isSectionNameValid(sectionName: newText)
        }
        
        doneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editAction), for: .touchUpInside)
    }
        
    func setIsEditing(_ isEditing: Bool) {
        normalContainer.isHidden = isEditing
        editContainer.isHidden = !isEditing
        editSectionContainer.isHidden = true
    }
    
    func setConfiguration(_ config: GridSection) {
        self.config = config
        updateCollapsedState()
        
        let isNilSection = (config.sectionID == nil)
        
        upDown.isHidden = isNilSection || config.position == .notUsed
        editButton.isHidden = isNilSection
        if isNilSection {
            editLabelLeading?.constant = Theme.Metrics.doubleMargin
        } else {
            editLabelLeading?.constant = Theme.Metrics.doubleMargin + UpDown.totalWidth
        }
        
        setTitle(config.title ?? T.Tokens.myTokens, numberOfItems: config.elementCount)
        upDown.setState(config.position)
        
        titleInput.setText(config.title ?? "")
        doneButton.isEnabled = true
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
    
    private func setupNormalContainerContent() {
        normalContainer.addSubview(titleLabelNormal, with: [
            titleLabelNormal.topAnchor.constraint(equalTo: normalContainer.topAnchor),
            titleLabelNormal.bottomAnchor.constraint(equalTo: normalContainer.bottomAnchor),
            titleLabelNormal.leadingAnchor.constraint(
                equalTo: normalContainer.leadingAnchor,
                constant: Theme.Metrics.doubleMargin
            )
        ])
        
        normalContainer.addSubview(collapseButton, with: [
            collapseButton.topAnchor.constraint(equalTo: normalContainer.topAnchor),
            collapseButton.bottomAnchor.constraint(equalTo: normalContainer.bottomAnchor),
            collapseButton.trailingAnchor.constraint(equalTo: normalContainer.trailingAnchor),
            collapseButton.heightAnchor.constraint(equalTo: collapseButton.widthAnchor)
        ])
        
        normalContainer.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(normalContainerTapAction))
        )
    }
    
    private func setupEditContainerContent() {
        editContainer.addSubview(upDown, with: [
            upDown.topAnchor.constraint(equalTo: editContainer.topAnchor),
            upDown.bottomAnchor.constraint(equalTo: editContainer.bottomAnchor),
            upDown.leadingAnchor.constraint(equalTo: editContainer.leadingAnchor)
        ])
        
        let leading = titleLabelEdit.leadingAnchor.constraint(
            equalTo: editContainer.leadingAnchor, constant: Theme.Metrics.doubleMargin + UpDown.totalWidth
        )
        editLabelLeading = leading
        editContainer.addSubview(titleLabelEdit, with: [
            titleLabelEdit.topAnchor.constraint(equalTo: editContainer.topAnchor),
            titleLabelEdit.bottomAnchor.constraint(equalTo: editContainer.bottomAnchor),
            leading
        ])
        editContainer.addSubview(editButton, with: [
            editButton.leadingAnchor.constraint(
                equalTo: titleLabelEdit.trailingAnchor,
                constant: Theme.Metrics.doubleMargin
            ),
            editButton.topAnchor.constraint(equalTo: normalContainer.topAnchor),
            editButton.bottomAnchor.constraint(equalTo: normalContainer.bottomAnchor),
            editButton.trailingAnchor.constraint(
                equalTo: normalContainer.trailingAnchor,
                constant: -Theme.Metrics.doubleMargin
            )
        ])
    }
    
    private func setupEditSectionContainerContent() {
        editSectionContainer.addSubview(deleteButton, with: [
            deleteButton.topAnchor.constraint(equalTo: editSectionContainer.topAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: editSectionContainer.bottomAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: editSectionContainer.leadingAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: deleteButtonWidth)
        ])
        
        editSectionContainer.addSubview(titleInput, with: [
            titleInput.topAnchor.constraint(equalTo: editSectionContainer.topAnchor),
            titleInput.bottomAnchor.constraint(equalTo: editSectionContainer.bottomAnchor),
            titleInput.leadingAnchor.constraint(
                equalTo: deleteButton.trailingAnchor,
                constant: Theme.Metrics.standardMargin
            )
        ])
        editSectionContainer.addSubview(doneButton, with: [
            doneButton.leadingAnchor.constraint(
                equalTo: titleInput.trailingAnchor,
                constant: Theme.Metrics.doubleMargin
            ),
            doneButton.topAnchor.constraint(equalTo: editSectionContainer.topAnchor),
            doneButton.bottomAnchor.constraint(equalTo: editSectionContainer.bottomAnchor),
            doneButton.trailingAnchor.constraint(
                equalTo: editSectionContainer.trailingAnchor,
                constant: -Theme.Metrics.doubleMargin
            )
        ])
    }
    
    @objc
    private func normalContainerTapAction() {
        collapseAction()
    }
    
    @objc
    private func doneAction() {
        titleInput.resignFirstResponder()
        editContainer.isHidden = false
        editSectionContainer.isHidden = true
        guard let config, let newTitle = titleInput.text, newTitle != config.title else { return }
        dataSource?.rename(config, with: newTitle)
    }
    
    @objc
    private func deleteAction() {
        guard let config else { return }
        dataSource?.delete(config)
    }
    
    @objc
    private func editAction() {
        editContainer.isHidden = true
        editSectionContainer.isHidden = false
        titleInput.becomeFirstResponder()
    }
    
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
        let text = "\(title) (\(numberOfItems))".uppercased()
        titleLabelNormal.text = text
        titleLabelEdit.text = text
    }
}
