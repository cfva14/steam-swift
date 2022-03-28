//
//  SteamRemotePlay.swift
//  Steamworks
//
//  Licensed under MIT (https://github.com/johnfairh/swift-steamworks/blob/main/LICENSE
//
//  This file is generated code: any edits will be overwritten.

@_implementationOnly import CSteamworks

/// Steamworks [`ISteamRemotePlay`](https://partner.steamgames.com/doc/api/ISteamRemotePlay)
///
/// Access via `SteamAPI.remotePlay`.
public struct SteamRemotePlay {
    var interface: UnsafeMutablePointer<ISteamRemotePlay> {
        SteamAPI_SteamRemotePlay_v001()
    }

    init() {
    }

    /// Steamworks `ISteamRemotePlay::BGetSessionClientResolution()`
    public func getSessionClientResolution(sessionID: RemotePlaySessionID) -> (rc: Bool, resolutionX: Int, resolutionY: Int) {
        var tmp_resolutionX = Int32()
        var tmp_resolutionY = Int32()
        let rc = SteamAPI_ISteamRemotePlay_BGetSessionClientResolution(interface, RemotePlaySessionID_t(sessionID), &tmp_resolutionX, &tmp_resolutionY)
        return (rc: rc, resolutionX: Int(tmp_resolutionX), resolutionY: Int(tmp_resolutionY))
    }

    /// Steamworks `ISteamRemotePlay::BSendRemotePlayTogetherInvite()`
    public func sendRemotePlayTogetherInvite(friend: SteamID) -> Bool {
        SteamAPI_ISteamRemotePlay_BSendRemotePlayTogetherInvite(interface, UInt64(friend))
    }

    /// Steamworks `ISteamRemotePlay::GetSessionClientFormFactor()`
    public func getSessionClientFormFactor(sessionID: RemotePlaySessionID) -> SteamDeviceFormFactor {
        SteamDeviceFormFactor(SteamAPI_ISteamRemotePlay_GetSessionClientFormFactor(interface, RemotePlaySessionID_t(sessionID)))
    }

    /// Steamworks `ISteamRemotePlay::GetSessionClientName()`
    public func getSessionClientName(sessionID: RemotePlaySessionID) -> String? {
        SteamAPI_ISteamRemotePlay_GetSessionClientName(interface, RemotePlaySessionID_t(sessionID)).map { String($0) }
    }

    /// Steamworks `ISteamRemotePlay::GetSessionCount()`
    public func getSessionCount() -> Int {
        Int(SteamAPI_ISteamRemotePlay_GetSessionCount(interface))
    }

    /// Steamworks `ISteamRemotePlay::GetSessionID()`
    public func getSessionID(sessionIndex: Int) -> RemotePlaySessionID {
        RemotePlaySessionID(SteamAPI_ISteamRemotePlay_GetSessionID(interface, Int32(sessionIndex)))
    }

    /// Steamworks `ISteamRemotePlay::GetSessionSteamID()`
    public func getSessionSteamID(sessionID: RemotePlaySessionID) -> SteamID {
        SteamID(SteamAPI_ISteamRemotePlay_GetSessionSteamID(interface, RemotePlaySessionID_t(sessionID)))
    }
}
