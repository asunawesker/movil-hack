
import 'package:dio/dio.dart';

class DioUploadService {
  
  Future<dynamic> uploadPhotos(String path, String code) async {
    MultipartFile photo = await MultipartFile.fromFile(path);
    
    var formData = FormData.fromMap({
      'files': photo,
      'code': code,
    });

    var response = await Dio().post('http://10.0.0.101:5000/profile/upload-mutiple', data: formData);
    print('\n\n');
    print('RESPONSE WITH DIO');
    print(response.data);
    print('\n\n');
    return response.data;
  }

}