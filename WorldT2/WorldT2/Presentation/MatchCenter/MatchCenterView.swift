import SwiftUI

/// Screen 2: Match Center
/// Displays both teams' live scores/overs, the latest ball outcome or match result in the center,
/// and the "Play Next Ball" / "Match Over" action button at the bottom.
public struct MatchCenterView: View {
    @State private var viewModel: MatchCenterViewModel

    public init(viewModel: MatchCenterViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top Scoreboard Section
            VStack(alignment: .leading, spacing: 28) {
                // First Batting Team Block
                TeamScoreBlockView(
                    headerText: viewModel.matchState.firstTeamHeader,
                    scoreText: viewModel.matchState.firstInnings.formattedScore,
                    oversText: viewModel.matchState.firstInnings.formattedOvers
                )

                // Second Batting Team Block
                TeamScoreBlockView(
                    headerText: viewModel.matchState.secondTeamHeader,
                    scoreText: viewModel.matchState.secondTeamScoreText,
                    oversText: viewModel.matchState.secondTeamOversText
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 28)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Center Outcome Display Canvas
            ZStack {
                Color.gray.opacity(0.38)

                Text(viewModel.matchState.centerBannerText)
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.2), value: viewModel.matchState.centerBannerText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom Action Button ("Play Next Ball" / "Match Over")
            Button {
                Task {
                    await viewModel.playNextBall()
                }
            } label: {
                Text(viewModel.matchState.actionButtonTitle)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color(red: 0.0, green: 0.56, blue: 0.0))
            }
            .disabled(viewModel.matchState.isMatchOver)
        }
        .navigationTitle("Match Center")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Toggle("Extras (Wide & No Ball)", isOn: $viewModel.includeExtras)
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
    }
}

private struct TeamScoreBlockView: View {
    let headerText: String
    let scoreText: String
    let oversText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(headerText)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)

            HStack {
                Text(scoreText)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(.primary)

                Spacer()

                Text(oversText)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(.primary)
            }
        }
    }
}
