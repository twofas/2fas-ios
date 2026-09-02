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
import Common

struct IntroductionView: View {
    @Bindable
    var presenter: IntroductionPresenter

    @State
    private var position = ScrollPosition(idType: Int.self)
    
    @State
    private var showBackButton = false
    
    @State
    private var showSkipButton = false
    
    @State
    private var showPaging = false
    
    private let totalPages: Int = 4
    
    var body: some View {
        IntroductionNavigationbar(
            showBackButton: $showBackButton,
            showSkipButton: $showSkipButton,
            backAction: {
                prevPage()
            }, skipAction: {
                presenter.close()
            }
        )
        .frame(alignment: .top)

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(0..<totalPages, id: \.self) { index in
                    PageView(page: index)
                    .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                    .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollDisabled(true)
        .scrollPosition($position)
        .scrollTargetBehavior(.viewAligned)
        .scrollTransition(transition: { content, phase in
            content
                .blur(radius: phase.isIdentity ? 10 : 0)
        })
        .onScrollPhaseChange { _, newPhase in
            guard !newPhase.isScrolling else { return }
            withAnimation {
                switch position.viewID as? Int {
                case 0:
                    showBackButton = false
                    showSkipButton = false
                    showPaging = false
                case 1:
                    showBackButton = false
                    showSkipButton = true
                    showPaging = true
                case 2:
                    showBackButton = true
                    showSkipButton = true
                    showPaging = true
                case 3:
                    showBackButton = true
                    showSkipButton = false
                    showPaging = true
                default:
                    break
                }
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            position.scrollTo(id: 0)
        }

        AdaptiveReadableContainer(verticalMargin: .zero) {
            ScrollPagingView(
                showPaging: $showPaging,
                activePage: Binding(get: { abs((position.viewID as? Int ?? 0) - 1) }, set: { _ in }),
                dotsCount: totalPages - 1
            )
            .padding(.bottom, .XL)
            VStack(spacing: .XL) {
                TFButton(
                    (position.viewID as? Int ?? 0) == totalPages - 1 ? T.Introduction.title : T.Commons.continue,
                    variant: .borderedProminent,
                    size: .large,
                    applyGlass: true
                ) {
                    nextPage()
                }
                TFButton(
                    T.Introduction.tos,
                    variant: .borderlessNeutral,
                    size: .small,
                    applyGlass: false
                ) {
                    presenter.onTOS()
                }
                .isHidden((position.viewID as? Int ?? 0) != 0, remove: true)
                .animation(.easeInOut, value: position)
            }
        }
        .minimumBottomSpacing()
        .toolbarVisibility(.hidden, for: .navigationBar)
    }
    
    private func nextPage() {
        guard let id = position.viewID as? Int else { return }
        if id < totalPages - 1 {
            withAnimation {
                position.scrollTo(id: id + 1)
            }
        } else {
            presenter.close()
        }
    }
    
    private func prevPage() {
        guard let id = position.viewID as? Int else { return }
        if id > 1 {
            withAnimation {
                position.scrollTo(id: id - 1)
            }
        }
    }
}

private struct IntroductionPage0: View {
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    BorderShield(showDeleteIcon: false)
                }
                .frame(alignment: .top)
                Spacer()
            }
            VStack {
                Spacer()
                VStack(spacing: .L) {
                    Text(T.Introduction.call1)
                        .textStyle(.body, .emphasized)
                        .foregroundStyle(.labelsPrimary)
                    IntroWelcomeView(text: T.Introduction.call2)
                    Text(T.Introduction.page1Content)
                        .textStyle(.body)
                        .foregroundStyle(.labelsSecondary)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }
        }
    }
}

private struct IntroductionPage1: View {
    var body: some View {
        ZStack {
            VStack {
                VStack(spacing: .L) {
                    Text(T.Introduction.page2Title)
                        .textStyle(.largeTitle, .emphasized)
                        .foregroundStyle(.labelsPrimary)
                    Text(T.Introduction.page2Content)
                        .foregroundStyle(.labelsSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(alignment: .top)
                Spacer()
            }
            VStack {
                Spacer()
                    .containerRelativeFrame(.vertical) { size, _ in size * 0.5 }
                VStack {
                    Asset.introductionPage0.swiftUIImage
                        .frame(alignment: .top)
                    Spacer()
                }
            }
        }
    }
}

private struct IntroductionPage2: View {
    var body: some View {
        ZStack {
            VStack {
                VStack(spacing: .L) {
                    Text(T.Introduction.page3Title)
                        .textStyle(.largeTitle, .emphasized)
                        .foregroundStyle(.labelsPrimary)
                    Text(T.Introduction.page3Content)
                        .foregroundStyle(.labelsSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(alignment: .top)
                Spacer()
            }
            VStack {
                Spacer()
                    .containerRelativeFrame(.vertical) { size, _ in size * 0.5 }
                VStack {
                    Asset.introductionPage1.swiftUIImage
                        .frame(alignment: .top)
                    Spacer()
                }
            }
        }
    }
}

private struct IntroductionPage3: View {
    @State private var showInfo = false
    
    var body: some View {
        ZStack {
            VStack {
                VStack(spacing: .L) {
                    Text(T.Introduction.page4Title)
                        .textStyle(.largeTitle, .emphasized)
                        .foregroundStyle(.labelsPrimary)
                    Text(T.Introduction.page4ContentIos)
                        .foregroundStyle(.labelsSecondary)
                        .multilineTextAlignment(.center)
                    Button {
                        showInfo = true
                    } label: {
                        Text(T.Introduction.backupIcloudCta)
                            .foregroundStyle(.labelsPrimary)
                            .textStyle(.subheadline, .emphasized)
                            .padding(.horizontal, .ML)
                            .padding(.vertical, .S)
                            .background {
                                RoundedRectangle(.medium)
                                    .foregroundStyle(.fillsTertiary)
                            }
                    }
                    .padding(.top, .M)
                    .sheetContentPopover(isPresented: $showInfo) {
                        IntroductionInfoSheetContent()
                    }
                }
                .frame(alignment: .top)
                Spacer()
            }
            VStack {
                Spacer()
                    .containerRelativeFrame(.vertical) { size, _ in size * 0.5 }
                VStack {
                    Asset.introductionPage2.swiftUIImage
                        .frame(alignment: .top)
                    Spacer()
                }
            }
        }
    }
}

private struct PageView: View {
    let page: Int

    var body: some View {
        AdaptiveReadableContainer {
            switch page {
            case 0: IntroductionPage0()
            case 1: IntroductionPage1()
            case 2: IntroductionPage2()
            case 3: IntroductionPage3()
            default: EmptyView()
            }
        }
    }
}
