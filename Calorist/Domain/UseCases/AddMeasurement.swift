import Foundation

protocol AddMeasurementUseCase {
    func execute(measurement: Measurement) async throws
}

struct AddMeasurementUseCaseImpl: AddMeasurementUseCase {
    private let measurementRepository: MeasurementRepository
    
    init(measurementRepository: MeasurementRepository) {
        self.measurementRepository = measurementRepository
    }
    
    func execute(measurement: Measurement) async throws {
        try await measurementRepository.save(measurement)
    }
}
