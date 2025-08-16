import Foundation

protocol CalculateBodyMetricsUseCase {
    func execute(measurement: Measurement, user: User) -> BodyMetrics
}

struct CalculateBodyMetricsUseCaseImpl: CalculateBodyMetricsUseCase {
    func execute(measurement: Measurement, user: User) -> BodyMetrics {
        return BodyMetrics(measurement: measurement, user: user)
    }
}
