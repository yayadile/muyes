import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// UUID v4 untuk id log baru. Satu helper biar konsisten di semua form.
String newUuid() => _uuid.v4();
