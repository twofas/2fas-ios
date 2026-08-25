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
    /// Set for the duration of a presentation whose push-back of this view
    /// should be suppressed.
    ///
    /// The system zoom transition scales the presenting view controller's
    /// content by animating its layer's `sublayerTransform` (≈0.91 while
    /// presented). There is no public option to opt out, so while this flag
    /// is set the view's layer ignores any `sublayerTransform` change,
    /// keeping its content exactly where it is. With the flag unset the
    /// layer behaves like a regular `CALayer`.
    var disablesSublayerTransform = false

    override class var layerClass: AnyClass { MainLayer.self }

    private final class MainLayer: CALayer {
        private var sublayerTransformDisabled: Bool {
            (delegate as? MainView)?.disablesSublayerTransform == true
        }
        
        override var sublayerTransform: CATransform3D {
            get { sublayerTransformDisabled ? CATransform3DIdentity : super.sublayerTransform }
            set {
                guard !sublayerTransformDisabled else { return }
                super.sublayerTransform = newValue
            }
        }
    }
}
