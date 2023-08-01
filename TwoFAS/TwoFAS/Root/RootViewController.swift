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

final class RootViewController: ContainerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Colors.Fill.background
    }
    
    override var shouldAutorotate: Bool { UIDevice.isiPad }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        NotificationCenter.default.post(Notification(name: Notification.Name.orientationSizeWillChange))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let modal = ModalViewController()
//        modal.modalTransitionStyle = .coverVertical
//        modal.modalPresentationStyle = .overCurrentContext
//        modal.definesPresentationContext = true
//        present(modal, animated: true)
        
        let test = TestViewController()
        test.update = { value, vc in
            if let sheet = vc.sheetPresentationController {
                UIView.animate(withDuration: 0.3, animations: {
                    test.mainView?.alpha = 0
                }, completion: { val in
                    print(val)
                    sheet.animateChanges {
                        sheet.detents = [.custom(resolver: { context in
                            min(value, context.maximumDetentValue)
                        })]
                    }
                    UIView.animate(withDuration: 0.3, delay: 0, animations: {
                        test.mainView?.alpha = 1
                    })
                })
                
            }
        }
        if let sheet = test.sheetPresentationController {
            sheet.detents = [.custom(resolver: { context in
                400.0
            })]
//                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
//                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
            present(test, animated: true, completion: nil)
    }
}


final class TestViewController: UIViewController {
    var update: ((CGFloat, UIViewController) -> Void)?
    var mainView: UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let v = V(change: {
            self.update?($0, self)
        })
        let vc = UIHostingController(rootView: v)
        
        vc.willMove(toParent: self)
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.pinToParent()
        vc.didMove(toParent: self)
        mainView = vc.view
//        let b = UIButton()
//        b.setTitle("Change", for: .normal)
//        b.setTitleColor(.white, for: .normal)
//        b.backgroundColor = .white
//        b.addTarget(self, action: #selector(change), for: .touchUpInside)
//        view.addSubview(b, with: [
//            b.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            b.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
    }
    
//    @objc
//    func change() {
//        update?(self)
//    }
}

struct V: View {
    let change: (CGFloat) -> Void
  
    @State var currentHeight: CGFloat = 400
    @State var username: String = "Test"
    
    @State private var height = CGFloat.zero
    
    var body: some View {
            GeometryReader { geo in
                VStack(alignment: .center, spacing: 10) {
                    Button("Change") {
                        currentHeight = CGFloat((100...600).randomElement() ?? 300)
                    }
                    .frame(height: currentHeight)
                    TextField(
                        "User name (email address)",
                        text: $username
                    )
                    .foregroundColor(.white)
                    .background(
                        Rectangle()
                            .fill(.blue)
                    )
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
