import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConnect {
  static final supabase = Supabase.instance.client;
  static Future uploadFile(Uint8List file, String bucket, String path) async {
    final fileBytes = file.buffer.asUint8List();
    final result = await supabase.storage
        .from(bucket)
        .uploadBinary(path, fileBytes);
    return result;
  }
}
