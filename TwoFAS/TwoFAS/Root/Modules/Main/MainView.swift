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

import UIKit

/// `MainViewController`'s root view.
final class MainView: UIView {
    override static var layerClass: AnyClass { MainLayer.self }
}

private final class MainLayer: CALayer, ZoomPushBackSuppressingLayer {
    var suppressesZoomPushBack = false

    override init() {
        super.init()
    }

    override init(layer: Any) {
        super.init(layer: layer)
        suppressesZoomPushBack = (layer as? MainLayer)?.suppressesZoomPushBack ?? false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override var sublayerTransform: CATransform3D {
        get { suppressesZoomPushBack ? CATransform3DIdentity : super.sublayerTransform }
        set {
            guard !suppressesZoomPushBack else { return }
            super.sublayerTransform = newValue
        }
    }
}
