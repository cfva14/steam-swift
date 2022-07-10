//
//  SteamAppList+Helpers.swift
//  SteamworksHelpers
//
//  Licensed under MIT (https://github.com/johnfairh/swift-steamworks/blob/main/LICENSE
//

import Steamworks

extension SteamAppList {
    /// Steamworks `ISteamAppList::GetInstalledApps()`
    public func getInstalledApps() -> (rc: Int, appID: [AppID]) {
        getInstalledApps(maxAppIDs: getNumInstalledApps())
    }
}
