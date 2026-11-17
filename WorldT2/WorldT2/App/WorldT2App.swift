import SwiftUI

@main
public struct WorldT2App: App {
    private let container = AppDIContainer()

    public init() {}

    public var body: some Scene {
        WindowGroup {
            NavigationStack {
                TeamSelectionView(
                    viewModel: container.makeTeamSelectionViewModel(),
                    makeMatchViewModel: { firstTeam, secondTeam in
                        container.makeMatchCenterViewModel(
                            firstTeam: firstTeam,
                            secondTeam: secondTeam
                        )
                    }
                )
            }
        }
    }
}
