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
import SyncWatch
import ProtectionWatch
import CommonWatch

struct ContentView: View {
    @State var syncStstus = "Hello, world!"
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                Text(syncStstus)
        }
        .padding()
        .task {
            let protection = Protection()
            
            EncryptionHolder.initialize(with: protection.localKeyEncryption)
            SyncInstanceWatch.initialize()
            let handler = SyncInstanceWatch.getCloudHandler()
            handler.registerForStateChange({ state in
                syncStstus = "\(state)"
            }, with: "listener!")
            handler.enable()
            handler.synchronize()
        }
    }
}

#Preview {
    ContentView()
}
