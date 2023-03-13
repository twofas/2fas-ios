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

import Foundation
import UIKit

extension TrashViewController {
    func cell(for data: TrashCell, in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TrashViewTableViewCell.identifier,
                for: indexPath
            ) as? TrashViewTableViewCell
        else { return UITableViewCell() }
        cell.update(icon: data.icon, title: data.title, subtitle: data.subtitle, indexPath: indexPath)
        
        cell.restore = { [weak self] in self?.presenter.handleRestoration(at: $0) }
        cell.delete = { [weak self] in self?.presenter.handleTrashing(at: $0) }
        
        return cell
    }   
}
