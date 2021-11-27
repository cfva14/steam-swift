//
//  SteamParties.swift
//  Steamworks
//
//  Licensed under MIT (https://github.com/johnfairh/swift-steamworks/blob/main/LICENSE
//
//  This file is generated code: any edits will be overwritten.

@_implementationOnly import CSteamworks

/// Steamworks [`ISteamParties`](https://partner.steamgames.com/doc/api/ISteamParties)
///
/// Access via `SteamAPI.parties`.
public struct SteamParties {
    var interface: UnsafeMutablePointer<ISteamParties> {
        SteamAPI_SteamParties_v002()
    }

    init() {
    }

    /// Steamworks `ISteamParties::CreateBeacon()`, callback
    public func createBeacon(openSlots: Int, beaconLocation: SteamPartyBeaconLocation, connectString: String, metadata: String, completion: @escaping (CreateBeaconCallback?) -> Void) {
        let rc = CSteamAPI_ISteamParties_CreateBeacon(interface, uint32(openSlots), SteamPartyBeaconLocation_t(beaconLocation), connectString, metadata)
        SteamBaseAPI.CallResults.shared.add(callID: rc, rawClient: SteamBaseAPI.makeRaw(completion))
    }

    /// Steamworks `ISteamParties::CreateBeacon()`, async
    func createBeacon(openSlots: Int, beaconLocation: SteamPartyBeaconLocation, connectString: String, metadata: String) async -> CreateBeaconCallback? {
        await withUnsafeContinuation {
            createBeacon(openSlots: openSlots, beaconLocation: beaconLocation, connectString: connectString, metadata: metadata, completion: $0.resume)
        }
    }

    /// Steamworks `ISteamParties::CancelReservation()`
    public func cancelReservation(beacon: PartyBeaconID, user: SteamID) {
        SteamAPI_ISteamParties_CancelReservation(interface, PartyBeaconID_t(beacon), UInt64(user))
    }

    /// Steamworks `ISteamParties::ChangeNumOpenSlots()`, callback
    public func changeNumOpenSlots(beacon: PartyBeaconID, openSlots: Int, completion: @escaping (ChangeNumOpenSlotsCallback?) -> Void) {
        let rc = SteamAPI_ISteamParties_ChangeNumOpenSlots(interface, PartyBeaconID_t(beacon), uint32(openSlots))
        SteamBaseAPI.CallResults.shared.add(callID: rc, rawClient: SteamBaseAPI.makeRaw(completion))
    }

    /// Steamworks `ISteamParties::ChangeNumOpenSlots()`, async
    func changeNumOpenSlots(beacon: PartyBeaconID, openSlots: Int) async -> ChangeNumOpenSlotsCallback? {
        await withUnsafeContinuation {
            changeNumOpenSlots(beacon: beacon, openSlots: openSlots, completion: $0.resume)
        }
    }

    /// Steamworks `ISteamParties::DestroyBeacon()`
    @discardableResult
    public func destroyBeacon(beacon: PartyBeaconID) -> Bool {
        SteamAPI_ISteamParties_DestroyBeacon(interface, PartyBeaconID_t(beacon))
    }

    /// Steamworks `ISteamParties::GetAvailableBeaconLocations()`
    @discardableResult
    public func getAvailableBeaconLocations(locationList: inout [SteamPartyBeaconLocation], maxNumLocations: Int) -> Bool {
        let tmp_locationList = UnsafeMutableBufferPointer<SteamPartyBeaconLocation_t>.allocate(capacity: maxNumLocations)
        defer { tmp_locationList.deallocate() }
        let rc = SteamAPI_ISteamParties_GetAvailableBeaconLocations(interface, tmp_locationList.baseAddress, uint32(maxNumLocations))
        locationList = tmp_locationList.map { SteamPartyBeaconLocation($0) }
        return rc
    }

    /// Steamworks `ISteamParties::GetBeaconByIndex()`
    public func getBeaconByIndex(index: Int) -> PartyBeaconID {
        PartyBeaconID(SteamAPI_ISteamParties_GetBeaconByIndex(interface, uint32(index)))
    }

    /// Steamworks `ISteamParties::GetBeaconDetails()`
    @discardableResult
    public func getBeaconDetails(beaconID: PartyBeaconID, beaconOwner: inout SteamID, location: inout SteamPartyBeaconLocation, metadata: inout String, metadataSize: Int) -> Bool {
        var tmp_beaconOwner = CSteamID()
        var tmp_location = SteamPartyBeaconLocation_t()
        let tmp_metadata = UnsafeMutableBufferPointer<CChar>.allocate(capacity: metadataSize)
        defer { tmp_metadata.deallocate() }
        let rc = SteamAPI_ISteamParties_GetBeaconDetails(interface, PartyBeaconID_t(beaconID), &tmp_beaconOwner, &tmp_location, tmp_metadata.baseAddress, Int32(metadataSize))
        beaconOwner = SteamID(tmp_beaconOwner)
        location = SteamPartyBeaconLocation(tmp_location)
        metadata = String(tmp_metadata)
        return rc
    }

    /// Steamworks `ISteamParties::GetBeaconLocationData()`
    @discardableResult
    public func getBeaconLocationData(beaconLocation: SteamPartyBeaconLocation, data: SteamPartyBeaconLocationData, dataStringOut: inout String, dataStringOutSize: Int) -> Bool {
        let tmp_dataStringOut = UnsafeMutableBufferPointer<CChar>.allocate(capacity: dataStringOutSize)
        defer { tmp_dataStringOut.deallocate() }
        let rc = SteamAPI_ISteamParties_GetBeaconLocationData(interface, SteamPartyBeaconLocation_t(beaconLocation), ESteamPartyBeaconLocationData(data), tmp_dataStringOut.baseAddress, Int32(dataStringOutSize))
        dataStringOut = String(tmp_dataStringOut)
        return rc
    }

    /// Steamworks `ISteamParties::GetNumActiveBeacons()`
    public func getNumActiveBeacons() -> Int {
        Int(SteamAPI_ISteamParties_GetNumActiveBeacons(interface))
    }

    /// Steamworks `ISteamParties::GetNumAvailableBeaconLocations()`
    @discardableResult
    public func getNumAvailableBeaconLocations(numLocations: inout Int) -> Bool {
        var tmp_numLocations = uint32()
        let rc = SteamAPI_ISteamParties_GetNumAvailableBeaconLocations(interface, &tmp_numLocations)
        numLocations = Int(tmp_numLocations)
        return rc
    }

    /// Steamworks `ISteamParties::JoinParty()`, callback
    public func joinParty(beaconID: PartyBeaconID, completion: @escaping (JoinPartyCallback?) -> Void) {
        let rc = SteamAPI_ISteamParties_JoinParty(interface, PartyBeaconID_t(beaconID))
        SteamBaseAPI.CallResults.shared.add(callID: rc, rawClient: SteamBaseAPI.makeRaw(completion))
    }

    /// Steamworks `ISteamParties::JoinParty()`, async
    func joinParty(beaconID: PartyBeaconID) async -> JoinPartyCallback? {
        await withUnsafeContinuation {
            joinParty(beaconID: beaconID, completion: $0.resume)
        }
    }

    /// Steamworks `ISteamParties::OnReservationCompleted()`
    public func onReservationCompleted(beacon: PartyBeaconID, user: SteamID) {
        SteamAPI_ISteamParties_OnReservationCompleted(interface, PartyBeaconID_t(beacon), UInt64(user))
    }
}