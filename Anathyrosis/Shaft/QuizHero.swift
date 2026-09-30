import SwiftUI

/// Role: Shaft. One clipped artwork cell. Caption stays under the tile. Soft shadow lives only here.
struct QuizHero: View {
    let piece: Piece?
    let rebuilt: Bool

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: ShaftRadius.card, style: .continuous)
        PiecePlate(
            title: piece?.title ?? "Painting",
            maker: piece?.maker ?? "",
            url: piece?.imageURL,
            prominence: .hero
        )
        .clipped()
        .clipShape(shape)
        .shadow(
            color: ShaftLift.shade,
            radius: ShaftLift.shadeRadius,
            y: ShaftLift.shadeY
        )
        .contentShape(shape)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(heroLabel)
    }

    private var heroLabel: String {
        guard let piece else { return "Painting" }
        if rebuilt {
            return "\(piece.title), \(piece.maker)"
        }
        return piece.title
    }
}
