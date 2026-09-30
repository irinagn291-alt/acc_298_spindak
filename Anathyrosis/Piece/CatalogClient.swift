import Foundation

/// Role: Piece. Typed transport failures. DTO decode never crashes the crate.
enum CatalogFault: Error, Equatable, Sendable {
    case cancelled
    case missing
    case refused
    case transport
    case malformed
}

/// Role: Piece. One HTTP hop. Injected so tests never leave the process.
protocol CatalogCarrying: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// Role: Piece. URLSession hop, 15 s timeout, app User-Agent on every request.
struct CatalogSession: CatalogCarrying {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = CatalogClient.timeout
        configuration.timeoutIntervalForResource = CatalogClient.timeout
        configuration.httpAdditionalHeaders = ["User-Agent": CatalogClient.userAgent]
        self.session = URLSession(configuration: configuration)
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

struct SearchEnvelopeDTO: Decodable, Sendable {
    var records: [SearchRecordDTO]?
}

struct SearchRecordDTO: Decodable, Sendable {
    var systemNumber: String?
    var accessionNumber: String?
    var primaryTitle: String?
    var primaryMaker: FlexibleMaker?
    var primaryImageId: String?
    var primaryDate: String?

    enum CodingKeys: String, CodingKey {
        case systemNumber
        case accessionNumber
        case primaryTitle = "_primaryTitle"
        case primaryMaker = "_primaryMaker"
        case primaryImageId = "_primaryImageId"
        case primaryDate = "_primaryDate"
    }
}

enum FlexibleMaker: Decodable, Sendable {
    case name(String)
    case object(MakerObject)
    case unknown

    struct MakerObject: Decodable, Sendable {
        var name: String?
        var association: String?
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .name(string)
            return
        }
        if let object = try? container.decode(MakerObject.self) {
            self = .object(object)
            return
        }
        self = .unknown
    }

    var makerName: String? {
        switch self {
        case .name(let value):
            return CatalogClient.tidyMaker(value)
        case .object(let object):
            return CatalogClient.tidyMaker(object.name)
        case .unknown:
            return nil
        }
    }
}

/// Role: Piece. Owns Victoria and Albert Museum search. cgi search pl maps to q, page, page_size, images_exist=1. Never Open Food Facts. DTO then domain.
actor CatalogClient {
    static let userAgent = "Anathyrosis/1.0 (iOS; +https://anathyrosis-shaft.pro)"
    static let timeout: TimeInterval = 15
    static let searchHost = "api.vam.ac.uk"
    static let searchPath = "/v2/objects/search"
    /// Programmer constant. The domain string is fixed in SPEC.md.
    static let contactURL = URL(string: "https://anathyrosis-shaft.pro/contact-us")!
    /// Programmer constant. Victoria and Albert Museum credit lives on Settings.
    static let vamHomeURL = URL(string: "https://www.vam.ac.uk")!
    static let vamOpenDataURL = URL(string: "https://www.vam.ac.uk/info/open-data")!
    static let searchURL = URL(string: "https://api.vam.ac.uk/v2/objects/search")!

    private let carrier: any CatalogCarrying
    private let decoder: JSONDecoder

    init(carrier: any CatalogCarrying) {
        self.carrier = carrier
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
    }

    init() {
        self.init(carrier: CatalogSession())
    }

    func search(query: String, page: Int = 1, pageSize: Int = 20) async throws -> [CatalogRow] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let request = Self.searchRequest(query: trimmed, page: page, pageSize: pageSize)
        let data = try await send(request)
        let dto: SearchEnvelopeDTO
        do {
            dto = try decoder.decode(SearchEnvelopeDTO.self, from: data)
        } catch is CancellationError {
            throw CatalogFault.cancelled
        } catch {
            throw CatalogFault.malformed
        }
        var rows: [CatalogRow] = []
        var seen = Set<String>()
        for record in dto.records ?? [] {
            try Task.checkCancellation()
            guard let row = Self.mapRow(record), seen.insert(row.objectID).inserted else { continue }
            rows.append(row)
        }
        return rows
    }

    nonisolated static func searchRequest(
        query: String,
        page: Int = 1,
        pageSize: Int = 20
    ) -> URLRequest {
        let pageIndex = max(page, 1)
        let size = min(max(pageSize, 1), 50)
        var parts = URLComponents()
        parts.scheme = "https"
        parts.host = searchHost
        parts.path = searchPath
        parts.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: String(pageIndex)),
            URLQueryItem(name: "page_size", value: String(size)),
            URLQueryItem(name: "images_exist", value: "1"),
        ]
        var request = URLRequest(url: parts.url ?? searchURL, timeoutInterval: timeout)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    nonisolated static func objectURL(systemNumber: String) -> URL? {
        let trimmed = trim(systemNumber)
        guard !trimmed.isEmpty else { return nil }
        return URL(string: "https://collections.vam.ac.uk/item/\(trimmed)")
    }

    nonisolated static func iiifThumb(imageID: String) -> String {
        "https://framemark.vam.ac.uk/collections/\(imageID)/full/!400,/0/default.jpg"
    }

    nonisolated static func thumbURL(from raw: String?) -> URL? {
        guard let string = thumbURLString(from: raw) else { return nil }
        return URL(string: string)
    }

    nonisolated static func thumbURLString(from raw: String?) -> String? {
        let trimmed = trim(raw)
        guard !trimmed.isEmpty else { return nil }
        var value = trimmed
        if value.hasPrefix("http://") {
            value = "https://" + value.dropFirst("http://".count)
        }
        return value
    }

    nonisolated static func tidyMaker(_ raw: String?) -> String? {
        var name = trim(raw)
        guard !name.isEmpty else { return nil }
        while name.hasSuffix(")"), let open = name.lastIndex(of: "(") {
            name = String(name[..<open]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let comma = name.firstIndex(of: ",") {
            let last = name[..<comma].trimmingCharacters(in: .whitespacesAndNewlines)
            let first = name[name.index(after: comma)...].trimmingCharacters(in: .whitespacesAndNewlines)
            if !first.isEmpty, !last.isEmpty {
                name = "\(first) \(last)"
            }
        }
        return name.isEmpty ? nil : name
    }

    private static func mapRow(_ record: SearchRecordDTO) -> CatalogRow? {
        let objectID = trim(record.systemNumber)
        let maker = record.primaryMaker?.makerName ?? ""
        let title = trim(record.primaryTitle)
        let imageID = trim(record.primaryImageId)
        guard !objectID.isEmpty, !maker.isEmpty, !title.isEmpty, !imageID.isEmpty else { return nil }
        return CatalogRow(
            objectID: objectID,
            maker: maker,
            title: title,
            imageURLString: iiifThumb(imageID: imageID),
            dated: emptyToNil(record.primaryDate)
        )
    }

    nonisolated private static func trim(_ value: String?) -> String {
        (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    nonisolated private static func emptyToNil(_ value: String?) -> String? {
        let trimmed = trim(value)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func send(_ request: URLRequest, retry: Bool = true) async throws -> Data {
        do {
            try Task.checkCancellation()
            let (data, response) = try await carrier.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw CatalogFault.transport
            }
            if http.statusCode == 404 {
                throw CatalogFault.missing
            }
            if http.statusCode == 401 || http.statusCode == 403 {
                throw CatalogFault.refused
            }
            guard (200 ..< 300).contains(http.statusCode) else {
                if retry {
                    return try await send(request, retry: false)
                }
                throw CatalogFault.transport
            }
            return data
        } catch is CancellationError {
            throw CatalogFault.cancelled
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw CatalogFault.cancelled
        } catch let fault as CatalogFault {
            throw fault
        } catch {
            if retry, Self.transient(error) {
                return try await send(request, retry: false)
            }
            throw CatalogFault.transport
        }
    }

    private static func transient(_ error: Error) -> Bool {
        guard let urlError = error as? URLError else { return false }
        switch urlError.code {
        case .timedOut, .networkConnectionLost, .notConnectedToInternet,
             .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
            return true
        default:
            return false
        }
    }
}
