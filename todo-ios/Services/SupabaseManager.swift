// Requires Supabase Swift package: https://github.com/supabase-community/supabase-swift
import Foundation
import Combine
#if canImport(Supabase)
import Supabase
#endif

#if canImport(Supabase)
class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: SupabaseConfig.supabaseURL,
            supabaseKey: SupabaseConfig.supabaseAnonKey
        )
    }
}
#endif
#if !canImport(Supabase)
class SupabaseManager {
    static let shared = SupabaseManager()
    private init() { }
}
#endif

