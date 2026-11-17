import Foundation

/// Weighted random generator for cricket ball outcomes.
///
/// Implements the extension requirement:
/// - "Different outcomes can have different probabilities associated with them
///   (6 and Wickets are rarer events than a dot ball or single run)"
/// - Supports Wide and No Ball extra deliveries.
public struct WeightedBallOutcomeGenerator: BallOutcomeGeneratorProtocol, Sendable {
    public struct WeightedOutcome: Sendable {
        public let outcome: BallOutcome
        public let weight: Int

        public init(outcome: BallOutcome, weight: Int) {
            self.outcome = outcome
            self.weight = max(0, weight)
        }
    }

    /// Standard distribution where 0 and 1 are frequent, while 6, Out, Wide, and No Ball are rarer.
    public static let standardDistribution: [WeightedOutcome] = [
        WeightedOutcome(outcome: .dot, weight: 28),      // 28% - Dot ball (frequent)
        WeightedOutcome(outcome: .runs(1), weight: 30),  // 30% - Single run (frequent)
        WeightedOutcome(outcome: .runs(2), weight: 12),  // 12% - Two runs
        WeightedOutcome(outcome: .runs(3), weight: 3),   //  3% - Three runs (rare)
        WeightedOutcome(outcome: .runs(4), weight: 11),  // 11% - Four boundary
        WeightedOutcome(outcome: .runs(6), weight: 5),   //  5% - Six boundary (rarer than 0/1)
        WeightedOutcome(outcome: .wicket, weight: 6),    //  6% - Out / Wicket (rarer than 0/1)
        WeightedOutcome(outcome: .wide, weight: 3),      //  3% - Wide ball (+1 run, extra ball)
        WeightedOutcome(outcome: .noBall, weight: 2)     //  2% - No ball (+1 run, extra ball, not out)
    ]

    private let distribution: [WeightedOutcome]

    public init(distribution: [WeightedOutcome] = Self.standardDistribution) {
        self.distribution = distribution
    }

    public func nextOutcome(includeExtras: Bool) -> BallOutcome {
        let activePool = distribution.filter { item in
            guard !includeExtras else { return item.weight > 0 }
            return item.outcome.isLegalDelivery && item.weight > 0
        }

        let totalWeight = activePool.reduce(0) { $0 + $1.weight }
        guard totalWeight > 0 else { return .dot }

        let roll = Int.random(in: 1...totalWeight)
        var cumulative = 0
        for entry in activePool {
            cumulative += entry.weight
            if roll <= cumulative {
                return entry.outcome
            }
        }
        return activePool.last?.outcome ?? .dot
    }
}
