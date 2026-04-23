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

import SwiftUI
import CommonUI

private struct OnboardingPage: Identifiable {
    let id: Int
}


struct IntroductionView: View {
    @State
    private var position = ScrollPosition(idType: Int.self)
    
    private let pages = [
        OnboardingPage(id: 0),
        OnboardingPage(id: 1),
        OnboardingPage(id: 2)
    ]
    
    var body: some View {
        HStack {
            TFLiquidGlassSymbolButton(symbol: .back) {
                
            }
            Spacer()
            TFLiquidGlassTextButton("Skip") {
                
            }
        }
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
//                ForEach(pages) { page in
//                    CardView(page: page)
//                        .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
//                        .id(page.id)
//                }
                
            }
            .scrollTargetLayout()
        }
        .scrollPosition($position)
        .scrollTargetBehavior(.viewAligned)
        .onAppear {
            position.scrollTo(id: 0)
        }
    }
}

struct IntroductionPage0: View {
    var body: some View {
        
    }
}


private struct CardView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Tytuł")
                .font(.title)
                .fontWeight(.bold)
            Text("Subtytuł")
                .font(.body)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .cornerRadius(16)
    }
}
