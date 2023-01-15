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

final class MainContainerDecoratedVerticalContainer: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        return stackView
    }()
    private var leading: NSLayoutConstraint!
    private var trailing: NSLayoutConstraint!
    private var top: NSLayoutConstraint!
    private var bottom: NSLayoutConstraint!
    
    var spacing: CGFloat = 0 {
        didSet {
            stackView.spacing = spacing
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        leading = stackView.leadingAnchor.constraint(equalTo: leadingAnchor)
        trailing = stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        top = stackView.topAnchor.constraint(equalTo: topAnchor)
        bottom = stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([
            top, bottom, leading, trailing
        ])
        
        spacing = 0
    }
    
    func addArrangedSubviews(_ views: [UIView]) {
        stackView.addArrangedSubviews(views)
    }
    
    func setContentEdge(edge: CGFloat) {
        leading.constant = edge
        trailing.constant = -edge
        top.constant = edge
        bottom.constant = -edge
    }
    
    func setBackgroundColor(_ color: UIColor ) {
        applyRoundedCorners(withBackgroundColor: color)
    }
}
