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

/// Root view of the main screen: its content doesn't get "pushed back" by
/// system presentation transitions while `isStabilizationActive` is set.
///
/// The system zoom transition scales the presenting view controller's content
/// by animating its layer's `sublayerTransform` (≈0.91 while presented). There
/// is no public option to opt out, so this view uses a layer that ignores any
/// `sublayerTransform` change while stabilization is active, keeping its
/// content exactly where it is. With stabilization inactive the layer
/// behaves like a regular `CALayer`.
final class MainView: UIView {
    /// Set for the duration of a presentation whose push-back of this view
    /// should be suppressed.
    var isStabilizationActive = false

    override class var layerClass: AnyClass { MainLayer.self }

    private final class MainLayer: CALayer {
        private var isStabilized: Bool {
            (delegate as? MainView)?.isStabilizationActive == true
        }

        override var sublayerTransform: CATransform3D {
            get { isStabilized ? CATransform3DIdentity : super.sublayerTransform }
            set {
                guard !isStabilized else { return }
                super.sublayerTransform = newValue
            }
        }
    }
}
