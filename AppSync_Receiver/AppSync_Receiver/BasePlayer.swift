//
//  BasePlayer.swift
//  AppSync_Receiver
//
//  Created by Evan Liu on 2026-06-27.
//

import Foundation

protocol BasePlayer {
    func update(named fileName: String)
    func play(from seconds: TimeInterval)
    func stop()
    func clear()
}
