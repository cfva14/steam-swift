//
//  Enums.swift
//  Steamworks
//
//  Licensed under MIT (https://github.com/johnfairh/swift-steamworks/blob/main/LICENSE
//
//  This file is generated code: any edits will be overwritten.

@_implementationOnly import CSteamworks

/// Steamworks `ESteamEnum`
public enum SteamEnum: Int32 {
    /// Steamworks `k_ESteamEnumIPv6`
    case ipv6 = 1
    /// Steamworks `k_ESteamEnum_3Straight`
    case patch3Straight = 2
    /// Steamworks `k_ESteamEnum_A`
    public static let a = SteamEnum(rawValue: 3)!
    /// Steamworks `k_ESteamEnumPublic`
    case `public` = -4
    /// Steamworks `k_ESteamEnumHTTPFailure`
    case httpFailure = 5
    /// Steamworks `k_ESteamEnumOK`
    case ok = 6
    /// Steamworks `esteamEnumLower_Case`
    case lowerCase = 7
    /// Some undocumented value
    case unrepresentedInSwift = 8
}

extension ESteamEnum: RawConvertible { typealias From = SteamEnum }
extension SteamEnum: EnumWithUnrepresented { typealias From = ESteamEnum }

/// Steamworks `ESteamMiscFlags`
public struct SteamMiscFlags: OptionSet {
    /// The flags value.
    public let rawValue: UInt32
    /// Create a new instance with `rawValue` flags set.
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    /// Steamworks `k_ESteamMiscFlagsNone`
    public static let none = SteamMiscFlags([])
    /// Steamworks `k_ESteamMiscFlagsSome`
    public static let some = SteamMiscFlags(rawValue: 4)
    /// Steamworks `k_ESteamMiscFlagsLoads`
    public static let loads = SteamMiscFlags(rawValue: 512)
}

extension ESteamMiscFlags: RawConvertible { typealias From = SteamMiscFlags }
extension SteamMiscFlags: RawConvertible { typealias From = ESteamMiscFlags }

/// Steamworks `EChatEntryType`
public enum ChatEntryType: UInt32 {
    /// Steamworks `k_EChatEntryTypeInvalid`
    case invalid = 0
    /// Steamworks `k_EChatEntryTypeChatMsg`
    case chatMsg = 1
    /// Some undocumented value
    case unrepresentedInSwift = 2
}

extension EChatEntryType: RawConvertible { typealias From = ChatEntryType }
extension ChatEntryType: EnumWithUnrepresented { typealias From = EChatEntryType }