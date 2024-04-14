//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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
import CommonWatch

struct PINKeyboardView: View {
    @State private var shake: CGFloat = 0
    
    @ObservedObject
    var presenter: PINKeyboardPresenter
        
    var body: some View {
        VStack {
            Text(presenter.pin)
                .modifier(Shake(shake: shake))
            Spacer()
            Grid(alignment: .center, horizontalSpacing: 1, verticalSpacing: 1) {
                GridRow {
                    button(1)
                        .disabled(presenter.isNumKeyboardLocked)
                    button(2)
                        .disabled(presenter.isNumKeyboardLocked)
                    button(3)
                        .disabled(presenter.isNumKeyboardLocked)
                }
                
                GridRow {
                    button(4)
                        .disabled(presenter.isNumKeyboardLocked)
                    button(5)
                        .disabled(presenter.isNumKeyboardLocked)
                    button(6)
                        .disabled(presenter.isNumKeyboardLocked)
                }
                
                GridRow {
                    button(7)
                        .disabled(presenter.isNumKeyboardLocked)
                    button(8)
                        .disabled(presenter.isNumKeyboardLocked)
                    button(9)
                        .disabled(presenter.isNumKeyboardLocked)
                }
                
                GridRow {
                    Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                    button(0)
                        .disabled(presenter.isNumKeyboardLocked)
                    if presenter.isDeleteVisible {
                        deleteButton()
                    } else {
                        deleteButton()
                            .hidden()
                    }
                }
            }
        }
        .onChange(of: presenter.animateFailure, { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 1)) {
                    shake = 3
                } completion: {
                    shake = 0
                    presenter.onShakeAnimationEnded()
                }
                
                DispatchQueue.main.async {
                    WKInterfaceDevice().play(.failure)
                }
            }
        })
        .ignoresSafeArea(edges: [.horizontal, .bottom])
        .toolbar(content: {
            if presenter.showCloseButton {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        presenter.onCloseAction()
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                }
            }
        })
        .toolbarTitleDisplayMode(.inline)
        .navigationTitle(presenter.navigationTitle)
        .onAppear {
            presenter.onAppear()
        }
    }
    
    @ViewBuilder
    private func button(_ value: Int) -> some View {
        Button(action: {}, label: {
            Text(String(value))
                .foregroundStyle(.black)
                .font(.caption)
                .monospacedDigit()
        })
        .buttonStyle(KeyboardButton(
            press: { presenter.numButtonPressed(value) },
            release: { presenter.onNumButtonRelease(value) })
        )
    }
    
    @ViewBuilder
    private func deleteButton() -> some View {
        Button(action: {
            presenter.onDeleteAction()
        }, label: {
            Image(systemName: "delete.left")
                .foregroundStyle(.black)
        })
        .buttonStyle(KeyboardButton())
    }
}

public struct KeyboardButton: ButtonStyle {
    let press: (() -> Void)?
    let release: (() -> Void)?
    
    init(press: (() -> Void)? = nil, release: (() -> Void)? = nil) {
        self.press = press
        self.release = release
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        GeometryReader(content: { geometry in
            if configuration.isPressed {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.gray.opacity(0.7))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .scaleEffect(1.1)
            } else {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .scaleEffect(1)
            }
            
            configuration.label
                .background(
                    ZStack {
                        GeometryReader(content: { geometry in
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.clear)
                                .frame(
                                    width: configuration.isPressed ? geometry.size.width / 0.75 : geometry.size.width,
                                    height: configuration.isPressed ? geometry.size.height / 0.8 : geometry.size.height
                                )
                        })
                    }
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                .scaleEffect(configuration.isPressed ? 1.2 : 1)
        })
        .onChange(of: configuration.isPressed) { old, new in
            if new {
                press?()
                DispatchQueue.main.async {
                    WKInterfaceDevice().play(.click)
                }
            } else if old && !new {
                release?()
            }
        }
    }
}

struct Shake: AnimatableModifier {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var shake: CGFloat = 0
    
    var animatableData: CGFloat {
            get { shake }
            set { shake = newValue }
        }

    func body(content: Content) -> some View {
        content.projectionEffect(
            ProjectionTransform(
                CGAffineTransform(translationX: amount * sin(shake * .pi * CGFloat(shakesPerUnit)), y: 0)
            )
        )
    }
}
