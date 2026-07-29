import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(url: url, publishableKey: anonKey);
  }

  // ── Prompts CRUD ──────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchPrompts() async {
    final data = await client
        .from('prompts')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> createPrompt(Map<String, dynamic> prompt) async {
    await client.from('prompts').insert(prompt);
  }

  static Future<void> updatePrompt(String id, Map<String, dynamic> fields) async {
    await client.from('prompts').update(fields).eq('id', id);
  }

  static Future<void> deletePrompt(String id) async {
    await client.from('prompts').delete().eq('id', id);
  }
}
