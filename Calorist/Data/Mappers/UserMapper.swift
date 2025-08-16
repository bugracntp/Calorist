import Foundation
import CoreData

struct UserMapper {
    static func toEntity(from dto: UserDTO) -> User? {
        return dto.toUser()
    }
    
    static func toDTO(from entity: User) -> UserDTO {
        return UserDTO(from: entity)
    }
}
