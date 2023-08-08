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
import SwiftUI

final class AddingServiceTokenViewController: UIViewController {
    var heightChange: ((CGFloat) -> Void)?
//    var presenter: AddingServiceTokenPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let token = AddingServiceToken(copyCode: { [weak self] in
            //self?.presenter.handleCopyToken()
        }, changeHeight: { [weak self] height in
            self?.heightChange?(height)
        })
        
        let vc = UIHostingController(rootView: token)
        vc.willMove(toParent: self)
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToParent()
        vc.view.backgroundColor = Theme.Colors.Fill.System.second
        vc.didMove(toParent: self)
        
//        presenter.viewDidLoad()
    }
}

private struct AddingServiceToken: View {
    @State private var errorReason: String?
    
    let serviceIcon: Image
    let serviceTitle: String
    let additionalInfo: String?
    let copyCode: Callback
    let changeHeight: (CGFloat) -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
            AddingServiceTitleView(text: "Almost done!")
            AddingServiceTextContentView(text: "To finish pairing, you might need to retype this token in the service.")
            AddingServiceLargeSpacing()

            Group {
                HStack {
                    serviceIcon
                    VStack {
                        AddingServiceTitleView(text: serviceTitle, alignToLeading: true)
                        
                    }
                }
                Text("Test")
            }
            .cornerRadius(Theme.Metrics.modalCornerRadius)
            .frame(maxWidth: .infinity)
            .border(.black)

            AddingServiceLargeSpacing()

            AddingServiceFullWidthButton(
                text: "Copy code",
                icon: Asset.keybordIcon.swiftUIImage
            ) {
                copyCode()
            }
        }
        .padding(.horizontal, Theme.Metrics.doubleMargin)
        .observeHeight(onChange: { height in
            changeHeight(height)
        })
    }
}
