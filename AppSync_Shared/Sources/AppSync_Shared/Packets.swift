//
//  Packets.swift
//  
//
//  Created by Evan Liu on 2026-05-23.
//

public struct SyncPacket: Codable {
    public let sequence: UInt32
    public let timestamp: Double

    public init(sequence: UInt32, timestamp: Double) {
        self.sequence = sequence
        self.timestamp = timestamp
    }
}