import Foundation
import Combine
#if canImport(Supabase)
import Supabase
#endif
import SwiftUI

#if canImport(Supabase)
class StorageService {
    static let shared = StorageService()
    private let client = SupabaseManager.shared.client
    
    // Upload a file to a specific bucket
    func uploadFile(bucket: String, path: String, data: Data) async throws -> URL? {
        let options = FileOptions(cacheControl: "3600", contentType: "application/octet-stream", upsert: true)
        _ = try await client.storage
            .from(bucket)
            .upload(path: path, file: data, options: options)
        
        return getPublicURL(bucket: bucket, path: path)
    }
    
    // Get public URL for a file
    func getPublicURL(bucket: String, path: String) -> URL? {
        // Construct URL manually to avoid SDK version mismatches
        return SupabaseConfig.supabaseURL
            .appendingPathComponent("storage/v1/object/public")
            .appendingPathComponent(bucket)
            .appendingPathComponent(path)
    }
    
    // Delete a file
    func deleteFile(bucket: String, path: String) async throws {
        _ = try await client.storage
            .from(bucket)
            .remove(paths: [path])
    }
}
#endif
#if !canImport(Supabase)
class StorageService {
    static let shared = StorageService()
    private init() {}
    func uploadFile(bucket: String, path: String, data: Data) async throws -> URL? { return nil }
    func getPublicURL(bucket: String, path: String) -> URL? { return nil }
    func deleteFile(bucket: String, path: String) async throws { }
}
#endif

