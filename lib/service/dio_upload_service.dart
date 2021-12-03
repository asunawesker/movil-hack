import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpUploadService {
  Future<String> uploadPhotos(String path, String color) async {
    String result = '';
    Uri uri = Uri.parse('http://3.88.248.37/upload/');
    http.MultipartRequest request = http.MultipartRequest('POST', uri);
    request.fields['color'] = color;
    request.files.add(await http.MultipartFile.fromPath('files', path));

    request.send().then((response) {
      if (response.statusCode == 200) {
        result = "Información enviada";
      } else {
        result = "Información no válida, vuelva a tomar la fotografía";
      }
    });
    return result;
  }
}
