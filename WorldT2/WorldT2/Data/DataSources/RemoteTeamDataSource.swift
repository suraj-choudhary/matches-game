import Foundation

/// Optional remote data source for fetching teams from `https://jsonkeeper.com/b/ZPFG` using Swift Concurrency.
public struct RemoteTeamDataSource: Sendable {
    private let endpointURL: URL

    public init(endpointURL: URL = URL(string: "https://jsonkeeper.com/b/ZPFG")!) {
        self.endpointURL = endpointURL
    }

    public func fetchTeams() async throws -> [TeamDTO] {
        let (data, response) = try await URLSession.shared.data(from: endpointURL)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([TeamDTO].self, from: data)
    }
}
