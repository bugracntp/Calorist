import Foundation

protocol UserRepository {
    func save(_ user: User) async throws
    func getCurrentUser() async throws -> User?
    func update(_ user: User) async throws
    func delete(_ user: User) async throws
}
