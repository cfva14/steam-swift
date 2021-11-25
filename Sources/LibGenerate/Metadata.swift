//
//  Metadata.swift
//  LibGenerate
//
//  Licensed under MIT (https://github.com/johnfairh/swift-steamworks/blob/main/LICENSE
//

import Foundation

/// Decoded SDK `steam_api.json`.
struct SteamJSON: Codable {
    struct Struct: Codable {
        struct Field: Codable {
            let fieldname: String
            let fieldtype: String
            let `private`: Bool?
        }
        let callback_id: Int?
        let enums: [Enum]?
        let fields: [Field]
        let `struct`: String
        let methods: [Method]?
    }
    let callback_structs: [Struct]

    struct Const: Codable {
        let constname: String
        let consttype: String
        let constval: String
    }
    let consts: [Const]

    struct Enum: Codable {
        struct Value: Codable {
            let name: String
            let value: String
        }
        let enumname: String
        let fqname: String?
        let values: [Value]

        var name: String {
            fqname ?? enumname
        }
    }
    let enums: [Enum]

    struct Method: Codable {
        let callresult: String?
        let callback: String?
        let methodname: String
        let methodname_flat: String

        struct Param: Codable {
            let paramname: String
            let paramtype: String
            let paramtype_flat: String?
            let array_count: String?
            let buffer_count: String?
            let out_struct: String?
            let out_array_call: String?
            let out_array_count: String?
            let out_string_count: String?
            let out_buffer_count: String?
        }
        let params: [Param]
        let returntype: String
    }

    struct Accessor: Codable {
        let kind: String
        let name_flat: String
    }

    struct Interface: Codable {
        let classname: String
        let methods: [Method]
        let accessors: [Accessor]?
    }
    let interfaces: [Interface]

    let structs: [Struct]

    struct Typedef: Codable {
        let typedef: String
        let type: String
    }
    let typedefs: [Typedef]

    init(data: Data) throws {
        self = try JSONDecoder().decode(SteamJSON.self, from: data)
    }

    init(_ parts: [SteamJSON]) {
        self.callback_structs = parts.flatMap(\.callback_structs)
        self.consts = parts.flatMap(\.consts)
        self.enums = parts.flatMap(\.enums)
        self.interfaces = parts.flatMap(\.interfaces)
        self.structs = parts.flatMap(\.structs)
        self.typedefs = parts.flatMap(\.typedefs)
    }
}

/// Description of the `steam_api_patch.json` file that holds additions and corrections
/// to the SDK json.
///
/// Features:
/// * Constants: Fix value to something Swift understands
/// * Constants: Correct the type
/// * Constants: ignore constants
/// * Enums: use OptionSet or Enum in Swift
/// * Enums: value prefix to strip -- Steam has a clear convention for this but breaks it in
///   various ways that we have to hard-code.
/// * Enums: token to insert to avoid enum cases starting with numbers
/// * Enums: hint to generate a static member instead of an enum case
/// * Methods: correct the return type
/// * Methods: specify out-param behaviour when API call fails
/// * Methods: correct a parameter type
/// * Methods: set discardableResult
/// * Methods: patch in missed `out_string_count` etc.
/// * Methods: ignore entirely
/// * Structs: correct a field type (steam or swift)
/// * Structs: ignore field or entire struct
/// * Structs: correct the steam name
///
struct PatchJSON: Codable {
    struct Const: Codable {
        let value: String? // patch C expression for value
        let type: String? // patch C type
    }
    let consts: [String: Const] // constname key
    let consts_to_ignore: [String]

    struct Enum: Codable {
        let is_set: Bool? // values are bit-sig, model as OptionSet
        let prefix: String? // enum values non-default prefix
        let numeric_prefix: String? // numeric-identifier workaround

        struct Value: Codable {
            let force_static: Bool? // generate a static member instead of an enum case
        }
        let values: [String : Value]? // valuename key
    }
    let enums: [String : Enum] // name (== fqname ?? enumname) key

    struct Method: Codable {
        let returntype: String? // patch returntype (steam type)
        let out_param_iff_rc: String? // only copyback out-params if method rc matches
        let discardable_result: Bool? // set that attr
        let ignore: String? // ignore this method
        var bIgnore: Bool { ignore != nil }

        struct Param: Codable {
            let type: String? // patch paramtype (steam type)
            let out_string_count: String? // patch out_string_count
            let out_array_count: String? // patch out_array_count
            let array_count: String? // patch array_count
        }
        let params: [String : Param]?
    }
    let methods: [String : Method] // methodname_flat key

    struct Struct: Codable {
        struct Field: Codable {
            let fieldtype: String? // patch fieldtype (steam type)
            let swift_type: String? // custom swift type
            let ignore: String? // filter out broken / too weird fields
            var bIgnore: Bool { ignore != nil }
        }
        let fields: [String : Field]? // fieldname key
        let ignore: String? // filter out broken / too weird structs
        var bIgnore: Bool { ignore != nil }
        let name: String? // the steam json name is wrong...
    }
    let structs: [String: Struct] // struct.name key

    init(data: Data) throws {
        self = try JSONDecoder().decode(PatchJSON.self, from: data)
    }
}

/// Actual API metadata database with useful data from the json and our patch.
///
/// Also fast lookups and central access for weird special cases of knowledge needs
/// (like 'is this random string an enum?')
///
struct MetadataDB {
    struct Const {
        let name: String
        let type: String
        let value: String

        init(base: SteamJSON.Const, patch: PatchJSON.Const?) {
            self.name = base.constname
            self.type = patch?.type ?? base.consttype
            self.value = patch?.value ?? base.constval
        }
    }

    /// Indexed by `constname`, filtered by patch exclude-list
    let consts: [String : Const]

    final class Enum {
        let name: String
        let is_set: Bool
        let prefix: String
        let numericPrefix: String?

        struct Value: Codable {
            let name: String
            let value: String
            let forceStatic: Bool

            init(base: SteamJSON.Enum.Value, patch: PatchJSON.Enum.Value?) {
                name = base.name
                value = base.value
                forceStatic = patch?.force_static ?? false
            }
        }
        let values: [Value]

        init(base: SteamJSON.Enum, patch: PatchJSON.Enum?) {
            name = base.name
            is_set = patch?.is_set ?? false
            prefix = patch?.prefix ?? name
            numericPrefix = patch?.numeric_prefix
            values = base.values.map {
                Value(base: $0, patch: patch?.values?[$0.name])
            }
        }
    }
    /// Indexed by `enumname`
    let enums: [String : Enum]

    struct Method {
        let name: String
        let flatName: String
        let callResult: String?
        let callback: String?

        struct Param {
            let name: String
            let type: String
            let arrayCount: String?
            let outArrayLength: String?
            let outStringLength: String?
            // ?? let buffer_count: String?

            init(base: SteamJSON.Method.Param, patch: PatchJSON.Method.Param?) {
                self.name = base.paramname
                self.type = patch?.type ?? base.paramtype_flat ?? base.paramtype
                if let patchedArrayCount = patch?.array_count, patchedArrayCount.isEmpty {
                    self.arrayCount = nil // fix a mistake
                } else {
                    self.arrayCount = patch?.array_count ?? base.array_count
                }

                if let arrayCall = base.out_array_call {
                    // comma-separated list, first is param name, rest is dynamic recipe on how to calculate.
                    // used so sparingly (once) ignore the clever part.
                    self.outArrayLength = String(arrayCall.split(separator: ",")[0])
                } else if let arrayCount = patch?.out_array_count ?? base.out_array_count {
                    // const or param with the length
                    self.outArrayLength = arrayCount
                } else {
                    self.outArrayLength = nil
                }

                if let outStringCount = patch?.out_string_count ?? base.out_string_count {
                    self.outStringLength = outStringCount
                } else {
                    self.outStringLength = nil
                }
//              precondition(arrayCount == nil || outArrayLength == nil, "base=\(base), patch=\(patch)")
                // something weird in inventory...
                precondition(outArrayLength == nil || outStringLength == nil)
            }
        }
        let params: [Param]
        let returnType: String
        let outParamIffRc: String?
        let discardableResult: Bool
        let ignore: Bool

        init(base: SteamJSON.Method, patch: PatchJSON.Method?) {
            name = base.methodname
            flatName = base.methodname_flat
            callResult = base.callresult
            callback = base.callback
            params = base.params.map { .init(base: $0, patch: patch?.params?[$0.paramname]) }
            returnType = patch?.returntype ?? base.returntype
            outParamIffRc = patch?.out_param_iff_rc
            discardableResult = patch?.discardable_result ?? false
            ignore = patch?.bIgnore ?? false
        }
    }

    struct Interface {
        let name: String
        /// Indexed by `methodname_flat` ... `methodname` is not unique...
        let methods: [String : Method]

        enum Access {
            case global(String)
            case user(String)
            case gameserver(String)
            case userAndServer(String, String)
        }
        let access: Access

        init?(base: SteamJSON.Interface, patch: PatchJSON) {
            name = base.classname
            methods = .init(uniqueKeysWithValues: base.methods.map { baseMethod in
                (baseMethod.methodname_flat, Method(base: baseMethod, patch: patch.methods[baseMethod.methodname_flat]))
            })
            // Filter out things in 'interfaces' that are not actually steamworks API interfaces
            guard let accessors = base.accessors else {
                return nil
            }
            let accessorMap = Dictionary(uniqueKeysWithValues: accessors.map { ($0.kind, $0.name_flat) })
            if let g = accessorMap["global"] {
                access = .global(g)
            } else {
                let u = accessorMap["user"]
                let g = accessorMap["gameserver"]
                if let u = u {
                    if let g = g {
                        access = .userAndServer(u, g)
                    } else {
                        access = .user(u)
                    }
                } else if let g = g {
                    access = .gameserver(g)
                } else {
                    preconditionFailure("Confused by accessors for \(base.classname)")
                }
            }
        }
    }
    /// Indexed by `classname`
    let interfaces: [String : Interface]

    /// Shared type between callback-structs and regular structs - regular structs don't have
    /// a callback ID and may have methods (though these are rarely coherent)
    struct Struct {
        struct Field {
            let name: String
            let type: String
            let ignore: Bool
            let swiftType: String?

            init(base: SteamJSON.Struct.Field, patch: PatchJSON.Struct.Field?) {
                name = base.fieldname
                type = patch?.fieldtype ?? Self.patch(name: name, type: base.fieldtype)
                ignore = base.private ?? patch?.bIgnore ?? false
                swiftType = patch?.swift_type
            }

            /// Patch up some systemic errors / C-alignment-reasoning in types
            static func patch(name: String, type: String) -> String {
                if name.starts(with: "m_b") {
                    return "bool"
                }
                if type == "uint64" {
                    if name.re_isMatch("steamid", options: .i) { return "CSteamID" }
                    if name.re_isMatch("gameid", options: .i) { return "CGameID" }
                }
                return type
            }
        }

        let name: String // "struct" too annoying
        let fields: [Field]
        let callbackID: Int?
        let ignore: Bool
        /// Indexed by `name`
        let enums: [String : Enum]
        /// Indexed by `methodname_flat` ... `methodname` is not unique...
        let methods: [String : Method]

        init(base: SteamJSON.Struct, patch: PatchJSON) {
            let structPatch = patch.structs[base.struct]
            name = structPatch?.name ?? base.struct
            fields = base.fields.map {
                .init(base: $0, patch: structPatch?.fields?[$0.fieldname])
            }
            callbackID = base.callback_id
            ignore = structPatch?.bIgnore ?? false

            enums = .init(uniqueKeysWithValues: (base.enums ?? []).map { baseEnum in
                (baseEnum.name, Enum(base: baseEnum, patch: patch.enums[baseEnum.name]))
            })

            methods = .init(uniqueKeysWithValues: (base.methods ?? []).map { baseMethod in
                (baseMethod.methodname_flat, Method(base: baseMethod, patch: patch.methods[baseMethod.methodname_flat]))
            })
        }
    }
    /// Indexed by `struct` -- 'callback structs' first
    let structs: [String : Struct]

    typealias Typedef = SteamJSON.Typedef
    /// Indexed by `typedef`, order from original file
    let typedefs: [String : Typedef]

    init(base: SteamJSON, patch: PatchJSON) {
        let ignoredConsts = Set(patch.consts_to_ignore)
        consts = .init(uniqueKeysWithValues: base.consts.compactMap {
            let name = $0.constname
            guard !ignoredConsts.contains(name) else {
                return nil
            }
            return (name, Const(base: $0, patch: patch.consts[name]))
        })

        enums = .init(uniqueKeysWithValues: base.enums.map {
            ($0.name, Enum(base: $0, patch: patch.enums[$0.name]))
        })

        interfaces = .init(uniqueKeysWithValues: base.interfaces.compactMap {
            Interface(base: $0, patch: patch).map { ($0.name, $0) }
        })

        structs = .init(uniqueKeysWithValues: (base.callback_structs + base.structs).map {
            let s = Struct(base: $0, patch: patch)
            return (s.name, s) // structs can rename themselves...
        })

        typedefs = .init(uniqueKeysWithValues: base.typedefs.map {
            ($0.typedef, $0)
        })
    }
}


/// Sharable reference wrapper around the API metadata
///
/// The API available here is the patched version.
final class Metadata: CustomStringConvertible {
    let io: IO
    let db: MetadataDB

    private let nestedEnums: [String : MetadataDB.Enum]

    init(io: IO) throws {
        self.io = io

        let baseAPI = try SteamJSON(data: io.loadSDKJSON())
        let extraAPI = try SteamJSON(data: io.loadSDKExtraJSON())
        let patch = try PatchJSON(data: io.loadPatchJSON())

        self.db = MetadataDB(base: SteamJSON([baseAPI, extraAPI]), patch: patch)

        // cache enums that aren't in the normal place
        self.nestedEnums = .init(uniqueKeysWithValues: db.structs.values.flatMap {
            $0.enums.values.map { ($0.name, $0) }
        })

        Self.shared = self
    }

    var description: String {
        """
          Constants: \(db.consts.count)
          Enums: \(db.enums.count)
          Nested enums: \(nestedEnums.count)
          Interfaces: \(db.interfaces.count)
          Interface methods: \(db.interfaces.values.reduce(0) { $0 + $1.methods.count })
          Structs: \(db.structs.count), \(db.structs.values.filter(\.ignore).count) ignored
          Fields: \(db.structs.values.reduce(0) { $0 + $1.fields.count })
          Typedefs: \(db.typedefs.count)
        """
    }

    static private(set) var shared: Metadata?

    static private func findEnum(name: String) -> MetadataDB.Enum? {
        shared?.db.enums[name] ?? shared?.nestedEnums[name]
    }

    static func isEnum(steamType name: String) -> Bool {
        findEnum(name: name) != nil
    }

    static func isOptionSetEnum(steamType name: String) -> Bool {
        findEnum(name: name)?.is_set ?? false
    }

    static func isStruct(steamType name: String) -> Bool {
        shared.flatMap { $0.db.structs[name] != nil } ?? false
    }

    static func isTypedef(steamType name: String) -> Bool {
        shared.flatMap { $0.db.typedefs[name] != nil } ?? false
    }
}
