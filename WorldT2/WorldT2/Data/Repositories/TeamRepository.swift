import Foundation

/// Concrete repository that provides `Team` entities from bundled JSON (and optional remote fallback).
public struct TeamRepository: TeamRepositoryProtocol, Sendable {
    private let localDataSource: LocalTeamDataSource
    private let remoteDataSource: RemoteTeamDataSource
    private let preferLocalBundle: Bool

    public init(
        localDataSource: LocalTeamDataSource = LocalTeamDataSource(),
        remoteDataSource: RemoteTeamDataSource = RemoteTeamDataSource(),
        preferLocalBundle: Bool = true
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
        self.preferLocalBundle = preferLocalBundle
    }

    public func fetchTeams() async throws -> [Team] {
        if preferLocalBundle {
            let localDTOs = try await localDataSource.loadTeams()
            return localDTOs.map { $0.toDomain() }
        }

        do {
            let remoteDTOs = try await remoteDataSource.fetchTeams()
            return remoteDTOs.map { $0.toDomain() }
        } catch {
            let fallbackDTOs = try await localDataSource.loadTeams()
            return fallbackDTOs.map { $0.toDomain() }
        }
    }
}
