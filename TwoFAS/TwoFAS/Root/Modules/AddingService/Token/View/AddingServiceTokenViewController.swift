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
//    var presenter: AddingServicePresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tmp = V2 { [weak self] height in
            self?.heightChange?(height)
        }
        
        let vc = UIHostingController(rootView: tmp)
        vc.willMove(toParent: self)
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToParent()
        vc.view.backgroundColor = Theme.Colors.Fill.System.second
        vc.didMove(toParent: self)
        
//        presenter.viewDidLoad()
    }
}

struct V2: View {
    let change: (CGFloat) -> Void
  
    @State private var height = CGFloat.zero
    
    var body: some View {
            GeometryReader { geo in
                VStack(alignment: .center, spacing: 10) {
                    Text("Test")
                    Text("Test")
                    Text("Test")
                    Text("Test")
                    Text("Test")
                    Text("Test")
                    Text("Test")
                    
                }
                .background(GeometryReader {
                                    // store half of current width (which is screen-wide)
                                    // in preference
                                    Color.clear
                                        .preference(key: ViewHeightKey.self,
                                            value: $0.frame(in: .local).size.height)
                                })
                                .onPreferenceChange(ViewHeightKey.self) {
                                    // read value from preference in state
                                    self.height = $0
                                    change(height)
                                }
//                .onChange(of: geo.size.height) { newValue in
//                    print(">>> \(newValue)")
//                    change(newValue)
//                }
            }
    }
}

struct ViewHeightKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
