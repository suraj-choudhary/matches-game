import Foundation

/// Outcome of a completed match.
public enum MatchResult: Equatable, Sendable {
    case won(winner: Team)
    case tied

    public var displayText: String {
        switch self {
        case .won(let winner):
            return "\(winner.name) Wins"
        case .tied:
            return "Match Tied"
        }
    }
}

/// Current phase of the 2-over match.
public enum MatchPhase: Equatable, Sendable {
    case firstInnings
    case secondInnings
    case completed(MatchResult)
}

/// Complete immutable value snapshot of the Match Center state.
public struct MatchState: Equatable, Sendable {
    public let firstBattingTeam: Team
    public let secondBattingTeam: Team
    public var firstInnings: InningsScore
    public var secondInnings: InningsScore
    public var phase: MatchPhase
    public var centerBannerText: String

    public init(
        firstBattingTeam: Team,
        secondBattingTeam: Team,
        maxOvers: Int = InningsScore.defaultMaxOvers,
        maxWickets: Int = InningsScore.defaultMaxWickets
    ) {
        self.firstBattingTeam = firstBattingTeam
        self.secondBattingTeam = secondBattingTeam
        self.firstInnings = InningsScore(maxOvers: maxOvers, maxWickets: maxWickets)
        self.secondInnings = InningsScore(maxOvers: maxOvers, maxWickets: maxWickets)
        self.phase = .firstInnings
        self.centerBannerText = ""
    }

    public var isMatchOver: Bool {
        if case .completed = phase {
            return true
        }
        return false
    }

    /// Title for the first team row, e.g., `"Pakistan (Batting)"` or `"Pakistan (Bowling)"`.
    public var firstTeamHeader: String {
        switch phase {
        case .firstInnings:
            return "\(firstBattingTeam.name) (Batting)"
        case .secondInnings, .completed:
            return "\(firstBattingTeam.name) (Bowling)"
        }
    }

    /// Title for the second team row, e.g., `"India (Bowling)"` or `"India (Batting)"`.
    public var secondTeamHeader: String {
        switch phase {
        case .firstInnings:
            return "\(secondBattingTeam.name) (Bowling)"
        case .secondInnings, .completed:
            return "\(secondBattingTeam.name) (Batting)"
        }
    }

    /// Whether the second team has started batting.
    public var hasSecondTeamStartedBatting: Bool {
        switch phase {
        case .firstInnings:
            return false
        case .secondInnings, .completed:
            return true
        }
    }

    /// Left subtitle for the second team (`"yet to bat"` during 1st innings, `"Score: X/Y"` afterward).
    public var secondTeamScoreText: String {
        hasSecondTeamStartedBatting ? secondInnings.formattedScore : "yet to bat"
    }

    /// Right subtitle for the second team (`"yet to bat"` during 1st innings, `"Overs: X.Y"` afterward).
    public var secondTeamOversText: String {
        hasSecondTeamStartedBatting ? secondInnings.formattedOvers : "yet to bat"
    }

    /// Bottom action button title (`"Play Next Ball"` while active, `"Match Over"` when finished).
    public var actionButtonTitle: String {
        isMatchOver ? "Match Over" : "Play Next Ball"
    }
}
