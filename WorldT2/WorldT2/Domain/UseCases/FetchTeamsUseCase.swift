import Foundation

/// Use case responsible for loading and sorting participating teams.
public struct FetchTeamsUseCase: Sendable {
    private let repository: any TeamRepositoryProtocol

    public init(repository: any TeamRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [Team] {
        let teams = try await repository.fetchTeams()
        return teams.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
