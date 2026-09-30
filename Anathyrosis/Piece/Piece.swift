import Foundation

/// Role: Piece. Work. Saved V&A accession with maker, title, IIIF image, daykey Int YYYYMMDD, and stored Anastylosis case.
struct Piece: Identifiable, Equatable, Sendable, Codable {
    var id: UUID
    var objectID: String
    var maker: String
    var title: String
    var imageURLString: String?
    var dated: String?
    var daykey: Int
    var anastylosis: Anastylosis

    var imageURL: URL? {
        CatalogClient.thumbURL(from: imageURLString)
    }

    static func spoil(
        from row: CatalogRow,
        id: UUID = UUID(),
        daykey: Int
    ) -> Piece {
        Piece(
            id: id,
            objectID: row.objectID,
            maker: row.maker,
            title: row.title,
            imageURLString: row.imageURLString,
            dated: row.dated,
            daykey: daykey,
            anastylosis: .spoil
        )
    }
}

/// Role: Piece. Catalog row before it is written Spoil. Cached so empty or failed V&A search still hangs from the crate shelf.
struct CatalogRow: Identifiable, Equatable, Sendable, Codable {
    var objectID: String
    var maker: String
    var title: String
    var imageURLString: String?
    var dated: String?

    var id: String { objectID }

    var imageURL: URL? {
        CatalogClient.thumbURL(from: imageURLString)
    }
}
