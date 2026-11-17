import Foundation

/// Abstract contract for retrieving the list of participating World Cup teams.
public protocol TeamRepositoryProtocol: Sendable {
    func fetchTeams() async throws -> [Team]
}
