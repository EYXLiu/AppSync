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
        ZStack {
            if receiver.screenPlayer.flash {
                Color.blue
            } else {
                Color.white
            }
        }
        VStack {
            Text("BLE Receiver Test")
                .font(.title)
            
            Text(receiver.message)
                .font(.headline)
                .padding()
            
            Text("Offset: \(receiver.clock.offset)")
            Text("RTT: \(receiver.clock.rtt)")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
