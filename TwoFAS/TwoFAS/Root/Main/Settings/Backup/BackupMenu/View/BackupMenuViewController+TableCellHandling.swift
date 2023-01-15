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

extension BackupMenuViewController {
    func cell(for data: BackupMenuCell, in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsMenuTableViewCell.identifier,
            for: indexPath
        ) as? SettingsMenuTableViewCell else { return UITableViewCell() }
        let (accessoryType, isActive) = dataToKind(data, tableView: tableView)
        cell.update(icon: data.icon, title: data.title, kind: accessoryType, decorateText: textDecoration(for: data))
        if !isActive {
            cell.disableToggle()
        }
        if data.isEnabled {
            if data.action != nil {
                cell.selectionStyle = .default
            } else {
                cell.selectionStyle = .none
            }
        } else {
            cell.disable()
        }
        return cell
    }
    
    private func textDecoration(for data: BackupMenuCell) -> SettingsMenuTableViewCell.TextDecoration {
        guard data.action != nil else { return .none }
        return .action
    }
    
    func titleForHeader(offset: Int, snapshot: TableViewDataSnapshot<BackupMenuSection, BackupMenuCell>) -> String? {
        let section = snapshot.section(at: offset)
        return section.title
    }
    
    func titleForFooter(offset: Int, snapshot: TableViewDataSnapshot<BackupMenuSection, BackupMenuCell>) -> String? {
        let section = snapshot.section(at: offset)
        return section.footer
    }
    
    func didSelect(tableView: UITableView, indexPath: IndexPath, data: BackupMenuCell) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.handleSelection(at: indexPath)
    }
    
    private func dataToKind(
        _ data: BackupMenuCell,
        tableView: UITableView
    ) -> (SettingsMenuTableViewCell.AccessoryType, isActive: Bool) {
        if let toggle = data.accessory {
            return (.toggle(isEnabled: toggle.isOn) { [weak tableView, weak self] calledCell, _ in
                guard let indexPath = tableView?.indexPath(for: calledCell) else { return }
                self?.presenter.handleToggle(for: indexPath)
            }, isActive: toggle.isActive)
        }
        return (.none, true)
    }
}
