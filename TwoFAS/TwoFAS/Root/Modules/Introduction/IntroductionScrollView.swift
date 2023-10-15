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

final class IntroductionScrollView: UIView {
    var didFinishAnimation: Callback?
    var didChangePage: ((Int) -> Void)?
    
    let container = IntroductionContainerView()
    
    private var previousPage: Int = -1
    private var currentPage: Int = 0
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.isPagingEnabled = true
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(scrollView, with: [
            scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: topAnchor),
            scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.frameLayoutGuide.heightAnchor.constraint(equalTo: heightAnchor)
        ])
        
        scrollView.addSubview(container, with: [
            container.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            container.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            container.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            container.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
            container.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                multiplier: CGFloat(IntroductionCommons.pageCount)
            )
        ])
        
        container.didFinishAnimation = { [weak self] in self?.didFinishAnimation?() }
        scrollView.delegate = self
    }
    
    func moveToPage(num: Int) {
        currentPage = num
        scrollView.scrollToPage(page: num, animated: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.layoutIfNeeded()
        scrollView.scrollToPage(page: currentPage, animated: false)
    }
}

extension IntroductionScrollView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let pageNum = Int(round(scrollView.contentOffset.x / pageWidth))
        guard pageNum != previousPage else { return }
        previousPage = pageNum
        didChangePage?(pageNum)
    }
}

private extension UIScrollView {
    func scrollToPage(page: Int, animated: Bool) {
        var frame: CGRect = self.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        self.scrollRectToVisible(frame, animated: animated)
    }
}
