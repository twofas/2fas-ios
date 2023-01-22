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

final class ColorPickerViewController: UIViewController {
    var presenter: ColorPickerPresenter!
    
    private let editor = ColorGridSelector()
    private let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editor.setActiveColor(presenter.currentColor, animated: false)
        editor.userAction = { [weak self] color in
            self?.presenter.handleColorSelection(color)
        }
        
        view.backgroundColor = Theme.Colors.Fill.System.third
        scrollView.backgroundColor = Theme.Colors.Fill.System.third
        
        view.addSubview(scrollView)
        scrollView.pinToParent()
        
        scrollView.addSubview(editor, with: [
            editor.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            editor.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            editor.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            editor.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            editor.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let contentSize = editor.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        preferredContentSize = contentSize
        sheetPresentationController?.presentedViewController.preferredContentSize = contentSize
    }
}
