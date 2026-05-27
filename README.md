# iOS BeatSync 
**Tech stack:** Swift, XCode, CoreBluetooth, AVFoundation, UIKit  
Built an iOS + macOS Bluetooth synchronization system using an NTP-inspired clock model (offset and RTT) to establish a virtual timebase for coordinated scheduling of visual flashes and audio playback across devices  

## Features
- Bluetooth LE communication using CoreBluetooth (advertising and GATT connections)
- NTP-style synchronization (RTT measurement, clock offset estimation, shared virtual clock)
- File Audio Playback usign AVFoundation
- Coordinated visual flashes
- File selection and local audio management using UIKit
- MacOS central controller + iOS peripherals
- Shared library for cross-platform logic between iOS and MacOS targets

## WIP
- `DispatchQueue.main.AsyncAfter` is not accurate for timing, will need to find a better way of playing audio and sound 
- XCode workspace/shared library limitations when multiple XCode instances attempt to access the same shared module simultaneously
