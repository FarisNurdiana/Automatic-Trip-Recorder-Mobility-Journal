import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads and validates environment configuration from the bundled `.env`
/// asset. The app must keep working (local mode) when Supabase is not
/// configured, so validation reports problems instead of throwing.
class Env {
  Env._({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.problems,
  });

  final String supabaseUrl;
  final String supabaseAnonKey;

  /// Human-readable configuration problems; empty when the env is valid.
  final List<String> problems;

  bool get isSupabaseConfigured => problems.isEmpty;

  static Future<Env> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // Missing .env file: run in local mode.
      debugPrint('Env: .env not loaded ($e); running without Supabase.');
    }
    final url = dotenv.maybeGet('SUPABASE_URL')?.trim() ?? '';
    final key = dotenv.maybeGet('SUPABASE_ANON_KEY')?.trim() ?? '';

    final problems = <String>[];
    if (url.isEmpty) {
      problems.add('SUPABASE_URL kosong. Isi di file .env.');
    } else if (Uri.tryParse(url)?.hasScheme != true ||
        !url.startsWith('https://')) {
      problems.add('SUPABASE_URL harus berupa URL https yang valid.');
    }
    if (key.isEmpty) {
      problems.add('SUPABASE_ANON_KEY kosong. Isi di file .env.');
    } else if (key.length < 20) {
      problems.add('SUPABASE_ANON_KEY terlihat tidak valid (terlalu pendek).');
    }
    if (key.contains('service_role')) {
      problems.add(
        'Jangan pernah memakai service role key di aplikasi. '
        'Gunakan anon key.',
      );
    }

    return Env._(supabaseUrl: url, supabaseAnonKey: key, problems: problems);
  }
}
