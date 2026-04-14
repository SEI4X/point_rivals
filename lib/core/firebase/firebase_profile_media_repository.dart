import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:point_rivals/core/firebase/firebase_contracts.dart';

class FirebaseProfileMediaRepository implements ProfileMediaRepository {
  FirebaseProfileMediaRepository({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileName,
    required String? contentType,
  }) async {
    final extension = _extensionFor(contentType, fileName);
    final reference = _storage.ref('avatars/$userId/avatar.$extension');
    final task = await reference.putData(
      bytes,
      SettableMetadata(contentType: contentType ?? 'image/jpeg'),
    );

    return task.ref.getDownloadURL();
  }

  String _extensionFor(String? mimeType, String name) {
    if (mimeType == 'image/png') {
      return 'png';
    }

    if (mimeType == 'image/webp') {
      return 'webp';
    }

    final lowerName = name.toLowerCase();
    if (lowerName.endsWith('.png')) {
      return 'png';
    }

    if (lowerName.endsWith('.webp')) {
      return 'webp';
    }

    return 'jpg';
  }
}
