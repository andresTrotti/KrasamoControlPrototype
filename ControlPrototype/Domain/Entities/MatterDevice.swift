//
//  MatterDeviceID.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//

import Foundation

struct MatterDeviceID: Hashable {
    let rawValue: UInt64
}

struct MatterDevice: Identifiable {
    var id: MatterDeviceID { deviceID }

    let deviceID: MatterDeviceID
    let name: String
    let isOnline: Bool
}



