import SwiftUI

/// Screen 1: Teams List ("Select Teams")
/// Displays participating Cricket World Cup teams with flags and allows selecting 2 teams to start a match.
public struct TeamSelectionView: View {
    @State private var viewModel: TeamSelectionViewModel
    @State private var isNavigatingToMatch: Bool = false
    private let makeMatchViewModel: @MainActor (Team, Team) -> MatchCenterViewModel

    public init(
        viewModel: TeamSelectionViewModel,
        makeMatchViewModel: @escaping @MainActor (Team, Team) -> MatchCenterViewModel
    ) {
        _viewModel = State(initialValue: viewModel)
        self.makeMatchViewModel = makeMatchViewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.teams) { team in
                        TeamRowView(
                            team: team,
                            isSelected: viewModel.isSelected(team)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.toggleSelection(for: team)
                        }
                        Divider()
                    }
                }
            }

            // Bottom "Start Match" CTA bar matching the specification wireframes
            Button {
                if viewModel.canStartMatch {
                    isNavigatingToMatch = true
                }
            } label: {
                Text("Start Match")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(
                        viewModel.canStartMatch
                            ? Color(red: 0.0, green: 0.56, blue: 0.0)
                            : Color.gray.opacity(0.75)
                    )
            }
            .disabled(!viewModel.canStartMatch)
        }
        .navigationTitle("Select Teams")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationDestination(isPresented: $isNavigatingToMatch) {
            if let pair = viewModel.matchPair {
                MatchCenterView(
                    viewModel: makeMatchViewModel(pair.first, pair.second)
                )
            }
        }
        .task {
            await viewModel.loadTeams()
        }
    }
}

private struct TeamRowView: View {
    let team: Team
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 22) {
            TeamFlagView(team: team)

            Text(team.name)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.primary)

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(isSelected ? Color.gray.opacity(0.55) : Color.clear)
    }
}
