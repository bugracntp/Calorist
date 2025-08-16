import Foundation
import CoreData

// Import Measurement entity from Domain layer
// Note: In a real project, you might need to adjust the import path
struct MeasurementDTO: Codable {
    let id: String
    let userId: String
    let height: Double
    let weight: Double
    let neck: Double
    let waist: Double
    let hip: Double
    let arm: Double
    let date: Date
    
    init(from measurement: Measurement) {
        self.id = measurement.id.uuidString
        self.userId = measurement.userId.uuidString
        self.height = measurement.height
        self.weight = measurement.weight
        self.neck = measurement.neck
        self.waist = measurement.waist
        self.hip = measurement.hip
        self.arm = measurement.arm
        self.date = measurement.date
    }
    
    init(id: String, userId: String, height: Double, weight: Double, neck: Double, waist: Double, hip: Double, arm: Double, date: Date) {
        self.id = id
        self.userId = userId
        self.height = height
        self.weight = weight
        self.neck = neck
        self.waist = waist
        self.hip = hip
        self.arm = arm
        self.date = date
    }
    
        func toMeasurement() -> Measurement? {
        guard let id = UUID(uuidString: id),
              let userId = UUID(uuidString: userId) else {
            print("DEBUG: MeasurementDTO.toMeasurement() - Parsing hatası: id=\(id), userId=\(userId)")
            return nil
        }

        return Measurement(
            id: id,
            userId: userId,
            height: height,
            weight: weight,
            neck: neck,
            waist: waist,
            hip: hip,
            arm: arm,
            date: date
        )
    }
}
