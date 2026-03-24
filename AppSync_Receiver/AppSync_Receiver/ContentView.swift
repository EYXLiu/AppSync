//
//  ContentView.swift
//  AppSync_Receiver
//
//  Created by Evan Liu on 2026-03-23.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var receiver = BLEReceiver()

    var body: some View {
        VStack {
            Text("BLE Receiver Test")
                .font(.title)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
