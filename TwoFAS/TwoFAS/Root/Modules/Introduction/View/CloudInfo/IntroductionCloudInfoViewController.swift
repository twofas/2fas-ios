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

final class IntroductionCloudInfoViewController: UIViewController {
    var close: Callback?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = UIHostingController(rootView: IntroductionCloudInfoView(close: close))
        vc.willMove(toParent: self)
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToParent()
        vc.view.backgroundColor = Theme.Colors.Fill.System.third
        vc.didMove(toParent: self)
    }
}

private struct IntroductionCloudInfoView: View {
    let close: Callback?
    
    private let spacing: CGFloat = Theme.Metrics.doubleSpacing
    private let image = Asset.cloudBackup.image
    
    var body: some View {
        VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
            VStack(spacing: spacing) {
                Spacer()
                Image(uiImage: image)
                    .frame(width: image.size.width, height: image.size.height)
            }
            .frame(maxHeight: .infinity, alignment: .center)
            
            VStack(spacing: spacing) {
                Text(T.Introduction.backupIcloudTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top, Theme.Metrics.standardMargin)
                
                if let desc = try? AttributedString(
                    markdown: T.Introduction.backupIcloudDescription,
                    options: AttributedString.MarkdownParsingOptions(
                        interpretedSyntax: .inlineOnlyPreservingWhitespace
                    )
                ) {
                    Text(desc)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .frame(alignment: .top)
                }
            }
            .frame(alignment: .center)
            .layoutPriority(1)
            
            VStack(spacing: 0) {
                Button {
                    close?()
                } label: {
                    Text(T.Commons.ok)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                .buttonStyle(RoundedFilledButtonStyle())
                .padding(EdgeInsets(top: 0, leading: 0, bottom: spacing, trailing: 0))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .frame(maxWidth: Theme.Metrics.componentWidth)
        .navigationBarHidden(true)
    }
}
