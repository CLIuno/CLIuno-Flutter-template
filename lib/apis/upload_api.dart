import 'package:dio/dio.dart';

import 'http.dart';

/// Maps the picked file's extension to the mime the backends whitelist.
/// Without an explicit type Dio sends application/octet-stream and every
/// backend rejects the upload.
DioMediaType? _mediaTypeFor(String filePath) {
  final ext = filePath.split('.').last.toLowerCase();
  switch (ext) {
    case 'png':
      return DioMediaType('image', 'png');
    case 'jpg':
    case 'jpeg':
      return DioMediaType('image', 'jpeg');
    case 'webp':
      return DioMediaType('image', 'webp');
    case 'gif':
      return DioMediaType('image', 'gif');
    default:
      return null;
  }
}

class UploadApi {
  /// Sends the picked image as multipart/form-data; Dio writes the boundary.
  Future<Response<dynamic>> uploadImage(String filePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        contentType: _mediaTypeFor(filePath),
      ),
    });
    return http.post('/uploads/image', data: form);
  }
}

final uploadApi = UploadApi();
