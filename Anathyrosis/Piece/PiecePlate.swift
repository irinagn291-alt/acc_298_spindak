import SwiftUI

/// Role: Piece. One clipped still. The loaded painting replaces the flat fill. No backdrop left under or over it.
struct PiecePlate: View {
    enum Prominence {
        case hero
        case row
    }

    let title: String
    let maker: String
    let url: URL?
    var prominence: Prominence = .row

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: ShaftRadius.card, style: .continuous)
        GeometryReader { geo in
            still(size: geo.size)
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
        .clipped()
        .clipShape(shape)
        .contentShape(shape)
        .accessibilityLabel("\(title), \(maker)")
        .accessibilityHidden(prominence == .hero)
    }

    @ViewBuilder
    private func still(size: CGSize) -> some View {
        if let url {
            AsyncImage(url: url, transaction: Transaction(animation: nil)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width, height: size.height, alignment: .center)
                        .clipped()
                default:
                    ShaftInk.surface
                        .frame(width: size.width, height: size.height)
                }
            }
        } else {
            ShaftInk.surface
                .frame(width: size.width, height: size.height)
        }
    }
}
