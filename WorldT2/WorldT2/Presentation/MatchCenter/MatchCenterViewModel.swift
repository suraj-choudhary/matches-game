import Foundation
import Observation

/// ViewModel for Screen 2 ("Match Center"), isolated to `@MainActor` and communicating
/// with the `MatchEngineUseCase` actor via Swift Structured Concurrency (`async`/`await`).
@MainActor
@Observable
public final class MatchCenterViewModel {
    public private(set) var matchState: MatchState
    public var includeExtras: Bool = true {
        didSet {
            let enabled = includeExtras
            Task {
                await matchEngine.setIncludeExtras(enabled)
            }
        }
    }

    private let matchEngine: MatchEngineUseCase

    public init(
        firstBattingTeam: Team,
        secondBattingTeam: Team,
        outcomeGenerator: any BallOutcomeGeneratorProtocol = WeightedBallOutcomeGenerator()
    ) {
        self.matchState = MatchState(
            firstBattingTeam: firstBattingTeam,
            secondBattingTeam: secondBattingTeam
        )
        self.matchEngine = MatchEngineUseCase(
            firstBattingTeam: firstBattingTeam,
            secondBattingTeam: secondBattingTeam,
            includeExtras: true,
            outcomeGenerator: outcomeGenerator
        )
    }

    /// Plays the next delivery asynchronously through the domain actor and updates UI state on `@MainActor`.
    public func playNextBall() async {
        guard !matchState.isMatchOver else { return }
        matchState = await matchEngine.playNextBall()
    }
}
