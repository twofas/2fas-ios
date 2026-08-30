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
import Common

/// A `TokensSectionHeader` that floats at the top edge of a scroll view, standing in for the
/// section header that has scrolled out of view. Place it above the scroll view (as a sibling,
/// not a subview) and pin `header`'s top to the safe area; move it with `pushOffset` when the next
/// section header is about to take its place. Only the header's own area takes touches. The header
/// stays accessible, so the list header it stands in for should hide its own content meanwhile.
///
/// From iOS 26 the scroll view's top scroll-edge effect is extended behind this view, so the
/// blur continues down to the header's bottom edge while the header stays transparent. On iOS 26
/// the effect covers only this view, which would leave a gap below the navigation bar's own, so
/// the view reaches `edgeEffectExtension` points above the header to overlap it; iOS 27 fills the
/// effect from the scroll view's edge on its own. Earlier systems draw an opaque navigation bar,
/// and the header keeps its own opaque band, which also hides the content scrolling beneath it.
final class TokensFloatingSectionHeader: UIView {
    /// How far above the header the scroll-edge effect is extended: enough to overlap the
    /// navigation bar's own effect on iOS 26, nothing from iOS 27, which fills the effect from the
    /// scroll view's edge on its own.
    static var edgeEffectExtension: CGFloat {
        if #available(iOS 27.0, *) {
            return 0
        }
        return 44
    }

    let header = TokensSectionHeader()
    
    /// Covers the whole view so the scroll-edge effect is extended behind all of it, not only
    /// behind the header; the interaction sizes the effect from the elements it finds inside.
    private let effectFiller: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = false
        label.isAccessibilityElement = false
        return label
    }()

    /// Vertical offset applied when the next section header pushes this one out; `0` or negative.
    var pushOffset: CGFloat = 0 {
        didSet {
            guard pushOffset != oldValue else { return }
            transform = CGAffineTransform(translationX: 0, y: pushOffset)
        }
    }

    init(scrollView: UIScrollView) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let topExtension: CGFloat
        if #available(iOS 26.0, *) {
            topExtension = Self.edgeEffectExtension
            addSubview(effectFiller)
            effectFiller.pinToParent()
            let interaction = UIScrollEdgeElementContainerInteraction()
            interaction.scrollView = scrollView
            interaction.edge = .top
            addInteraction(interaction)
        } else {
            topExtension = 0
        }
        addSubview(header, with: [
            header.topAnchor.constraint(equalTo: topAnchor, constant: topExtension),
            header.leadingAnchor.constraint(equalTo: leadingAnchor),
            header.trailingAnchor.constraint(equalTo: trailingAnchor),
            header.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        header.frame.contains(point)
    }
}
