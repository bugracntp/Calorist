import Foundation
import CoreData

struct MeasurementMapper {
    static func toEntity(from dto: MeasurementDTO) -> Measurement? {
        return dto.toMeasurement()
    }
    
    static func toDTO(from entity: Measurement) -> MeasurementDTO {
        return MeasurementDTO(from: entity)
    }
}
