//
//  FeatureFlagManager.swift
//  Nugget
//
//  Created by lemin on 9/9/24.
//

import Foundation

enum FeatureFlagCategory: String {
    case SpringBoard0 = "GenerativeModels0"
    case SpringBoard = "GenerativeModels"
    case SpringBoard1 = "SpringBoard"
    case Photos = "CoreAudioServices"
    case Photos1 = "CoreAudioServices0"
}

struct FeatureFlag: Identifiable {
    let id: Int
    var category: FeatureFlagCategory
    let flags: [String]
    var is_list: Bool = true
    var inverted: Bool = false
}

class FeatureFlagManager: ObservableObject {
    static let shared = FeatureFlagManager()
    
    @Published var EnabledFlags: [FeatureFlag] = []
    
    public func apply() throws -> Data {
        var plist: [String: Any] = [:]
        for EnabledFlag in self.EnabledFlags {
            var value = "FeatureComplete"
            var flagList: [String: Any] = [:]
            for flag in EnabledFlag.flags {
                if (EnabledFlag.category == "GenerativeModels") {
                if EnabledFlag.is_list {
                    flagList[flag] = ["DevelopmentPhase": value]
                } else {
                    flagList[flag] = value
                }}else
                if (EnabledFlag.category == "GenerativeModels0") {
                    EnabledFlag.category = SpringBoard
                    var value1 = true
                if EnabledFlag.is_list {
                    flagList[flag] = ["Enabled": value1]
                } else {
                    flagList[flag] = value
                }}else
                if (EnabledFlag.category == "CoreAudioServices") {
                if EnabledFlag.is_list {
                    flagList[flag] = ["DevelopmentPhase": value]
                } else {
                    flagList[flag] = value
                }}else
                if (EnabledFlag.category == "CoreAudioServices0") {
                    EnabledFlag.category = Photos
                    var value1 = true
                if EnabledFlag.is_list {
                    flagList[flag] = ["Enabled": value1]
                } else {
                    flagList[flag] = value
                }}else {
                    value = true
                   if EnabledFlag.is_list {
                    flagList[flag] = ["Enabled": value]
                } else {
                    flagList[flag] = value 
                }}
            }
            plist[EnabledFlag.category.rawValue] = flagList
        }
        // convert to data and return
        return try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
    }
    
    public func reset() throws -> Data {
        return Data()
    }
}
