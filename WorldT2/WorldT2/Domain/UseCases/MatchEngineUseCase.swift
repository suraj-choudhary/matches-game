import Foundation

/// Actor-isolated Use Case that encapsulates the 2-over cricket rules and state transitions.
///
/// Rules enforced:
/// 1. Each team gets up to 2 overs (12 legal balls) or 3 wickets, whichever comes first.
/// 2. Wide and No Ball award 1 extra run and 1 extra ball (legal ball count does not advance; No Ball cannot be Out).
/// 3. If the team batting 2nd outscores the 1st team before 2 overs or 3 wickets, the match ends immediately.
/// 4. At the end of the 2nd innings, the team with more runs wins (or Match Tied if scores are equal).
public actor MatchEngineUseCase {
    private let outcomeGenerator: any BallOutcomeGeneratorProtocol
    private var state: MatchState
    public private(set) var includeExtras: Bool

    public init(
        firstBattingTeam: Team,
        secondBattingTeam: Team,
        includeExtras: Bool = true,
        outcomeGenerator: any BallOutcomeGeneratorProtocol
    ) {
        self.outcomeGenerator = outcomeGenerator
        self.includeExtras = includeExtras
        self.state = MatchState(
            firstBattingTeam: firstBattingTeam,
            secondBattingTeam: secondBattingTeam
        )
    }

    /// Returns the current immutable snapshot of the match.
    public func currentState() -> MatchState {
        state
    }

    /// Updates whether Wide and No Ball extension outcomes are enabled.
    public func setIncludeExtras(_ enabled: Bool) {
        includeExtras = enabled
    }

    /// Simulates the next ball and advances the match state according to standard cricket rules.
    @discardableResult
    public func playNextBall() -> MatchState {
        guard !state.isMatchOver else { return state }

        let outcome = outcomeGenerator.nextOutcome(includeExtras: includeExtras)
        Self.apply(outcome: outcome, to: &state)
        return state
    }

    /// Pure deterministic transition function (also directly testable with fixed outcomes).
    public static func apply(outcome: BallOutcome, to state: inout MatchState) {
        switch state.phase {
        case .firstInnings:
            state.firstInnings.record(outcome)
            state.centerBannerText = outcome.displayText

            // Check if 1st innings has concluded (3 wickets lost or 2.0 overs completed)
            if state.firstInnings.isInningsOver {
                state.phase = .secondInnings
            }

        case .secondInnings:
            state.secondInnings.record(outcome)
            state.centerBannerText = outcome.displayText

            // Rule: If the team batting 2nd outscores the 1st team before 2 overs, the match ends immediately
            if state.secondInnings.runs > state.firstInnings.runs {
                let result = MatchResult.won(winner: state.secondBattingTeam)
                state.phase = .completed(result)
                state.centerBannerText = result.displayText
                return
            }

            // Check if 2nd innings has concluded (3 wickets lost or 2.0 overs completed)
            if state.secondInnings.isInningsOver {
                let result: MatchResult
                if state.secondInnings.runs > state.firstInnings.runs {
                    result = .won(winner: state.secondBattingTeam)
                } else if state.firstInnings.runs > state.secondInnings.runs {
                    result = .won(winner: state.firstBattingTeam)
                } else {
                    result = .tied
                }
                state.phase = .completed(result)
                state.centerBannerText = result.displayText
            }

        case .completed:
            break
        }
    }
}
