//
//  GestaltView.swift
//  Nugget
//
//  Created by lemin on 9/9/24.
//

import SwiftUI

struct GestaltView: View {
    let gestaltManager = MobileGestaltManager.shared
    let userVersion = Version(string: UIDevice.current.systemVersion)
    
    struct GestaltTweak: Identifiable {
        var id = UUID()
        var label: String
        var keys: [String]
        var values: [Any] = [1]
        var active: Bool = false
        var minVersion: Version = Version(string: "1.0")
    }
    
    struct DeviceSubType: Identifiable {
        var id = UUID()
        var key: Int
        var title: String
        var minVersion: Version = Version(string: "16.0")
    }
    
    @State private var CurrentSubType: Int = -1
    @State private var CurrentSubTypeDisplay: String = "Default"
    
    @State private var deviceModelChanged: Bool = false
    @State private var deviceModelName: String = ""
    
    // list of device subtype options
    @State var deviceSubTypes: [DeviceSubType] = [
        .init(key: -1, title: NSLocalizedString("Default", comment: "default device subtype")),
        .init(key: 2436, title: NSLocalizedString("iPhone X Gestures", comment: "x gestures")),
        .init(key: 2556, title: NSLocalizedString("iPhone 14 Pro Dynamic Island", comment: "iPhone 14 Pro SubType")),
        .init(key: 2796, title: NSLocalizedString("iPhone 14 Pro Max Dynamic Island", comment: "iPhone 14 Pro Max SubType")),
        .init(key: 2976, title: NSLocalizedString("iPhone 15 Pro Max Dynamic Island", comment: "iPhone 15 Pro Max SubType"), minVersion: Version(string: "17.0")),
        .init(key: 2622, title: NSLocalizedString("iPhone 16 Pro Dynamic Island", comment: "iPhone 16 Pro SubType"), minVersion: Version(string: "18.0")),
        .init(key: 2868, title: NSLocalizedString("iPhone 16 Pro Max Dynamic Island", comment: "iPhone 16 Pro Max SubType"), minVersion: Version(string: "18.0"))
    ]
    
    // list of mobile gestalt tweaks
    @State var gestaltTweaks: [GestaltTweak] = [
        .init(label: "Enable Boot Chime", keys: ["QHxt+hGLaBPbQJbXiUJX3w"]),
        .init(label: "Enable Charge Limit", keys: ["37NVydb//GP/GrhuTN+exg"]),
        .init(label: "Enable Collision SOS", keys: ["HCzWusHQwZDea6nNhaKndw"]),
        .init(label: "Enable Tap to Wake (iPhone SE)", keys: ["yZf3GTRMGTuwSV/lD7Cagw"]),
        .init(label: "Enable iOS 16 Camera Button Settings", keys: ["CwvKxM2cEogD3p+HYgaW0Q", "oOV1jhJbdV3AddkcCg0AEA"], values: [1, 1], minVersion: Version(string: "18.0")),
        .init(label: "Disable Wallpaper Parallax", keys: ["UIParallaxCapability"], values: [0]),
        .init(label: "Enable Stage Manager Supported (WARNING: risky on some devices, mainly phones)", keys: ["qeaj75wk3HF4DwQ8qbIi7g"], values: [1]),
        .init(label: "Allow iPad Apps on iPhone", keys: ["9MZ5AdH43csAUajl/dU+IQ"], values: [[1, 2]]),
        .init(label: "Disable Region Restrictions (ie. Shutter Sound)", keys: ["h63QSdBCiT/z0WU6rdQv6Q", "zHeENZu+wbg7PUprwNwBWg"], values: ["US", "LL/A"]),
        .init(label: "Enable Apple Pencil", keys: ["yhHcB0iH0d1XzPO/CFd3ow"]),
        .init(label: "Toggle Action Button", keys: ["cT44WE1EohiwRzhsZ8xEsw"]),
        .init(label: "Toggle Internal Storage (WARNING: risky for some devices, mainly iPads)", keys: ["LBJfwOEzExRxzlAnSuI7eg"]),
        .init(label: "Set as Apple Internal Install (ie Metal HUD in any app)", keys: ["EqrsVvjcYDdxHBiQmGhAWw"]),
        .init(label: "Always On Display", keys: ["2OOJf1VhaM7NxfRok3HbWQ", "j8/Omm6s1lsmTDFsXjsBfA"], values: [1, 1], minVersion: Version(string: "18.0"))
    ]
    
    var body: some View {
        List {
            Section {
                // device subtype
                HStack {
                    Image(systemName: "ipodtouch")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                    
                    
                    Text("Gestures / Dynamic Island")
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    Button(CurrentSubTypeDisplay, action: {
                        showSubTypeChangerPopup()
                    })
                    .foregroundColor(.blue)
                    .padding(.leading, 10)
                }
                
                // device model name
                VStack {
                    Toggle("Change Device Model Name", isOn: $deviceModelChanged).onChange(of: deviceModelChanged, perform: { nv in
                        if nv {
                            if deviceModelName != "" {
                                gestaltManager.setGestaltValue(key: "ArtworkDeviceProductDescription", value: deviceModelName)
                            }
                        } else {
                            gestaltManager.removeGestaltValue(key: "ArtworkDeviceProductDescription")
                        }
                    })
                    TextField("Device Model Name", text: $deviceModelName).onChange(of: deviceModelName, perform: { nv in
                        if deviceModelChanged {
                            gestaltManager.setGestaltValue(key: "ArtworkDeviceProductDescription", value: deviceModelName)
                        }
                    })
                }
            }
            Section {
                // tweaks from list
                ForEach($gestaltTweaks) { tweak in
                    Toggle(tweak.label.wrappedValue, isOn: tweak.active).onChange(of: tweak.active.wrappedValue, perform: { nv in
                        if nv {
                            gestaltManager.setGestaltValues(keys: tweak.keys.wrappedValue, values: tweak.values.wrappedValue)
                        } else {
                            gestaltManager.removeGestaltValues(keys: tweak.keys.wrappedValue)
                        }
                    })
                }
            }
        }
        .navigationTitle("Mobile Gestalt")
        .navigationViewStyle(.stack)
        .onAppear {
            do {
                try gestaltManager.loadMobileGestaltFile()
            } catch {
                print(error.localizedDescription)
            }
            // get the base device subtype
            do {
                let subtype = try gestaltManager.getDefaultDeviceSubtype()
                for (i, deviceSubType) in deviceSubTypes.enumerated() {
                    if deviceSubType.key == -1 {
                        deviceSubTypes[i].key = subtype
                        break
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            // load enabled gestalt tweaks
            let enabledTweaks = gestaltManager.getEnabledTweaks()
            // first, the dynamic island
            if let subtype = enabledTweaks["ArtworkDeviceSubType"] as? Int {
                CurrentSubType = subtype
                for deviceSubType in deviceSubTypes {
                    if deviceSubType.key == subtype {
                        CurrentSubTypeDisplay = deviceSubType.title
                        break
                    }
                }
            }
            // next, the device model name
            if let modelName = enabledTweaks["ArtworkDeviceProductDescription"] as? String {
                deviceModelName = modelName
                deviceModelChanged = true
            }
            // finally, do the other values
            for (i, gestaltTweak) in gestaltTweaks.enumerated() {
                if gestaltTweak.keys.count > 0 && enabledTweaks[gestaltTweak.keys[0]] != nil {
                    gestaltTweaks[i].active = true
                }
            }
        }
    }
    
    func showSubTypeChangerPopup() {
        // create and configure alert controller
        let alert = UIAlertController(title: NSLocalizedString("Choose a device subtype", comment: ""), message: "", preferredStyle: .actionSheet)
        
        // create the actions
        
        for type in deviceSubTypes {
            if userVersion >= type.minVersion {
                let newAction = UIAlertAction(title: type.title + " (" + String(type.key) + ")", style: .default) { (action) in
                    // apply the type
                    gestaltManager.setGestaltValue(key: "ArtworkDeviceSubType", value: type.key)
                    CurrentSubType = type.key
                    CurrentSubTypeDisplay = type.title
                }
                if CurrentSubType == type.key {
                    // add a check mark
                    newAction.setValue(true, forKey: "checked")
                }
                alert.addAction(newAction)
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
            // cancels the action
        }
        
        // add the actions
        alert.addAction(cancelAction)
        
        let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
        // present popover for iPads
        alert.popoverPresentationController?.sourceView = view // prevents crashing on iPads
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
        
        // present the alert
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
}
