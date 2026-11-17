import Foundation

/// Tracks the score, wickets, and legal deliveries for a single team's innings.
public struct InningsScore: Equatable, Sendable {
    public static let defaultMaxOvers: Int = 2
    public static let ballsPerOver: Int = 6
    public static let defaultMaxWickets: Int = 3

    public private(set) var runs: Int = 0
    public private(set) var wickets: Int = 0
    public private(set) var legalBalls: Int = 0
    public private(set) var history: [BallOutcome] = []

    public let maxOvers: Int
    public let maxWickets: Int

    public init(
        runs: Int = 0,
        wickets: Int = 0,
        legalBalls: Int = 0,
        maxOvers: Int = InningsScore.defaultMaxOvers,
        maxWickets: Int = InningsScore.defaultMaxWickets,
        history: [BallOutcome] = []
    ) {
        self.runs = runs
        self.wickets = wickets
        self.legalBalls = legalBalls
        self.maxOvers = maxOvers
        self.maxWickets = maxWickets
        self.history = history
    }

    /// Maximum legal deliveries in the innings (2 overs = 12 balls).
    public var maxLegalBalls: Int {
        maxOvers * Self.ballsPerOver
    }

    /// Whether the innings has ended due to all wickets lost (3) or all overs bowled (2.0).
    public var isInningsOver: Bool {
        wickets >= maxWickets || legalBalls >= maxLegalBalls
    }

    /// Formatted score string matching the specification: `"Score: 18/3"`.
    public var formattedScore: String {
        "Score: \(runs)/\(wickets)"
    }

    /// Formatted overs string matching the specification: `"Overs: 0.2"` or `"Overs: 2.0"`.
    public var formattedOvers: String {
        let completedOvers = legalBalls / Self.ballsPerOver
        let ballsInCurrentOver = legalBalls % Self.ballsPerOver
        return "Overs: \(completedOvers).\(ballsInCurrentOver)"
    }

    /// Applies a `BallOutcome` to the current innings.
    public mutating func record(_ outcome: BallOutcome) {
        guard !isInningsOver else { return }
        runs += outcome.runsAwarded
        if outcome.isWicket {
            wickets += 1
        }
        if outcome.isLegalDelivery {
            legalBalls += 1
        }
        history.append(outcome)
    }
}
