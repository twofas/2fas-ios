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

struct PINKeyboard: View {
    
    @State private var PIN: String = ""
    
    var body: some View {
        VStack {
            Text("Enter PIN")
        //Text("****")
            Spacer()
//            GeometryReader { proxy in
                Grid(alignment: .center, horizontalSpacing: 1, verticalSpacing: 1) {
                    GridRow {
                        button(1)
                        button(2)
                        button(3)
                    }
//                    .frame(height: floor((proxy.size.height - 3.0)/4.0))
                    
                    GridRow {
                        button(4)
                        button(5)
                        button(6)
                    }
//                    .frame(height: floor((proxy.size.height - 3.0)/4.0))
                    
                    GridRow {
                        button(7)
                        button(8)
                        button(9)
                    }
//                    .frame(height: floor((proxy.size.height - 3.0)/4.0))
                    
                    GridRow {
                        Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                        button(0)
                        Image(systemName: "delete.left")
                    }
//                    .frame(height: floor((proxy.size.height - 3.0)/4.0))
//                }
                    
                
                    
            }
                .background(.red)
        }
        .ignoresSafeArea(edges: [.horizontal, .bottom])
//        .toolbarTitleDisplayMode(.inline)
//        .navigationTitle("Enter PIN")
//        .toolbar {
//            ToolbarItemGroup(placement: .topBarLeading) {
//                Button(action: {
//                }, label: {
//                    Text("Cancel")
//                })
//            }
//        }
        .toolbar(content: {
                   ToolbarItem(placement: .cancellationAction){
                       Button {
                           print("go!")
                       } label: {
                           Label("Done", systemImage: "xmark")
                       }
                   }
               })
    }
    
    @ViewBuilder
    func button(_ value: Int) -> some View {
        Button(action: {}, label: {
            Text(String(value))
                .foregroundStyle(.black)
                .font(.caption)
                .monospacedDigit()
        })
        .buttonStyle(DigitPadStyle())
    }
}
//PINKeyboardLayout {
//    button(1)
//    button(2)
//    button(3)
//    button(4)
//    button(5)
//    button(6)
//    button(7)
//    button(8)
//    button(9)
//    button(0)
//}
//.frame(maxWidth: .infinity)

//struct FullScreenModalView: View {
//    @Environment(\.dismiss) var dismiss
//
//    var body: some View {
//        ZStack {
//            Color.primary.edgesIgnoringSafeArea(.all)
//            Button("Dismiss Modal") {
//                dismiss()
//            }
//        }
//    }
//}

public struct DigitPadStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        GeometryReader(content: { geometry in
            configuration.isPressed ?
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.gray.opacity(0.7))
                .frame(width: geometry.size.width, height: geometry.size.height)
                .scaleEffect(1.1)
                :
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.gray.opacity(0.5))
                .frame(width:  geometry.size.width, height:  geometry.size.height)
                .scaleEffect(1)
            
            configuration.label
                .background(
                    ZStack {
                        GeometryReader(content: { geometry in
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.clear)
                                .frame(
                                    width: configuration.isPressed ? geometry.size.width/0.75 : geometry.size.width,
                                    height: configuration.isPressed ? geometry.size.height/0.8 : geometry.size.height
                                )
                                
                        })
                        
                        
                    }
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                .scaleEffect(configuration.isPressed ? 1.2 : 1)
        })
            .onChange(of: configuration.isPressed, perform: { value in
                if configuration.isPressed{
                    DispatchQueue.main.async {
                        #if os(watchOS)
                        WKInterfaceDevice().play(.click)
                        #endif
                        
                    }
                }
            })
        
    }
}
