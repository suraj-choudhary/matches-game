import Foundation

/// Composition root assembling Data repositories, Domain use cases, and Presentation ViewModels.
@MainActor
public final class AppDIContainer {
    public let teamRepository: any TeamRepositoryProtocol
    public let outcomeGenerator: any BallOutcomeGeneratorProtocol

    public init(
        teamRepository: any TeamRepositoryProtocol = TeamRepository(preferLocalBundle: true),
        outcomeGenerator: any BallOutcomeGeneratorProtocol = WeightedBallOutcomeGenerator()
    ) {
        self.teamRepository = teamRepository
        self.outcomeGenerator = outcomeGenerator
    }

    public func makeTeamSelectionViewModel() -> TeamSelectionViewModel {
        let fetchTeamsUseCase = FetchTeamsUseCase(repository: teamRepository)
        return TeamSelectionViewModel(fetchTeamsUseCase: fetchTeamsUseCase)
    }

    public func makeMatchCenterViewModel(firstTeam: Team, secondTeam: Team) -> MatchCenterViewModel {
        MatchCenterViewModel(
            firstBattingTeam: firstTeam,
            secondBattingTeam: secondTeam,
            outcomeGenerator: outcomeGenerator
        )
    }
}
