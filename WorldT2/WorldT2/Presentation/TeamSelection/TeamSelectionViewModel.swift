import Foundation
import Observation

/// ViewModel for Screen 1 (Select Teams), isolated to `@MainActor` and using Swift `@Observable`.
@MainActor
@Observable
public final class TeamSelectionViewModel {
    public private(set) var teams: [Team] = []
    public private(set) var selectedTeams: [Team] = []
    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String?

    private let fetchTeamsUseCase: FetchTeamsUseCase
    public let maxSelectableTeams: Int = 2

    public init(fetchTeamsUseCase: FetchTeamsUseCase) {
        self.fetchTeamsUseCase = fetchTeamsUseCase
    }

    /// True only when exactly 2 teams have been chosen.
    public var canStartMatch: Bool {
        selectedTeams.count == maxSelectableTeams
    }

    /// Returns the pair of selected teams in selection order (or randomly tossed order).
    public var matchPair: (first: Team, second: Team)? {
        guard selectedTeams.count == 2 else { return nil }
        return (selectedTeams[0], selectedTeams[1])
    }

    public func isSelected(_ team: Team) -> Bool {
        selectedTeams.contains(team)
    }

    /// Toggles selection of a team while enforcing the 2-team limit.
    public func toggleSelection(for team: Team) {
        if let existingIndex = selectedTeams.firstIndex(of: team) {
            selectedTeams.remove(at: existingIndex)
        } else if selectedTeams.count < maxSelectableTeams {
            selectedTeams.append(team)
        }
    }

    public func loadTeams() async {
        guard teams.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            teams = try await fetchTeamsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
