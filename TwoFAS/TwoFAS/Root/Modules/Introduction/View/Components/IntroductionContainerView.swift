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

final class IntroductionContainerView: UIView {
    private let minimalSpacing: CGFloat = Theme.Metrics.doubleMargin
    
    var didFinishAnimation: Callback?
    
    private let page1 = IntroductionPage1View()
    private let page2 = IntroductionPage2View()
    private let page3 = IntroductionPage3View()
    private let page4 = IntroductionPage4View()
    
    private var pages: [IntroductionPageView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        pages = [page1, page2, page3, page4]
        let pageSize: CGFloat = 1.0 / CGFloat(pages.count)
        let halfPageSize: CGFloat = pageSize / 2.0

        pages.enumerated().forEach({ index, p in
            p.translatesAutoresizingMaskIntoConstraints = false
            addSubview(p)
            let multiplier: CGFloat = (CGFloat(index) * pageSize + halfPageSize)
            NSLayoutConstraint.activate([
                p.centerYAnchor.constraint(equalTo: centerYAnchor),
                NSLayoutConstraint(
                    item: p,
                    attribute: .width,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .width,
                    multiplier: pageSize,
                    constant: 0
                ),
                NSLayoutConstraint(
                    item: p,
                    attribute: .centerX,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .trailing,
                    multiplier: multiplier,
                    constant: 0
                ),
                p.topAnchor.constraint(equalTo: topAnchor, constant: 0),
                p.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -minimalSpacing)
            ])
        })
    }
    
    func mainButtonTitle(for num: Int) -> String {
        pages[num].mainButtonTitle
    }
    
    func mainButtonAdditionalAction(for num: Int) -> Callback? {
        pages[num].mainButtonAdditionalAction
    }
    
    func showSkip(for num: Int) -> Bool {
        pages[num].showSkip
    }
    
    func showBack(for num: Int) -> Bool {
        pages[num].showBack
    }
    
    func additionalButtonTitle(for num: Int) -> String? {
        pages[num].additionalButtonTitle
    }
}
