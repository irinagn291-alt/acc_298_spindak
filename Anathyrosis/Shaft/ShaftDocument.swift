import Foundation

/// Role: Shaft. Preference keys. Snapshot is JSON Data under ahy.shaft.v1. Demo is Simulator-only.
enum ShaftKey {
    static let snapshot = "ahy.shaft.v1"
    static let backup = "ahy.shaft.v1.backup"
    static let demo = "ahy.demo.v1"
}

enum ShaftCodecError: Error, Equatable, Sendable {
    case unsupportedSchema(Int)
    case corrupt
}

/// Role: Shaft. Codable ShaftDocument. schemaVersion from 1. Anastylosis case is stored. Rebuilt-ness is not a parallel bool.
enum ShaftDocument {
    static func encode(_ shaft: Shaft) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        var copy = shaft
        copy.schemaVersion = Shaft.currentSchema
        return try encoder.encode(RootFile(shaft: copy))
    }

    static func decode(_ data: Data) throws -> Shaft {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let probe: SchemaProbe
        do {
            probe = try decoder.decode(SchemaProbe.self, from: data)
        } catch {
            throw ShaftCodecError.corrupt
        }
        switch probe.schemaVersion {
        case 1:
            do {
                var shaft = try decoder.decode(RootFile.self, from: data).shaft
                shaft.schemaVersion = Shaft.currentSchema
                return shaft
            } catch let error as ShaftCodecError {
                throw error
            } catch {
                throw ShaftCodecError.corrupt
            }
        default:
            throw ShaftCodecError.unsupportedSchema(probe.schemaVersion)
        }
    }
}

private struct SchemaProbe: Decodable {
    var schemaVersion: Int
}

private struct RootFile: Codable {
    var schemaVersion: Int
    var onboardingComplete: Bool
    var pieces: [Piece]
    var hanging: ShaftHang
    var clampMarks: [ClampMark]
    var spallMarks: [SpallMark]
    var peelLog: [PeelRef]
    var cachedRows: [CatalogRow]
    var focusedPieceID: UUID?

    init(shaft: Shaft) {
        schemaVersion = shaft.schemaVersion
        onboardingComplete = shaft.onboardingComplete
        pieces = shaft.pieces
        hanging = shaft.hanging
        clampMarks = shaft.clampMarks
        spallMarks = shaft.spallMarks
        peelLog = shaft.peelLog
        cachedRows = shaft.cachedRows
        focusedPieceID = shaft.focusedPieceID
    }

    var shaft: Shaft {
        Shaft(
            schemaVersion: schemaVersion,
            onboardingComplete: onboardingComplete,
            pieces: pieces,
            hanging: hanging,
            clampMarks: clampMarks,
            spallMarks: spallMarks,
            peelLog: peelLog,
            cachedRows: cachedRows,
            focusedPieceID: focusedPieceID
        )
    }
}
