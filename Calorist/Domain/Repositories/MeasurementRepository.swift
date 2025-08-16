import Foundation

protocol MeasurementRepository {
    func save(_ measurement: Measurement) async throws
    func getAll(for userId: UUID) async throws -> [Measurement]
    func getLatest(for userId: UUID) async throws -> Measurement?
    func delete(_ measurement: Measurement) async throws
}
