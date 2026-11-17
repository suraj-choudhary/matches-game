import Foundation

/// Domain entity representing a national cricket team.
public struct Team: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let flagURL: URL?
    public let isoCode: String

    public init(id: String? = nil, name: String, flagURL: URL?, isoCode: String = "") {
        self.id = id ?? name
        self.name = name
        self.flagURL = flagURL
        self.isoCode = isoCode
    }
}
