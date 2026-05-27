//
//  ContentView.swift
//  AppSync_Broadcaster
//
//  Created by Evan Liu on 2026-03-23.
//

import SwiftUI

struct ContentView: View {
    let BLE = BLEBroadcaster()
    
    var body: some View {
        VStack {
            Text("BLE Broadcasting")
                .padding()
            
            Button("Flash In 3 Seconds") {
                let timestamp = getTimeNow() + 3.0
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    print("flash")
                }
                let packet = Packet(
                    type: .scheduledEvent,
                    event: 1,
                    timestamp: timestamp
                )
                BLE.sendPacket(packet: packet)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ContentView()
}
