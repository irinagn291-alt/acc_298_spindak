import Foundation

/// Role: Shaft. Projects Shaft to UserDefaults ahy.shaft.v1 plus an atomic Application Support file. Views never touch this type.
actor ShaftVault {
    private let directory: URL
    private let suiteName: String?
    private let fileManager: FileManager

    init(
        directory: URL,
        suiteName: String? = nil,
        fileManager: FileManager = .default
    ) {
        self.directory = directory
        self.suiteName = suiteName
        self.fileManager = fileManager
    }

    static func applicationSupportDirectory(fileManager: FileManager = .default) throws -> URL {
        let root = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return root.appendingPathComponent("Spindak", isDirectory: true)
    }

    func load() -> (shaft: Shaft, warning: ShaftWarning?) {
        if let shaft = decode(defaults().data(forKey: ShaftKey.snapshot)) {
            return (shaft, nil)
        }
        if let shaft = decode(read(fileURL)) {
            return (shaft, nil)
        }
        if let shaft = decode(defaults().data(forKey: ShaftKey.backup)) {
            return (shaft, .recoveredFromBackup)
        }
        if let shaft = decode(read(backupURL)) {
            return (shaft, .recoveredFromBackup)
        }
        let hadPayload = defaults().data(forKey: ShaftKey.snapshot) != nil
            || fileManager.fileExists(atPath: fileURL.path)
        return (.empty, hadPayload ? .startedEmpty : nil)
    }

    func save(_ shaft: Shaft) throws {
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try ShaftDocument.encode(shaft)
        let box = defaults()
        if let current = box.data(forKey: ShaftKey.snapshot) {
            box.set(current, forKey: ShaftKey.backup)
        }
        if fileManager.fileExists(atPath: fileURL.path) {
            try? fileManager.removeItem(at: backupURL)
            try? fileManager.copyItem(at: fileURL, to: backupURL)
        }
        box.set(data, forKey: ShaftKey.snapshot)
        try data.write(to: fileURL, options: .atomic)
    }

    func wipe() throws {
        let box = defaults()
        box.removeObject(forKey: ShaftKey.snapshot)
        box.removeObject(forKey: ShaftKey.backup)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
        if fileManager.fileExists(atPath: backupURL.path) {
            try fileManager.removeItem(at: backupURL)
        }
    }

    func demoPlanted() -> Bool {
        defaults().object(forKey: ShaftKey.demo) != nil
    }

    func markDemoPlanted() {
        defaults().set(true, forKey: ShaftKey.demo)
    }

    private func decode(_ data: Data?) -> Shaft? {
        guard let data else { return nil }
        return try? ShaftDocument.decode(data)
    }

    private func read(_ url: URL) -> Data? {
        try? Data(contentsOf: url)
    }

    private var fileURL: URL {
        directory.appendingPathComponent("shaft.json", isDirectory: false)
    }

    private var backupURL: URL {
        directory.appendingPathComponent("shaft.json.backup", isDirectory: false)
    }

    private func defaults() -> UserDefaults {
        if let suiteName {
            return UserDefaults(suiteName: suiteName) ?? .standard
        }
        return .standard
    }
}
