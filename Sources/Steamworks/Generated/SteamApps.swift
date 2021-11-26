//
//  SteamApps.swift
//  Steamworks
//
//  Licensed under MIT (https://github.com/johnfairh/swift-steamworks/blob/main/LICENSE
//
//  This file is generated code: any edits will be overwritten.

@_implementationOnly import CSteamworks

/// Steamworks [`ISteamApps`](https://partner.steamgames.com/doc/api/ISteamApps)
///
/// Access via `SteamAPI.apps`.
public struct SteamApps {
    var interface: UnsafeMutablePointer<ISteamApps> {
        SteamAPI_SteamApps_v008()
    }

    init() {
    }

    /// Steamworks `ISteamApps::BGetDLCDataByIndex()`
    public func getDLCDataByIndex(dlcIndex: Int, appID: inout AppID, available: inout Bool, name: inout String, nameBufferSize: Int) -> Bool {
        var tmp_appID = AppId_t()
        let tmp_name = UnsafeMutableBufferPointer<CChar>.allocate(capacity: nameBufferSize)
        defer { tmp_name.deallocate() }
        let rc = SteamAPI_ISteamApps_BGetDLCDataByIndex(interface, Int32(dlcIndex), &tmp_appID, &available, tmp_name.baseAddress, Int32(nameBufferSize))
        if rc {
            appID = AppID(tmp_appID)
            name = String(tmp_name)
        }
        return rc
    }

    /// Steamworks `ISteamApps::BIsAppInstalled()`
    public func isAppInstalled(id: AppID) -> Bool {
        SteamAPI_ISteamApps_BIsAppInstalled(interface, AppId_t(id))
    }

    /// Steamworks `ISteamApps::BIsCybercafe()`
    public func isCybercafe() -> Bool {
        SteamAPI_ISteamApps_BIsCybercafe(interface)
    }

    /// Steamworks `ISteamApps::BIsDlcInstalled()`
    public func isDlcInstalled(id: AppID) -> Bool {
        SteamAPI_ISteamApps_BIsDlcInstalled(interface, AppId_t(id))
    }

    /// Steamworks `ISteamApps::BIsLowViolence()`
    public func isLowViolence() -> Bool {
        SteamAPI_ISteamApps_BIsLowViolence(interface)
    }

    /// Steamworks `ISteamApps::BIsSubscribed()`
    public func isSubscribed() -> Bool {
        SteamAPI_ISteamApps_BIsSubscribed(interface)
    }

    /// Steamworks `ISteamApps::BIsSubscribedApp()`
    public func isSubscribedApp(id: AppID) -> Bool {
        SteamAPI_ISteamApps_BIsSubscribedApp(interface, AppId_t(id))
    }

    /// Steamworks `ISteamApps::BIsSubscribedFromFamilySharing()`
    public func isSubscribedFromFamilySharing() -> Bool {
        SteamAPI_ISteamApps_BIsSubscribedFromFamilySharing(interface)
    }

    /// Steamworks `ISteamApps::BIsSubscribedFromFreeWeekend()`
    public func isSubscribedFromFreeWeekend() -> Bool {
        SteamAPI_ISteamApps_BIsSubscribedFromFreeWeekend(interface)
    }

    /// Steamworks `ISteamApps::BIsTimedTrial()`
    public func isTimedTrial(secondsAllowed: inout Int, secondsPlayed: inout Int) -> Bool {
        var tmp_secondsAllowed = uint32()
        var tmp_secondsPlayed = uint32()
        let rc = SteamAPI_ISteamApps_BIsTimedTrial(interface, &tmp_secondsAllowed, &tmp_secondsPlayed)
        secondsAllowed = Int(tmp_secondsAllowed)
        secondsPlayed = Int(tmp_secondsPlayed)
        return rc
    }

    /// Steamworks `ISteamApps::BIsVACBanned()`
    public func isVACBanned() -> Bool {
        SteamAPI_ISteamApps_BIsVACBanned(interface)
    }

    /// Steamworks `ISteamApps::GetAppBuildId()`
    public func getAppBuildId() -> Int {
        Int(SteamAPI_ISteamApps_GetAppBuildId(interface))
    }

    /// Steamworks `ISteamApps::GetAppInstallDir()`
    public func getAppInstallDir(id: AppID, folder: inout String, folderBufferSize: Int) -> Int {
        let tmp_folder = UnsafeMutableBufferPointer<CChar>.allocate(capacity: folderBufferSize)
        defer { tmp_folder.deallocate() }
        let rc = Int(SteamAPI_ISteamApps_GetAppInstallDir(interface, AppId_t(id), tmp_folder.baseAddress, uint32(folderBufferSize)))
        folder = String(tmp_folder)
        return rc
    }

    /// Steamworks `ISteamApps::GetAppOwner()`
    public func getAppOwner() -> SteamID {
        SteamID(SteamAPI_ISteamApps_GetAppOwner(interface))
    }

    /// Steamworks `ISteamApps::GetAvailableGameLanguages()`
    public func getAvailableGameLanguages() -> String {
        String(SteamAPI_ISteamApps_GetAvailableGameLanguages(interface))
    }

    /// Steamworks `ISteamApps::GetCurrentBetaName()`
    public func getCurrentBetaName(name: inout String, nameBufferSize: Int) -> Bool {
        let tmp_name = UnsafeMutableBufferPointer<CChar>.allocate(capacity: nameBufferSize)
        defer { tmp_name.deallocate() }
        let rc = SteamAPI_ISteamApps_GetCurrentBetaName(interface, tmp_name.baseAddress, Int32(nameBufferSize))
        if rc {
            name = String(tmp_name)
        }
        return rc
    }

    /// Steamworks `ISteamApps::GetCurrentGameLanguage()`
    public func getCurrentGameLanguage() -> String {
        String(SteamAPI_ISteamApps_GetCurrentGameLanguage(interface))
    }

    /// Steamworks `ISteamApps::GetDLCCount()`
    public func getDLCCount() -> Int {
        Int(SteamAPI_ISteamApps_GetDLCCount(interface))
    }

    /// Steamworks `ISteamApps::GetDlcDownloadProgress()`
    public func getDlcDownloadProgress(appID: AppID, bytesDownloaded: inout UInt64, bytesTotal: inout UInt64) -> Bool {
        SteamAPI_ISteamApps_GetDlcDownloadProgress(interface, AppId_t(appID), &bytesDownloaded, &bytesTotal)
    }

    /// Steamworks `ISteamApps::GetEarliestPurchaseUnixTime()`
    public func getEarliestPurchaseUnixTime(appID: AppID) -> RTime32 {
        RTime32(SteamAPI_ISteamApps_GetEarliestPurchaseUnixTime(interface, AppId_t(appID)))
    }

    /// Steamworks `ISteamApps::GetFileDetails()`, callback
    public func getFileDetails(fileName: String, completion: @escaping (FileDetailsResult?) -> Void) {
        let rc = SteamAPI_ISteamApps_GetFileDetails(interface, fileName)
        SteamBaseAPI.CallResults.shared.add(callID: rc, rawClient: SteamBaseAPI.makeRaw(completion))
    }

    /// Steamworks `ISteamApps::GetFileDetails()`, async
    func getFileDetails(fileName: String) async -> FileDetailsResult? {
        await withUnsafeContinuation {
            getFileDetails(fileName: fileName, completion: $0.resume)
        }
    }

    /// Steamworks `ISteamApps::GetInstalledDepots()`
    public func getInstalledDepots(id: AppID, depots: inout [DepotID], maxDepots: Int) -> Int {
        let tmp_depots = UnsafeMutableBufferPointer<DepotId_t>.allocate(capacity: maxDepots)
        defer { tmp_depots.deallocate() }
        let rc = Int(SteamAPI_ISteamApps_GetInstalledDepots(interface, AppId_t(id), tmp_depots.baseAddress, uint32(maxDepots)))
        depots = tmp_depots.map { DepotID($0) }
        return rc
    }

    /// Steamworks `ISteamApps::GetLaunchCommandLine()`
    public func getLaunchCommandLine(commandLine: inout String, commandLineSize: Int) -> Int {
        let tmp_commandLine = UnsafeMutableBufferPointer<CChar>.allocate(capacity: commandLineSize)
        defer { tmp_commandLine.deallocate() }
        let rc = Int(SteamAPI_ISteamApps_GetLaunchCommandLine(interface, tmp_commandLine.baseAddress, Int32(commandLineSize)))
        commandLine = String(tmp_commandLine)
        return rc
    }

    /// Steamworks `ISteamApps::GetLaunchQueryParam()`
    public func getLaunchQueryParam(key: String) -> String {
        String(SteamAPI_ISteamApps_GetLaunchQueryParam(interface, key))
    }

    /// Steamworks `ISteamApps::InstallDLC()`
    public func installDLC(appID: AppID) {
        SteamAPI_ISteamApps_InstallDLC(interface, AppId_t(appID))
    }

    /// Steamworks `ISteamApps::MarkContentCorrupt()`
    public func markContentCorrupt(missingFilesOnly: Bool) -> Bool {
        SteamAPI_ISteamApps_MarkContentCorrupt(interface, missingFilesOnly)
    }

    /// Steamworks `ISteamApps::RequestAllProofOfPurchaseKeys()`
    public func requestAllProofOfPurchaseKeys() {
        SteamAPI_ISteamApps_RequestAllProofOfPurchaseKeys(interface)
    }

    /// Steamworks `ISteamApps::RequestAppProofOfPurchaseKey()`
    public func requestAppProofOfPurchaseKey(appID: AppID) {
        SteamAPI_ISteamApps_RequestAppProofOfPurchaseKey(interface, AppId_t(appID))
    }

    /// Steamworks `ISteamApps::UninstallDLC()`
    public func uninstallDLC(appID: AppID) {
        SteamAPI_ISteamApps_UninstallDLC(interface, AppId_t(appID))
    }
}