//
//  Names.swift
//  LibGenerate
//
//  Licensed under MIT (https://github.com/johnfairh/swift-steamworks/blob/main/LICENSE
//

/// Utilities for converting Steamworks API names to Swift names.
extension String {
    /// * Convert arrays
    /// * Drop unwanted suffixes
    /// * Get rid of C++ nesting - everything top-level in Swift
    /// * Drop leading capital E/I/C - used in SDK for enums/interfaces/classes (but not for structs...)
    var asSwiftTypeName: String {
        if let match = re_match(#"^(.*) +\[.*\]"#) {
            if let special = steamArrayElementTypeToSwiftArrayTypes[match[1]] {
                return special
            }
            return "[\(match[1].asSwiftTypeName)]"
        }
        if let mapped = steamToSwiftTypes[self] ?? Metadata.steamToSwiftTypeName(self) {
            return mapped
        }
        var name = re_sub("_t\\b", with: "")
            .re_sub("^(const |.*::)", with: "")
            .re_sub("Id\\b", with: "ID")
        if !Metadata.isStruct(steamType: self) {
            name = name.re_sub("^[CEI](?=[A-Z])", with: "")
        }
        return name.replacingOccurrences(of: "_", with: "")
    }

    /// Given a canonical C++ type name, convert it to how Swift sees it
    var asSwiftNameForSteamType: String {
        replacingOccurrences(of: "::", with: ".")
    }

    /// Swift expression for 'casting' from this string, itself a Swift expression, to the given type
    func asCast(to: String?) -> String {
        guard let to = to else {
            return self
        }
        if to == "char **" {
            return "SteamStringArray(\(self)).cStrings" // no no this is broken, have to use with... pattern
        }
        guard to.hasSuffix("?") else {
            return "\(to)(\(self))"
        }
        return "\(self).map { \(to.dropLast())($0) }"
    }

    /// Decompose a C fixed-size array into its pieces
    var parseCArray: (String, Int)? {
        re_match(#"^(.*) \[(.+)\]$"#).flatMap { ($0[1], Int($0[2])!) }
    }

    /// * get rid of 'BIsBShortForBool'
    /// * to lowerCamelCase
    /// * keep one leading underscore, erase all others
    /// * backticks if accidentally a Swift keyword
    /// * special cases to taste...
    var asSwiftIdentifier: String {
        switch self {
        case "IPv4", "IPv6": return self.lowercased()
        default:
            return re_sub("^B(?=[A-Z].*[a-z])", with: "")
                .re_sub("^[A-Z]+?(?=$|[^A-Z]|[A-Z][a-z])") { $0.lowercased() }
                .re_sub("(?<!^)_", with: "")
                .backtickedIfNecessary
        }
    }

    /// For method parameters and (derivedly) structure members
    ///
    /// Try to get rid of the hungarian prefix without losing meaning.
    var asSwiftParameterName: String {
        if let exception = steamParameterNamesExceptions[self] {
            return exception
        }
        // 'steamID' is used as a single hungarian character with various spellings
        if let matches = re_match("^p?(?:Out)?steamID(.+)$", options: .i) {
            return matches[1].asSwiftIdentifier
        }
        // 'i' usually means 'index' into some constant, bit cargo culty though
        if let match = re_match("^i([A-Z].*?)(?:Index)?$") {
            return "\(match[1])Index".asSwiftIdentifier
        }
        // 'cch' special cases, avoid collapsing 'cchFoo' and 'pchFoo' to the same thing
        if let match = re_match("^p?c(?:ch|u?b)([A-Z][a-z]*.*?)(?:Length|Size)?$") {
            return "\(match[1])Size".asSwiftIdentifier
        }
        // Ultimate fallback - strip lower-case prefix and convert
        return re_sub("^[a-z]*(?=[A-Z])") {
            steamParameterNameGoodPrefixes.contains($0) ? $0 : ""
        }.asSwiftIdentifier
    }

    /// 99+% of them start with "m_" which I vaguely remember is a MSVC++ meme, then the r-hung. stuff
    var asSwiftStructFieldName: String {
        re_sub("^m_", with: "").asSwiftParameterName
    }

    /// Mix of SHOUTY_C_DEFINE and k_IsForKonstant names
    var asSwiftConstantName: String {
        if !re_isMatch("[a-z]") {
            return self
        }
        return re_sub("^k_", with: "").asSwiftParameterName
    }

    /// Some kind of sizing arithmetic expression involving parameter names
    var asSwiftParameterExpression: String {
        self.split(separator: " ")
            .map { String($0).asSwiftParameterName }
            .joined(separator: " ")
    }

    /// Tuned specifically for the subset used to define constants
    var asSwiftValue: String {
        re_sub(#"\(.*?\) *"#, with: "")     // drop weird cast
            .re_sub("(?<=^-|~) ", with: "") // no spacing for unary operators ...
            .re_sub("ull$", with: "")       // no int-length suffix
    }

    /// WBN to have a runtime function for this ...
    var backtickedIfNecessary: String {
        backtickKeywords.contains(self) ? "`\(self)`" : self
    }

    /// `self` is a a steam-declared (C++) type, represented in the Swift interface
    /// as `asSwiftTypeName`.  What Swift type is required to pass this to the
    /// steamworks interface?   This is normally `self`, the type itself, but there
    /// are special cases thanks to things like the Swift Clang Importer magicking
    /// strings and our usage of `Int` upstream.  `OptionSet` enums are
    /// confusing again - see `EnumConvertible` discussion.
    var asSwiftTypeForPassingIntoSteamworks: String? {
        if steamTypesPassedInTransparently.contains(self) {
            return nil
        }
        return asExplicitSwiftTypeForPassingIntoSteamworks
    }

    /// As above but with explicit types, not used calling a C function with clang importer magic
    var asExplicitSwiftTypeForPassingIntoSteamworks: String {
        if let special = steamTypesPassedInStrangely[self] {
            return special
        }
        if let optionSetType = Metadata.isOptionSetEnumPassedUnpredictably(steamType: self) {
            return optionSetType
        }
        if self == asSwiftTypeName {
            return "CSteamworks.\(self)"
        }
        return asSwiftNameForSteamType.re_sub("^const ", with: "")
    }

    /// For constructing a temporary instance, in Swift, to pass by ref to Steamworks
    /// and then to be copied back out to the Swift type.
    func asExplicitSwiftInstanceForPassingIntoSteamworks(_ initWith: String = "") -> String {
        let typename = asExplicitSwiftTypeForPassingIntoSteamworks
        let suffix = Metadata.isEnum(steamType: self) ? "(rawValue: 0)" : "(\(initWith))"
        return typename + suffix
    }

    /// Can a steam type be used transparently as an out param in Swift.
    var isTransparentOutType: Bool {
        steamTypesPassedInTransparently.contains(self)
    }

    var asSwiftTypeForPassingOutOfSteamworks: String? {
        if steamTypesPassedOutTransparently.contains(self) {
            return nil
        }
        return asSwiftTypeName
    }

    /// Drop one layer of C pointers from a type
    var depointered: String {
        re_sub(" *\\*$", with: "")
    }
}

/// Just what we've seen necessary
private let backtickKeywords = Set<String>([
    "case", "default", "for", "internal", "private", "protocol", "public",
    "switch", "init", "repeat"
])

// How to represent a steam type in the Swift interface, special cases
private let steamToSwiftTypes: [String : String] = [
    // Base types
    "const char *" : "String",
    "int" : "Int",
    "uint8" : "Int",
    "uint16" : "Int",
    "uint32" : "Int",
    "int32" : "Int",
    "const int32" : "Int", // hmm
    "int64" : "Int",
    "int64_t" : "Int", // steamnetworking == disaster
    "uint64": "UInt64",
    "bool" : "Bool",
    "float" : "Float",
    "double" : "Double",
    "void *" : "UnsafeMutableRawPointer",
    "const void *": "UnsafeRawPointer",
    "uint8 *" : "UnsafeMutablePointer<UInt8>",
    "uint64_steamid" : "SteamID",
    "uint64_gameid" : "GameID",
    "const char **": "[String]",
    "char": "Int", // SteamInput going its own way...
    "unsigned short": "Int", // ""
    "unsigned int": "Int", // ""

    // Misc
    "SteamParamStringArray_t" : "[String]" // weirdness, tbd
]

// How to represent an array of steam types (in a struct field,) special cases
private let steamArrayElementTypeToSwiftArrayTypes: [String : String] = [
    "char" : "String",
    "uint8" : "[UInt8]" // Should be Data but can't use Foundation inside Steamworks because C++!
]

// Steam types whose Swift type version is typesafe to pass
// directly (without a cast) to a Steamworks function expecting
// the Steam type.
private let steamTypesPassedInTransparently = Set<String>([
    "bool", "const char *", "void *", "uint8 *",
    "const void *", "float", "double", "uint64",

    "SteamAPIWarningMessageHook_t" // function pointer special case
])

// Steam types whose Swift type version is typesafe to pass
// directly (without a cast) from a Steamworks function to a
// Swift value expecting the corresponding Swift type.
private let steamTypesPassedOutTransparently = Set<String>([
    "bool", "void"
])

// Steam types whose Swift type version needs a non-standard
// cast to pass to a Steamworks function expecting the Steam type.
private let steamTypesPassedInStrangely: [String : String] = [
    "int" : "Int32",
    "bool" : "Bool",
    "uint64_steamid" : "UInt64",
    "uint64_gameid" : "UInt64",
    "unsigned short" : "UInt16",
    "unsigned int" : "UInt32",
    "char" : "Int8"
]

// Parameter/field names where no rules are followed and we
// have to hard-code something acceptable
private let steamParameterNamesExceptions: [String : String] = [
    "iFriendFlags" : "friendFlags"
]

// Parameter/field hungarian-smelling prefixes that are actually
// parts of the name...
private let steamParameterNameGoodPrefixes = Set<String>([
    "friends", "steam", "csecs", "identity", "addr", "debug",
    "rtime", "src"
])

extension String {
    func indented(_ level: Int) -> String {
        guard !isEmpty else {
            return self
        }
        return String(repeating: "    ", count: level) + self
    }
}

extension Sequence where Element == String {
    func indented(_ level: Int) -> [String] {
        map { $0.indented(level) }
    }
}
