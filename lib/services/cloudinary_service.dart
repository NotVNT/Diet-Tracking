import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/cloudinary_config.dart';

/// Handles image uploads to Cloudinary.
class CloudinaryService {
  final String cloudName;
  final String uploadPreset;
  final String? apiKey;

  CloudinaryService({
    required this.cloudName,
    required this.uploadPreset,
    this.apiKey,
  });

  factory CloudinaryService.fromConfig() {
    if (CloudinaryConfig.cloudName.isEmpty ||
        CloudinaryConfig.uploadPreset.isEmpty) {
      throw StateError(
        'Cloudinary is not configured. Update lib/config/cloudinary_config.dart',
      );
    }

    return CloudinaryService(
      cloudName: CloudinaryConfig.cloudName,
      uploadPreset: CloudinaryConfig.uploadPreset,
      apiKey: CloudinaryConfig.apiKey.isEmpty
          ? null
          : CloudinaryConfig.apiKey,
    );
  }

  Future<String> uploadImage(File imageFile) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset;

    if (apiKey != null) {
      request.fields['api_key'] = apiKey!;
    }

    if (CloudinaryConfig.folder.isNotEmpty) {
      request.fields['folder'] = CloudinaryConfig.folder;
    }

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception(
        'Cloudinary upload failed (${response.statusCode}): $body',
      );
    }

    final Map<String, dynamic> payload =
        jsonDecode(body) as Map<String, dynamic>;
    final String? secureUrl = payload['secure_url'] as String?;

    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary response missing secure_url.');
    }

    return secureUrl;
  }
}
