//
//  AppSync_Shared.swift
//  AppSync_Receiver
//
//  Created by Evan Liu on 2026-05-25.
//
// I WILL ADDRESS THIS IN THE FUTURE BUT THIS MIGHT BE AN XCODE LIMITATION THAT I CAN'T USE A CUSTOM LIBRARY IN TWO XCODE INSTANCES

//
// UUIDs.swift
//

// legacy module, relax concurrency checks
@preconcurrency import CoreBluetooth

// immutable, safe to share accross threads in practice
public enum BLEUUIDs {
    public static let service = CBUUID(string: "12345678-1234-1234-1234-123456789ABC")
    public  static let syncCharacteristic = CBUUID(string: "87654321-4321-4321-4321-CBA987654321")
}

//
// Packets.swift
//

public enum PacketType: UInt8, Codable {
    case syncRequest = 1 // requires sequence, t1
    case syncResponse = 2 // requires sequence, t1, t2, t3
    case scheduledEvent = 3 // requires event, timestamp
}

public struct Packet: Codable {
    public let type: PacketType

    public let sequence: UInt8?

    public let t1: Double?
    public let t2: Double?
    public let t3: Double?

    public let event: UInt8?
    public let timestamp: Double?
    
    public let fileName: String?
    public let offset: Double?
    
    public init(type: PacketType, sequence: UInt8? = nil, t1: Double? = nil, t2: Double? = nil, t3: Double? = nil, event: UInt8? = nil, timestamp: Double? = nil, filename: String? = nil, offset: Double? = nil) {
        self.type = type
        self.sequence = sequence
        self.t1 = t1
        self.t2 = t2
        self.t3 = t3
        self.event = event
        self.timestamp = timestamp
        self.fileName = filename
        self.offset = offset
    }
}

//
// Globals.swift
//

func getTimeNow() -> Double {
    ProcessInfo.processInfo.systemUptime
}
