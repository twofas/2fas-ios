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

extension ComposeServiceViewController {
    func cell(
        for data: ComposeServiceSectionCell,
        in tableView: UITableView,
        at indexPath: IndexPath
    ) -> UITableViewCell {
        switch data.kind {
        case .input(let config):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ComposeServiceInputCell.identifier,
                for: indexPath
            ) as? ComposeServiceInputCell else { return UITableViewCell() }
            cell.configure(
                title: config.kind.title,
                value: config.value,
                kind: config.kind.inputKind,
                inputConfig: config.kind.inputConfig,
                isRequired: config.kind.isRequired
            )
            cell.didSelectActionButton = { [weak self] in self?.presenter.handleActionButton(for: $0) }
            cell.didUpdateValue = { [weak self, weak tableView] kind, value, shouldReload in
                self?.presenter.handleValueUpdate(for: kind, value: value?.trim())
                if shouldReload {
                    tableView?.beginUpdates()
                    tableView?.endUpdates()
                }
            }
            return cell
        case .privateKey(let config):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ComposeServicePrivateKeyCell.identifier,
                for: indexPath
            ) as? ComposeServicePrivateKeyCell else { return UITableViewCell() }
            let kind: ComposeServicePrivateKeyKind = {
                switch config.privateKeyKind {
                case .empty: .empty
                case .hidden: .hidden
                case .hiddenNonCopyable: .hiddenNonCopyable
                }
            }()
            cell.configure(privateKeyKind: kind)
            cell.value = config.value
            if let error = config.error {
                cell.showError(error.localizedStringValue)
            } else {
                cell.hideError()
            }
            cell.didSelectActionButton = { [weak self] in self?.presenter.handleActionButton(for: $0) }
            cell.didUpdateValue = { [weak self] kind, value in
                self?.presenter.handleValueUpdate(for: kind, value: value)
            }
            cell.revealButtonAction = { [weak self] in self?.presenter.handleReveal() }
            return cell
        case .navigate(let config):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingsMenuTableViewCell.identifier,
                for: indexPath
            ) as? SettingsMenuTableViewCell else { return UITableViewCell() }
            let accessoryType: SettingsMenuTableViewCell.AccessoryType = {
                if let acc = config.accessory {
                    if case let ComposeServiceSectionCell.NavigationConfig.AccessoryKind.badgeColor(color) = acc {
                        let badgeColorView = ComposeServiceBadgeColorView()
                        badgeColorView.setBadgeColor(color)
                        return .arrowWithCustomView(customView: badgeColorView)
                    } else if case let ComposeServiceSectionCell.NavigationConfig.AccessoryKind.label(text) = acc {
                        return .infoArrow(text: text)
                    }
                }
                return .arrow
            }()
            cell.update(icon: nil, title: config.kind.localizedStringValue, kind: accessoryType)
            if !config.isEnabled {
                cell.disable()
            }
            return cell
        case .action(let config):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingsMenuTableViewCell.identifier,
                for: indexPath
            ) as? SettingsMenuTableViewCell else { return UITableViewCell() }
            if config.kind == .delete {
                cell.update(icon: nil, title: T.Tokens.removeServiceFromApp, kind: .none, decorateText: .action)
            }
            return cell
        case .icon(let config):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ComposeServiceIconTypeSelection.identifier,
                for: indexPath
            ) as? ComposeServiceIconTypeSelection else { return UITableViewCell() }
            cell.set(
                iconTypeID: config.iconTypeID,
                labelTitle: config.labelTitle,
                labelColor: config.labelColor,
                iconTypeName: config.iconTypeName
            )
            let option: ComposeServiceIconTypeSelection.OptionSelected = {
                switch config.kind {
                case .label: return .label
                case .brand: return .brandIcon
                }
            }()
            cell.setSelectedOption(option)
            cell.didSelect = { [weak self] selected in
                let option: IconType = {
                    switch selected {
                    case .label: return .label
                    case .brandIcon: return .brand
                    }
                }()
                self?.presenter.handleIconType(option)
            }
            return cell
        }
    }
    
    func titleForHeader(
        offset: Int,
        snapshot: TableViewDataSnapshot<ComposeServiceSection, ComposeServiceSectionCell>
    ) -> String? {
        let section = snapshot.section(at: offset)
        return section.title
    }
    
    func didSelect(tableView: UITableView, indexPath: IndexPath, data: ComposeServiceSectionCell) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.handleSelection(at: indexPath, cell: data)
    }
}
