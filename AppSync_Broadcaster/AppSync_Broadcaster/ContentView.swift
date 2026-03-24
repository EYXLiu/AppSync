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
        Text("BLE Broadcasting")
            .padding()
    }
}

#Preview {
    ContentView()
}
