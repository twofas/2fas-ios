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

final class TokensView: UICollectionView {
    private var lastLayoutWidth: CGFloat = 0
    /// Called after every layout pass, i.e. on scroll, data reload and size change.
    var didLayout: Callback?

    override static var layerClass: AnyClass { TokensLayer.self }

    override var isEditing: Bool {
        get {
            super.isEditing
        }
        set {
            guard newValue != super.isEditing else { return }
            super.isEditing = newValue
            reloadHeaders()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.width != lastLayoutWidth {
            lastLayoutWidth = bounds.width
            collectionViewLayout.invalidateLayout()
        }
        didLayout?()
    }

    func configure() {
        backgroundColor = AppColor.backgroundsPrimary.uiColor
        register(TokensTOTPCell.self, forCellWithReuseIdentifier: TokensTOTPCell.reuseIdentifier)
        register(TokensHOTPCell.self, forCellWithReuseIdentifier: TokensHOTPCell.reuseIdentifier)
        register(TokensEditCell.self, forCellWithReuseIdentifier: TokensEditCell.reuseIdentifier)
        register(TokensTOTPCompactCell.self, forCellWithReuseIdentifier: TokensTOTPCompactCell.reuseIdentifier)
        register(TokensHOTPCompactCell.self, forCellWithReuseIdentifier: TokensHOTPCompactCell.reuseIdentifier)
        register(
            TokensEmptyDropSpaceCell.self,
            forCellWithReuseIdentifier: TokensEmptyDropSpaceCell.reuseIdentifier
        )
        register(TokensPassCell.self, forCellWithReuseIdentifier: TokensPassCell.reuseIdentifier)
        register(
            TokensSectionHeader.self,
            forSupplementaryViewOfKind: TokensSectionHeader.reuseIdentifier,
            withReuseIdentifier: TokensSectionHeader.reuseIdentifier
        )
    
        allowsSelectionDuringEditing = true
    }
    
    private func reloadHeaders() {
        guard let visible = visibleSupplementaryViews(
            ofKind: TokensSectionHeader.reuseIdentifier
        ) as? [TokensSectionHeader] else { return }
        visible.forEach({ $0.setIsEditing(isEditing) })
    }
}

private final class TokensLayer: CALayer, ZoomPushBackSuppressingLayer {
    var suppressesZoomPushBack = false

    override init() {
        super.init()
    }

    override init(layer: Any) {
        super.init(layer: layer)
        suppressesZoomPushBack = (layer as? TokensLayer)?.suppressesZoomPushBack ?? false
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
