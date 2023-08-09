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
import Common

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
            VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
                AddingServiceTitleView(text: "Almost done!")
                AddingServiceTextContentView(text: "To finish pairing, you might need to retype this token in the service.")
                AddingServiceLargeSpacing()
                
                VStack(spacing: 6) {
                    HStack(spacing: 12) {
                        serviceIcon
                        VStack(spacing: 4) {
                            AddingServiceTitleView(text: serviceTitle, alignToLeading: true)
                            Text("Subtitle")
                                .font(.footnote)
                                .foregroundColor(Color(Theme.Colors.Text.subtitle))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    HStack(alignment: .center) {
                        Text("343 342")
                            .foregroundColor(Color(Theme.Colors.Text.main))
                            .font(Font(Theme.Fonts.Counter.syncCounter))
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ZStack(alignment: .center) {
                            Text("25")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Color(Theme.Colors.Text.main))
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(0.3)/CGFloat(1))
                                .stroke(Color(ThemeColor.primary),
                                        style: StrokeStyle(
                                            lineWidth: 1,
                                            lineCap: .round
                                        ))
                                .rotationEffect(.degrees(-90))
                                .padding(0.5)
                                .frame(width: 30, height: 30)
                            
                        }
                    }
                }
                .padding(.init(top: 16, leading: 20, bottom: 12, trailing: 20))
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Metrics.modalCornerRadius)
                        .stroke(Color(Theme.Colors.Line.separator), lineWidth: 1)
                )
            }.padding(.horizontal, Theme.Metrics.doubleMargin * 3.0 / 4.0)
            
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
