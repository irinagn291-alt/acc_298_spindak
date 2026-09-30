import XCTest
@testable import Anathyrosis

final class CatalogClientTests: XCTestCase {
    func testCgiSearchPlMapsOntoVASearch() throws {
        let page2 = CatalogClient.searchRequest(query: "constable", page: 2, pageSize: 10)
        let url = try XCTUnwrap(page2.url)
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let keyed = Dictionary(uniqueKeysWithValues: items.compactMap { item in
            item.value.map { (item.name, $0) }
        })
        XCTAssertEqual(url.host, "api.vam.ac.uk")
        XCTAssertEqual(url.path, "/v2/objects/search")
        XCTAssertEqual(keyed["q"], "constable")
        XCTAssertEqual(keyed["page"], "2")
        XCTAssertEqual(keyed["page_size"], "10")
        XCTAssertEqual(keyed["images_exist"], "1")
        XCTAssertNil(keyed["search_terms"])
        XCTAssertFalse(url.absoluteString.contains("openfoodfacts"))
        XCTAssertFalse(url.absoluteString.contains("cgi/search.pl"))
        XCTAssertFalse(url.absoluteString.contains("world.openfoodfacts.org"))
        XCTAssertFalse(url.absoluteString.contains("api.artic.edu"))
        XCTAssertFalse(url.absoluteString.contains("collectionapi.metmuseum.org"))
        XCTAssertFalse(url.absoluteString.contains("query.wikidata.org"))
        XCTAssertEqual(page2.timeoutInterval, 15)
        XCTAssertEqual(page2.value(forHTTPHeaderField: "User-Agent"), CatalogClient.userAgent)
        XCTAssertEqual(CatalogClient.userAgent, "Anathyrosis/1.0 (iOS; +https://anathyrosis-shaft.pro)")
        XCTAssertEqual(
            CatalogClient.iiifThumb(imageID: "2006AP2028"),
            "https://framemark.vam.ac.uk/collections/2006AP2028/full/!400,/0/default.jpg"
        )
        XCTAssertEqual(
            CatalogClient.objectURL(systemNumber: "O82677")?.absoluteString,
            "https://collections.vam.ac.uk/item/O82677"
        )
        XCTAssertEqual(CatalogClient.tidyMaker("Constable, John (RA)"), "John Constable")
        XCTAssertEqual(CrateShelf.bundled.rows[0].objectID, "O82677")
        XCTAssertEqual(CrateShelf.bundled.rows[0].title, "Salisbury Cathedral from the Close")
        XCTAssertTrue(CrateShelf.bundled.rows[0].imageURLString?.contains("2006AP2028") ?? false)
    }

    func testDTOMapsVAFieldsThenDomainRow() async throws {
        let carrier = ScriptedCarrier(results: [
            .success((VAFixtures.searchJSON, VAFixtures.response(VAFixtures.searchURL, 200))),
        ])
        let client = CatalogClient(carrier: carrier)
        let rows = try await client.search(query: "constable", page: 1)
        let row = try XCTUnwrap(rows.first)
        XCTAssertEqual(row.objectID, "O82677")
        XCTAssertEqual(row.maker, "John Constable")
        XCTAssertEqual(row.title, "Salisbury Cathedral from the Close")
        XCTAssertEqual(row.imageURLString, CatalogClient.iiifThumb(imageID: "2006AP2028"))
        XCTAssertEqual(row.dated, "1820 August")
        let requests = await carrier.recordedRequests()
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests.first?.value(forHTTPHeaderField: "User-Agent"), CatalogClient.userAgent)
    }

    func testStringMakerAndMissingImageAreHandled() async throws {
        let carrier = ScriptedCarrier(results: [
            .success((VAFixtures.mixedJSON, VAFixtures.response(VAFixtures.searchURL, 200))),
        ])
        let client = CatalogClient(carrier: carrier)
        let rows = try await client.search(query: "rossetti")
        XCTAssertEqual(rows.map(\.objectID), ["O14962"])
        XCTAssertEqual(rows.first?.maker, "Dante Gabriel Rossetti")
        XCTAssertEqual(rows.first?.title, "The Day Dream")
    }

    func testTransientTransportRetriesOnce() async throws {
        let carrier = ScriptedCarrier(results: [
            .failure(URLError(.timedOut)),
            .success((VAFixtures.searchJSON, VAFixtures.response(VAFixtures.searchURL, 200))),
        ])
        let client = CatalogClient(carrier: carrier)
        let rows = try await client.search(query: "constable")
        XCTAssertEqual(rows.count, 1)
        let count = await carrier.recordedRequests().count
        XCTAssertEqual(count, 2)
    }

    func testDoesNotRetry404() async {
        let carrier = ScriptedCarrier(results: [
            .success((Data(), VAFixtures.response(VAFixtures.searchURL, 404))),
            .success((VAFixtures.searchJSON, VAFixtures.response(VAFixtures.searchURL, 200))),
        ])
        let client = CatalogClient(carrier: carrier)
        do {
            _ = try await client.search(query: "constable")
            XCTFail("expected missing")
        } catch {
            XCTAssertEqual(error as? CatalogFault, .missing)
        }
        let count = await carrier.recordedRequests().count
        XCTAssertEqual(count, 1)
    }

    func testMalformedJSONIsHandled() async {
        let carrier = ScriptedCarrier(results: [
            .success((Data("not-json".utf8), VAFixtures.response(VAFixtures.searchURL, 200))),
        ])
        let client = CatalogClient(carrier: carrier)
        do {
            _ = try await client.search(query: "constable")
            XCTFail("malformed")
        } catch {
            XCTAssertEqual(error as? CatalogFault, .malformed)
        }
    }

    func testEmptyQueryDoesNotHitNetwork() async throws {
        let carrier = ScriptedCarrier(results: [
            .success((VAFixtures.searchJSON, VAFixtures.response(VAFixtures.searchURL, 200))),
        ])
        let client = CatalogClient(carrier: carrier)
        let rows = try await client.search(query: "   ")
        XCTAssertTrue(rows.isEmpty)
        let count = await carrier.recordedRequests().count
        XCTAssertEqual(count, 0)
    }
}

private actor ScriptedCarrier: CatalogCarrying {
    private var results: [Result<(Data, URLResponse), Error>]
    private var requests: [URLRequest] = []

    init(results: [Result<(Data, URLResponse), Error>]) {
        self.results = results
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        guard !results.isEmpty else { throw URLError(.cannotConnectToHost) }
        return try results.removeFirst().get()
    }

    func recordedRequests() -> [URLRequest] {
        requests
    }
}

enum VAFixtures {
    static let searchURL = URL(string: "https://api.vam.ac.uk/v2/objects/search")!

    static let searchJSON = Data(
        """
        {"records":[{"systemNumber":"O82677","accessionNumber":"318-1888","_primaryTitle":"Salisbury Cathedral from the Close","_primaryMaker":{"name":"Constable, John (RA)","association":"artist"},"_primaryImageId":"2006AP2028","_primaryDate":"1820 August"}]}
        """.utf8
    )

    static let mixedJSON = Data(
        """
        {"records":[{"systemNumber":"O00000","accessionNumber":"x","_primaryTitle":"No Picture","_primaryMaker":{"name":"Someone"},"_primaryImageId":"","_primaryDate":"1800"},{"systemNumber":"O14962","accessionNumber":"CAI.3","_primaryTitle":"The Day Dream","_primaryMaker":"Rossetti, Dante Gabriel","_primaryImageId":"2006AP8073","_primaryDate":"1880"}]}
        """.utf8
    )

    static func response(_ url: URL, _ code: Int) -> URLResponse {
        HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
    }
}
