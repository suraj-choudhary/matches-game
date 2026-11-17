import Foundation

/// Abstract contract for generating random ball outcomes based on probability weights.
public protocol BallOutcomeGeneratorProtocol: Sendable {
    func nextOutcome(includeExtras: Bool) -> BallOutcome
}
