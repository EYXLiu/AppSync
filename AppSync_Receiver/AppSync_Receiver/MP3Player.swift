//
//  VideoPlayer.swift
//  AppSync_Receiver
//
//  Created by Evan Liu on 2026-06-27.
//

import Foundation
import AVFoundation

class MP3Player: BasePlayer {
    
    private var currentAudioURL: URL?
    private var audioPlayer: AVAudioPlayer?
    
    func update(named fileName: String) {
        let fileManager = FileManager.default
        
        guard let documentsUrl = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            currentAudioURL = nil
            return
        }
        
        let fileURL = documentsUrl.appendingPathComponent("\(fileName).mp3")
        
        if fileManager.fileExists(atPath: fileURL.path) {
            currentAudioURL = fileURL
        } else {
            currentAudioURL = nil
            print("MP3 not found: \(fileName).mp3")
        }
    }
    
    func play(from seconds: TimeInterval = 0) {
        guard let url = currentAudioURL else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.currentTime = seconds
            audioPlayer?.play()
        } catch {
            print("failed to play audio: \(error)")
        }
    }
    
    func stop() {
        audioPlayer?.stop()
    }
    
    func clear() {
        currentAudioURL = nil
        audioPlayer = nil
    }
}
