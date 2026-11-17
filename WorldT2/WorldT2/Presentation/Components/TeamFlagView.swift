import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Displays a team's flag using `ImageCacheActor` for async network loading,
/// backed by a crisp vector SwiftUI flag fallback so flags render even offline.
public struct TeamFlagView: View {
    public let team: Team
    @State private var loadedImage: Image?

    public init(team: Team) {
        self.team = team
    }

    public var body: some View {
        ZStack {
            if let loadedImage {
                loadedImage
                    .resizable()
                    .scaledToFill()
            } else {
                FallbackFlagCanvas(teamName: team.name)
            }
        }
        .frame(width: 68, height: 44)
        .clipShape(Rectangle())
        .overlay(
            Rectangle()
                .stroke(Color.black.opacity(0.15), lineWidth: 0.5)
        )
        .task(id: team.flagURL) {
            await loadRemoteFlagIfAvailable()
        }
    }

    private func loadRemoteFlagIfAvailable() async {
        guard let url = team.flagURL else { return }
        guard let data = try? await ImageCacheActor.shared.imageData(for: url) else { return }
        #if canImport(UIKit)
        if let uiImage = UIImage(data: data) {
            loadedImage = Image(uiImage: uiImage)
        }
        #elseif canImport(AppKit)
        if let nsImage = NSImage(data: data) {
            loadedImage = Image(nsImage: nsImage)
        }
        #endif
    }
}

/// Offline vector flag renderer matching the 10 ICC Cricket World Cup teams.
private struct FallbackFlagCanvas: View {
    let teamName: String

    var body: some View {
        switch teamName.lowercased() {
        case "india":
            VStack(spacing: 0) {
                Color(red: 1.0, green: 0.60, blue: 0.20)
                ZStack {
                    Color.white
                    Circle()
                        .stroke(Color(red: 0.0, green: 0.0, blue: 0.50), lineWidth: 1.5)
                        .frame(width: 10, height: 10)
                }
                Color(red: 0.07, green: 0.53, blue: 0.03)
            }
        case "pakistan":
            HStack(spacing: 0) {
                Color.white.frame(width: 16)
                ZStack {
                    Color(red: 0.0, green: 0.40, blue: 0.18)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 18, height: 18)
                    Circle()
                        .fill(Color(red: 0.0, green: 0.40, blue: 0.18))
                        .frame(width: 15, height: 15)
                        .offset(x: 3, y: -2)
                }
            }
        case "bangladesh":
            ZStack {
                Color(red: 0.0, green: 0.42, blue: 0.31)
                Circle()
                    .fill(Color(red: 0.96, green: 0.16, blue: 0.25))
                    .frame(width: 20, height: 20)
            }
        case "england":
            ZStack {
                Color.white
                Rectangle()
                    .fill(Color(red: 0.81, green: 0.08, blue: 0.17))
                    .frame(height: 8)
                Rectangle()
                    .fill(Color(red: 0.81, green: 0.08, blue: 0.17))
                    .frame(width: 8)
            }
        case "afghanistan":
            HStack(spacing: 0) {
                Color.black
                ZStack {
                    Color(red: 0.83, green: 0.07, blue: 0.09)
                    Circle()
                        .stroke(Color.white, lineWidth: 1.2)
                        .frame(width: 12, height: 12)
                }
                Color(red: 0.0, green: 0.60, blue: 0.20)
            }
        case "australia", "new zealand":
            ZStack(alignment: .topLeading) {
                Color(red: 0.0, green: 0.12, blue: 0.48)
                ZStack {
                    Color(red: 0.0, green: 0.12, blue: 0.48)
                    Rectangle().fill(Color.white).frame(height: 5)
                    Rectangle().fill(Color.white).frame(width: 5)
                    Rectangle().fill(Color.red).frame(height: 3)
                    Rectangle().fill(Color.red).frame(width: 3)
                }
                .frame(width: 30, height: 20)
            }
        case "south africa":
            VStack(spacing: 0) {
                Color(red: 0.88, green: 0.24, blue: 0.19)
                Color(red: 0.0, green: 0.47, blue: 0.29)
                Color(red: 0.0, green: 0.14, blue: 0.58)
            }
        case "sri lanka":
            HStack(spacing: 0) {
                Color(red: 0.0, green: 0.52, blue: 0.31).frame(width: 10)
                Color(red: 1.0, green: 0.47, blue: 0.0).frame(width: 10)
                Color(red: 0.55, green: 0.08, blue: 0.23)
            }
            .padding(3)
            .background(Color(red: 1.0, green: 0.75, blue: 0.0))
        default:
            ZStack {
                Color(red: 0.48, green: 0.08, blue: 0.18)
                Text(String(teamName.prefix(2)).uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            }
        }
    }
}
