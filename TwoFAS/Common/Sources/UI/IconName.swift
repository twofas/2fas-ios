//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

import SwiftUI

public enum IconName: String {
    case appleWatch = "applewatch"
    case applewatchAndArrowForward = "applewatch.and.arrow.forward"
    case arrowClockwise = "arrow.clockwise"
    case arrowDown = "arrow.down"
    case arrowDownCircleFill = "arrow.down.circle.fill"
    case arrowLeftArrowRight = "arrow.left.arrow.right"
    case arrowRight = "arrow.right"
    case arrowUp = "arrow.up"
    case arrowUpDocFill = "arrow.up.doc.fill"
    case arrowUpForward = "arrow.up.forward"
    case arrowUpRight = "arrow.up.right"
    case arrowTrianglehead2ClockwiseRotate90 = "arrow.trianglehead.2.clockwise.rotate.90"
    case arrowTrianglehead2ClockwiseRotate90IcloudFill = "arrow.trianglehead.2.clockwise.rotate.90.icloud.fill"
    case bellBadge = "bell.badge"
    case bellBadgeSlash = "bell.badge.slash"
    case bellFill = "bell.fill"
    case briefcase = "briefcase"
    case checkmark = "checkmark"
    case checkmarkCircle = "checkmark.circle"
    case checkmarkCircleFill = "checkmark.circle.fill"
    case checkmarkShieldFill = "checkmark.shield.fill"
    case chevronBackward = "chevron.backward"
    case chevronDown = "chevron.down"
    case chevronLeft = "chevron.left"
    case chevronRight = "chevron.right"
    case chevronUp = "chevron.up"
    case chevronUpChevronDown = "chevron.up.chevron.down"
    case circleFill = "circle.fill"
    case cloudFill = "cloud.fill"
    case deleteBackward = "delete.backward"
    case deleteLeft = "delete.left"
    case desktopcomputerAndArrowDown = "desktopcomputer.and.arrow.down"
    case doc = "doc"
    case docFill = "doc.fill"
    case docOnDoc = "doc.on.doc"
    case documentBadgeEllipsis = "document.badge.ellipsis"
    case documentFill = "document.fill"
    case ellipsis = "ellipsis"
    case exclamationmarkIcloud = "exclamationmark.icloud"
    case exclamationmarkTriangle = "exclamationmark.triangle"
    case exclamationmarkTriangleFill = "exclamationmark.triangle.fill"
    case eyeFill = "eye.fill"
    case eyeSlashFill = "eye.slash.fill"
    case faceid = "faceid"
    case folder = "folder"
    case gear = "gear"
    case gearshape = "gearshape"
    case icloud = "icloud"
    case icloudSlash = "icloud.slash"
    case infoBubbleFill = "info.bubble.fill"
    case infoCircleFill = "info.circle.fill"
    case keyHorizontalFill = "key.horizontal.fill"
    case ladybugFill = "ladybug.fill"
    case laptopcomputerTrianglebadgeExclamationmark = "laptopcomputer.trianglebadge.exclamationmark"
    case line3Horizontal = "line.3.horizontal"
    case link = "link"
    case lockAppleWatch = "lock.applewatch"
    case lockBadgeClockFill = "lock.badge.clock.fill"
    case lockFill = "lock.fill"
    case lockIcloudFill = "lock.icloud.fill"
    case lockOpenFill = "lock.open.fill"
    case lockOpenRotation = "lock.open.rotation"
    case lockRotation = "lock.rotation"
    case macbookAndIphone = "macbook.and.iphone"
    case magnifyingglass = "magnifyingglass"
    case pencil = "pencil"
    case person = "person"
    case personBadgeShieldCheckmark = "person.badge.shield.checkmark"
    case photo = "photo"
    case photoBadgeMagnifyingglass = "photo.badge.magnifyingglass"
    case plus = "plus"
    case puzzlepieceExtensionFill = "puzzlepiece.extension.fill"
    case qrcode = "qrcode"
    case qrcodeViewfinder = "qrcode.viewfinder"
    case questionmarkCircle = "questionmark.circle"
    case questionmarkCircleFill = "questionmark.circle.fill"
    case rectangleOnRectangle = "rectangle.on.rectangle"
    case sidebarLeft = "sidebar.left"
    case squareAndArrowDown = "square.and.arrow.down"
    case squareAndArrowDownOnSquareFill = "square.and.arrow.down.on.square.fill"
    case squareAndArrowUp = "square.and.arrow.up"
    case squareAndPencil = "square.and.pencil"
    case squareGrid2x2Fill = "square.grid.2x2.fill"
    case star = "star"
    case starFill = "star.fill"
    case staroflifeShield = "staroflife.shield"
    case staroflifeShieldFill = "staroflife.shield.fill"
    case touchid = "touchid"
    case trash = "trash"
    case trashFill = "trash.fill"
    case trashSlash = "trash.slash"
    case xmark = "xmark"
    case xmarkCircleFill = "xmark.circle.fill"
    case xmarkIcloudFill = "xmark.icloud.fill"
}

public extension Image {
    init(icon: IconName) {
        self.init(systemName: icon.rawValue)
    }
}

public extension Label where Title == Text, Icon == Image {
    init(_ title: String, icon: IconName) {
        self.init(title, systemImage: icon.rawValue)
    }
}

public extension UIImage {
    convenience init?(icon: IconName) {
        self.init(systemName: icon.rawValue)
    }

    convenience init?(icon: IconName, withConfiguration configuration: UIImage.Configuration?) {
        self.init(systemName: icon.rawValue, withConfiguration: configuration)
    }
}
