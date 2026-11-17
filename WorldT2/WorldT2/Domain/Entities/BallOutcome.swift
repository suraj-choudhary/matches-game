import Foundation

/// Represents every possible outcome on a single delivery in World T2,
/// including standard outcomes (0, 1, 2, 3, 4, 6, Out) and extensions (Wide, No Ball).
public enum BallOutcome: Equatable, Hashable, Sendable {
    case dot
    case runs(Int)
    case wicket
    case wide
    case noBall

    /// Total runs added to the batting team's score on this delivery.
    public var runsAwarded: Int {
        switch self {
        case .dot, .wicket:
            return 0
        case .runs(let count):
            return count
        case .wide, .noBall:
            return 1
        }
    }

    /// Whether this delivery counts as a legal ball toward the 6-ball over.
    /// Wide and No Ball award an extra delivery (0 legal balls consumed).
    public var isLegalDelivery: Bool {
        switch self {
        case .dot, .runs, .wicket:
            return true
        case .wide, .noBall:
            return false
        }
    }

    /// Whether a wicket fell on this delivery.
    /// Note: Under standard cricket rules & the No Ball extension, a batter cannot get Out on a No Ball.
    public var isWicket: Bool {
        if case .wicket = self {
            return true
        }
        return false
    }

    /// Display text rendered in the center of the Match Center screen.
    public var displayText: String {
        switch self {
        case .dot:
            return "0"
        case .runs(let count):
            return "\(count)"
        case .wicket:
            return "Out"
        case .wide:
            return "Wide"
        case .noBall:
            return "No Ball"
        }
    }
}
