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

import SwiftUI
import Common
import CommonUIKit
import UIKit
import Data

struct GuidePagesView: View {
    @ObservedObject var presenter: GuidePagesPresenter
    
    @State private var panelWidth: CGFloat = 0
    
    var body: some View {
        VStack {
            Spacer()
            
            PagingViewController(pages: presenter.pages.map { $0.toPage() }, currentPage: $presenter.currentPage)

            Spacer()
            
            VStack(spacing: Theme.Metrics.doubleMargin) {
                PageIndicator(totalPages: presenter.totalPages, pageNumber: $presenter.currentPage)
                Button {
                    presenter.handleAction()
                } label: {
                    if let buttonIcon = presenter.buttonIcon {
                        HStack {
                            Image(uiImage: buttonIcon)
                                .tint(.white)
                                .accessibilityHidden(true)
                            Text(verbatim: presenter.buttonTitle)
                        }
                    } else {
                        Text(verbatim: presenter.buttonTitle)
                    }
                }
                .buttonStyle(RoundedFilledConstantWidthButtonStyle())
            }
            .padding(.bottom, 2 * Theme.Metrics.doubleMargin)
            .frame(maxWidth: .infinity, alignment: .bottom)
        }
    }
}

private struct Page: View {
    let icon: UIImage
    let description: AttributedString
    var body: some View {
        VStack(alignment: .center, spacing: 3 * Theme.Metrics.doubleMargin) {
            Image(uiImage: icon)
                .accessibilityHidden(true)
            Text(attrString(with: description))
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(Theme.Colors.Text.main))
                .frame(maxWidth: Theme.Metrics.componentWidth)
                .padding(2 * Theme.Metrics.doubleMargin)
        }
        .background(Color(Theme.Colors.Fill.System.third))
    }
    
    private func attrString(with attrString: AttributedString) -> AttributedString {
        var str = attrString
        str.foregroundColor = Theme.Colors.Text.main
        return str
    }
}

private extension GuideDescription.Page {
    func toPage() -> Page {
        Page(icon: image.icon, description: content)
    }
}

private struct PageIndicator: View {
    private let dotSize: CGFloat = 6
    
    // Settings
    let totalPages: Int
    @Binding var pageNumber: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: Theme.Metrics.halfSpacing) {
            ForEach(0 ..< totalPages, id: \.self) {
                Circle()
                    .accessibilityLabel(T.Commons.pageOfPageTitle($0 + 1, totalPages))
                    .accessibilityAddTraits(pageNumber == $0 ? .isSelected : .isStaticText)
                    .foregroundColor(
                        pageNumber == $0 ? Color(Theme.Colors.Fill.theme) : Color(Theme.Colors.Controls.pageIndicator)
                    )
                    .frame(width: dotSize, height: dotSize)
            }
        }
    }
}

private struct PagingViewController: UIViewControllerRepresentable {
    var pages: [Page]
    @Binding var currentPage: Int

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal)
        pageController.dataSource = context.coordinator
        pageController.delegate = context.coordinator
        pageController.view.backgroundColor = Theme.Colors.Fill.System.third
        pageController.edgesForExtendedLayout = []

        return pageController
    }

    func updateUIViewController(_ pageController: UIPageViewController, context: Context) {
        pageController.setViewControllers(
            [context.coordinator.controllers[currentPage]],
            direction: .forward,
            animated: true
        )
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PagingViewController
        var controllers = [UIViewController]()

        init(_ pageController: PagingViewController) {
            parent = pageController
            controllers = parent.pages.map {
                let vc = UIHostingController(rootView: $0)
                vc.view.backgroundColor = Theme.Colors.Fill.System.third
                return vc
            }
        }

        func pageViewController(
            _ pageController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            
            if index == 0 {
                return nil
            }
            
            return controllers[index - 1]
        }

        func pageViewController(
            _ pageController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            
            if index + 1 == controllers.count {
                return nil
            }
            
            return controllers[index + 1]
        }

        func pageViewController(
            _ pageController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            if let visibleViewController = pageController.viewControllers?.first,
               let index = controllers.firstIndex(of: visibleViewController) {
                parent.currentPage = index
            }
        }
    }
}
