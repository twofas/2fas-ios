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

extension SettingsMenuViewController {
    func cell(for data: SettingsMenuCell, in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsMenuTableViewCell.identifier,
            for: indexPath
        ) as? SettingsMenuTableViewCell else { return UITableViewCell() }
        cell.update(
            icon: data.icon,
            title: data.title,
            kind: dataToKind(data, tableView: tableView),
            decorateText: dataToTextDecoration(data)
        )
        if data.shouldSelectCell {
            cell.selectionStyle = .default
        } else {
            cell.selectionStyle = .none
        }
        return cell
    }
    
    func titleForHeader(
        offset: Int,
        snapshot: TableViewDataSnapshot<SettingsMenuSection, SettingsMenuCell>
    ) -> String? {
        let section = snapshot.section(at: offset)
        return section.title
    }
    
    func titleForFooter(
        offset: Int,
        snapshot: TableViewDataSnapshot<SettingsMenuSection, SettingsMenuCell>
    ) -> String? {
        let section = snapshot.section(at: offset)
        return section.footer
    }
    
    func didSelect(tableView: UITableView, indexPath: IndexPath, data: SettingsMenuCell) {
        presenter.handleSelection(at: indexPath)
    }
    
    private func dataToKind(
        _ data: SettingsMenuCell,
        tableView: UITableView
    ) -> SettingsMenuTableViewCell.AccessoryType {
        if let accessory = data.accessory {
            switch accessory {
            case .arrow:
                if let info = data.info {
                    return .infoArrow(text: info)
                }
                return .arrow
            case .toggle(_, let isOn):
                return .toggle(isEnabled: isOn) { [weak tableView, weak self] calledCell, _ in
                    guard let indexPath = tableView?.indexPath(for: calledCell) else { return }
                    self?.presenter.handleToggle(for: indexPath)
                }
            case .customView(let cView):
                return .customView(customView: cView)
            case .external:
                let img = Asset.externalLinkIcon.image
                    .withRenderingMode(.alwaysTemplate)
                    .withTintColor(Theme.Colors.Icon.theme)
                let view = UIImageView(image: img)
                view.tintColor = Theme.Colors.Icon.theme
                return .customView(customView: view)
            case .warning:
                return .none
            case .donate:
                let exteralLinkImage = Asset.externalLinkIcon.image
                    .withRenderingMode(.alwaysTemplate)
                    .withTintColor(Theme.Colors.Icon.theme)
                let donateLabel = {
                    let label = UILabel()
                    label.textColor = Theme.Colors.Text.theme
                    label.text = T.Settings.itMatters
                    label.minimumScaleFactor = 0.3
                    label.adjustsFontSizeToFitWidth = true
                    label.numberOfLines = 1
                    label.allowsDefaultTighteningForTruncation = true
                    label.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
                    label.baselineAdjustment = .alignBaselines
                    return label
                }()
                let customView = {
                    let img = UIImageView(image: exteralLinkImage)
                    img.tintColor = Theme.Colors.Icon.theme
                    img.contentMode = .right
                    let view = UIView()
                    view.addSubview(donateLabel, with: [
                        donateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                        donateLabel.topAnchor.constraint(equalTo: view.topAnchor),
                        donateLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                    ])
                    view.addSubview(img, with: [
                        img.leadingAnchor.constraint(
                            equalTo: donateLabel.trailingAnchor,
                            constant: Theme.Metrics.standardMargin
                        ),
                        img.topAnchor.constraint(equalTo: view.topAnchor),
                        img.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                        img.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                    ])
                    return view
                }()
                return .customView(customView: customView)
            }
        } else if let info = data.info {
            return .info(text: info)
        }
        
        return .none
    }
    
    private func dataToTextDecoration(_ data: SettingsMenuCell) -> SettingsMenuTableViewCell.TextDecoration {
        switch data.accessory {
        case .warning: return .action
        default: return .none
        }
    }
}
