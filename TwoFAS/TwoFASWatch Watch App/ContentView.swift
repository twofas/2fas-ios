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
//import SyncWatch
//import ProtectionWatch
//import CommonWatch
//import StorageWatch

struct ContentView: View {
    private let list: [Service] = [
//        .init(id: "32423432", name: "First", additionalInfo: nil),
//        .init(id: "4889812312", name: "Second", additionalInfo: "test@test.com"),
//        .init(id: "3242342", name: "First", additionalInfo: nil),
//        .init(id: "488912312", name: "Second", additionalInfo: "test@test.com"),
//        .init(id: "322342", name: "First", additionalInfo: nil),
//        .init(id: "48891212", name: "Second", additionalInfo: "test@test.com")
    ]
    
    @State private var selectedService: Service?
    @State private var isConfirming = false
    
    @State private var textTest: String = ""
    
    var body: some View {
        NavigationSplitView {
            List(list, selection: $selectedService) { item in
                Section(header: Text("Important tasks")) {
                    Button(action: {
                        selectedService = item
                    }, label: {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.callout)
                                .padding(4)
                                .foregroundStyle(.primary)
                            //                                .background(Material.ultraThin, in: RoundedRectangle(cornerRadius: 7))
                            if let additionalInfo = item.additionalInfo {
                                Text(additionalInfo)
                                    .padding(.horizontal, 4)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }.frame(minHeight: 70)
                    })
                }
            }
            .listStyle(.carousel)
            .navigationTitle("Services")
            .navigationBarTitleDisplayMode(.automatic)
            .containerBackground(.red.gradient, for: .navigation)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: {
                        isConfirming = true
                    }, label: {
                        Label("Settings", systemImage: "gear")
                    })
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        isConfirming = true
                    }, label: {
                        Label("Clear search results", systemImage: "search")
                    })
                }
//                ToolbarItemGroup(placement: .topBarTrailing) {
//                    NavigationLink {
//                        Color.blue
//                    } label: {
//                        Label("Settings", systemImage: "gear")
//                    }
//                }
            }
            .fullScreenCover(isPresented: $isConfirming) {
//            .confirmationDialog("Select value", isPresented: $isConfirming) {
//                Button(action: {}, label: {
//                    Text("Action 1")
//                })
//                Button(action: {}, label: {
//                    Text("Action 2")
//                })
//                Button(action: {}, label: {
//                    Text("Action 3")
//                })
                
                
                VStack {
                            TextFieldLink {
                                Image(systemName: "globe")
                                    .imageScale(.large)
                                    .foregroundColor(.accentColor)
                            } onSubmit: { value in
                                self.textTest = value
                            }
                        }
                        .padding()
//
//                TextField("Testowy", text: $textTest)
//                    .multilineTextAlignment(.center)
//                    .textInputAutocapitalization(.characters)
//                    .foregroundColor(.blue)
//                         .background(.yellow)
//                         .font(.largeTitle)
//                         .multilineTextAlignment(.center)
                
            }
        } detail: {
            if let selectedService {
                Text("Detail \(selectedService.name)")
            }
        }
    }
}

#Preview {
    ContentView()
}
