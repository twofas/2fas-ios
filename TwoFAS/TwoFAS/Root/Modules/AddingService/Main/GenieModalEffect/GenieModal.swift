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

public extension View {
    func genieModal<ModalContent: View>(
        isPresented: Binding<Bool>,
        cornerRadius: CGFloat = TFCornerRadius.extraLarge.rawValue,
        usesMaterialBackground: Bool = false,
        @ViewBuilder content: @escaping () -> ModalContent
    ) -> some View {
        modifier(
            GenieModalModifier(
                isPresented: isPresented,
                cornerRadius: cornerRadius,
                usesMaterialBackground: usesMaterialBackground,
                modalContent: content
            )
        )
    }
}

private struct GenieModalModifier<ModalContent: View>: ViewModifier {
    @Binding
    var isPresented: Bool

    let cornerRadius: CGFloat
    let usesMaterialBackground: Bool
    let modalContent: () -> ModalContent

    @State
    private var isMounted = false
    @State
    private var progress: CGFloat = 0
    @State
    private var modalSize: CGSize = .zero

    private let animation: Animation = .spring(response: 0.58, dampingFraction: 0.82, blendDuration: 0.08)

    func body(content base: Content) -> some View {
        base
            .overlay {
                if isMounted {
                    GeometryReader { proxy in
                        let visualProgress = clampedProgress
                        let source = modalSourcePoint(in: proxy)
                        let finalCenter = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
                        let measuredWidth = max(1, modalSize.width)
                        let measuredHeight = max(1, modalSize.height)
                        let finalTopAnchor = CGPoint(
                            x: finalCenter.x,
                            y: finalCenter.y - measuredHeight / 2
                        )
                        let currentTopAnchor = CGPoint(
                            x: source.x + (finalTopAnchor.x - source.x) * visualProgress,
                            y: source.y + (finalTopAnchor.y - source.y) * visualProgress
                        )
                        let currentCenter = CGPoint(
                            x: currentTopAnchor.x,
                            y: currentTopAnchor.y + measuredHeight / 2
                        )
                        let scale = 0.035 + visualProgress * 0.965

                        ZStack {
                            Color.black
                                .opacity(0.4 * visualProgress)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    isPresented = false
                                }

                            // Shadow — pojawia się dopiero gdy modal jest osiadły.
                            shadowLayer(width: measuredWidth, height: measuredHeight)
                                .opacity(visualProgress > 0.985 ? 1.0 : 0.0)
                                .allowsHitTesting(false)
                                .shadow(
                                    color: .black.opacity(0.22 * visualProgress),
                                    radius: 30 * visualProgress,
                                    x: 0,
                                    y: 20 * visualProgress
                                )
                                .scaleEffect(x: scale, y: scale, anchor: .top)
                                .position(currentCenter)

                            // Genie shape — pusty rounded rectangle z fillem na którym
                            // jedzie shader. Brak tu zawartości, więc shader pinch'uje
                            // czysty kolor, bez postrzępionych fragmentów modal contentu.
                            // Znika dokładnie wtedy gdy shader się wyłącza (próg 0.985).
                            shadowLayer(width: measuredWidth, height: measuredHeight)
                                .opacity(visualProgress > 0.985 ? 0.0 : 1.0)
                                .allowsHitTesting(false)
                                .genieMetalWindow(progress: shaderProgress(for: visualProgress))
                                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                                .scaleEffect(x: scale, y: scale, anchor: .top)
                                .position(currentCenter)

                            // Faktyczna zawartość modala (AddingServiceView) —
                            // wjeżdża alphą w ostatnich 5% animacji, dokładnie tam
                            // gdzie genie shape kończy swoje istnienie. Brak shadera
                            // bo nie ma już co pinch'ować w tym momencie.
                            modalWindow(/*width: modalWidth*/)
                                .opacity(contentOpacity(for: visualProgress))
                                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                                .readSize { size in
                                    modalSize = size
                                }
                                .scaleEffect(x: scale, y: scale, anchor: .top)
                                .position(currentCenter)
                                .accessibilityAddTraits(.isModal)
                        }
                    }
                    .ignoresSafeArea()
                    .transition(.identity)
                }
            }
            .onAppear {
                syncPresentationState(isPresented)
            }
            .onChange(of: isPresented) { _, newValue in
                syncPresentationState(newValue)
            }
    }

    private func syncPresentationState(_ presented: Bool) {
        if presented {
            isMounted = true
            progress = 0

            DispatchQueue.main.async {
                withAnimation(animation) {
                    progress = 1
                }
            }
        } else {
            withAnimation(animation) {
                progress = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.62) {
                if !isPresented {
                    isMounted = false
                }
            }
        }
    }

    private func modalSourcePoint(in proxy: GeometryProxy) -> CGPoint {
        let x = proxy.size.width / 2

        let hasLikelyDynamicIsland = proxy.safeAreaInsets.top >= 51
        let y = hasLikelyDynamicIsland ? proxy.safeAreaInsets.top + 4 : 0

        return CGPoint(x: x, y: y)
    }

    private var clampedProgress: CGFloat {
        min(max(progress, 0), 1)
    }

    private func shaderProgress(for progress: CGFloat) -> CGFloat {
        if progress > 0.985 {
            return 1
        }

        return progress
    }

    /// Content (modalContent) jest niewidoczne przez większość animacji
    /// i wjeżdża po ostatnich 5% (0.95 → 1.0). Wcześniej shader pinch'uje
    /// tylko jednolite tło z modalWindow, więc nie widać postrzępionych
    /// fragmentów AddingServiceView w soczewce genie.
    private func contentOpacity(for progress: CGFloat) -> CGFloat {
        max(0, min(1, (progress - 0.95) * 20))
    }

    private func modalWindow() -> some View {
        modalContent()
//            .background {
//                if usesMaterialBackground {
//                    Rectangle().fill(.regularMaterial)
//                } else {
//                    Rectangle().fill(Color(uiColor: .secondarySystemBackground))
//                }
//            }
    }

    @ViewBuilder
    private func shadowLayer(width: CGFloat, height: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        if usesMaterialBackground {
            shape.fill(.regularMaterial).frame(width: width, height: height)
        } else {
            shape.fill(Color(uiColor: .secondarySystemBackground)).frame(width: width, height: height)
        }
    }
}

private extension View {
    @ViewBuilder
    func genieMetalWindow(progress: CGFloat) -> some View {
        if progress < 1.0 {
            self.visualEffect { content, proxy in
                content.layerEffect(
                    ShaderLibrary.genieWindow(
                        .float2(proxy.size),
                        .float(progress)
                    ),
                    maxSampleOffset: .zero
                )
            }
        } else {
            self
        }
    }

    func readSize(_ onChange: @escaping (CGSize) -> Void) -> some View {
        background {
            GeometryReader { proxy in
                Color.clear.preference(key: GenieModalSizePreferenceKey.self, value: proxy.size)
            }
        }
        .onPreferenceChange(GenieModalSizePreferenceKey.self, perform: onChange)
    }
}

private struct GenieModalSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
