//
//  ScreenPlayer.swift
//  AppSync_Receiver
//
//  Created by Evan Liu on 2026-06-30.
//

import SwiftUI
import Combine

class ScreenPlayer: ObservableObject, BasePlayer {
    @Published var flash = false
    
    func update(named fileName: String = "") {
        // unused
    }
    
    func play(from seconds: TimeInterval = 0) {
        flash = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.flash = false
        }
    }
    
    func stop() {
        flash = false
    }
    
    func clear() {
        flash = false
    }
}
