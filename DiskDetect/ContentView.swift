//
//  ContentView.swift
//  DiskDetect
//
//  Created by Allister Harvey on 6/13/23.
//

import SwiftUI
import Foundation

struct Device: Identifiable {
  let id: Int
  var name: String
  var type: String
  var size: Int64
  var mountPoint: String
  var free: Int64
  var usage: Double {
    Double(self.free) / Double(self.size)
  }
}

struct ContentView: View {
  private var byteCountFormatter = ByteCountFormatter()
  
  @State private var devices = getExternalDevices()
  
  var body: some View {
    Table(devices) {
      TableColumn("Name", value: \.name)
      TableColumn("Type", value: \.type)
      TableColumn("Size") { device in
        Text(byteCountFormatter.string(fromByteCount: device.size))
      }
      TableColumn("Mount Point", value: \.mountPoint)
      TableColumn("Free") { device in
        Text(byteCountFormatter.string(fromByteCount: device.free))
      }
      TableColumn("Full %") { device in
        let percentage = device.usage * 100
        Text("\(String(format:"%.0f", percentage))%")
      }
      TableColumn("Usage") { device in
        ProgressView(value: device.usage)
      }
      
    }
  }
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}


func getExternalDevices() -> [Device] {
    var devices: [Device] = []
    
    let fileManager = FileManager.default
    let mountedVolumes = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: nil) ?? []
      
    for volumeURL in mountedVolumes {
        do {
          let resourceValues = try volumeURL.resourceValues(forKeys: [.volumeNameKey, .volumeIsRemovableKey, .volumeTotalCapacityKey, .volumeAvailableCapacityKey, .volumeMountFromLocationKey])
            
            guard let name = resourceValues.volumeName,
                  let isRemovable = resourceValues.volumeIsRemovable,
                  let totalSize = resourceValues.volumeTotalCapacity,
                  let availableSize = resourceValues.volumeAvailableCapacity,
                  let mountPoint = resourceValues.volumeMountFromLocation
            else {
                continue
            }
                      
            let deviceType = isRemovable ? "USB" : "Internal"
            let device = Device(
                id: devices.count,
                name: name,
                type: deviceType,
                size: Int64(totalSize),
                mountPoint: mountPoint,
                free: Int64(availableSize)
            )
            
            devices.append(device)
        } catch {
            print("Error retrieving resource values for \(volumeURL.path): \(error)")
        }
    }
    
    return devices
}
