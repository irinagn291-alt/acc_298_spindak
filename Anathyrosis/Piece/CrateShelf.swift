import Foundation

/// Role: Piece. Bundled crate shelf. Empty or failed V&A search hangs from here. Not a food catalog.
struct CrateShelf: Sendable {
    var rows: [CatalogRow]

    static let bundled = CrateShelf(rows: Self.makeRows())

    private static func makeRows() -> [CatalogRow] {
        [
            row(
                "O82677",
                "John Constable",
                "Salisbury Cathedral from the Close",
                "1820 August",
                "2006AP2028"
            ),
            row(
                "O56525",
                "Joseph Mallord William Turner",
                "Venice from the Giudecca",
                "1840",
                "2024NX3090"
            ),
            row(
                "O14962",
                "Dante Gabriel Rossetti",
                "The Day Dream",
                "1880",
                "2006AP8073"
            ),
            row(
                "O80546",
                "John Everett Millais",
                "Pizarro Seizing the Inca of Peru",
                "1846",
                "2006AG3579"
            ),
            row(
                "O84528",
                "John Constable",
                "Branch Hill Pond Hampstead",
                "1819",
                "2014GY5228"
            ),
            row(
                "O80862",
                "Joseph Mallord William Turner",
                "East Cowes Castle",
                "1827-1828",
                "2006AG3585"
            ),
            row(
                "O77435",
                "John Constable",
                "Gillingham Mill Dorset",
                "1823-1827",
                "2006AU6480"
            ),
            row(
                "O82565",
                "Joseph Mallord William Turner",
                "Line Fishing Off Hastings",
                "ca. 1835",
                "2006AG2445"
            ),
            row(
                "O82577",
                "John Constable",
                "Golding Constable House East Bergholt",
                "ca. 1811",
                "2006AG3410"
            ),
            row(
                "O15042",
                "Dante Gabriel Rossetti",
                "Elizabeth Siddal",
                "May 1854",
                "2012FH3957"
            ),
        ]
    }

    private static func row(
        _ objectID: String,
        _ maker: String,
        _ title: String,
        _ dated: String,
        _ imageID: String
    ) -> CatalogRow {
        CatalogRow(
            objectID: objectID,
            maker: maker,
            title: title,
            imageURLString: CatalogClient.iiifThumb(imageID: imageID),
            dated: dated
        )
    }
}
