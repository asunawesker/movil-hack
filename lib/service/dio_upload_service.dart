/*import 'dart:io';
import 'package:http/http.dart' as http;

ocr(File image, String color) async {
  //Uri
  var uri = Uri.parse('http://3.88.248.37/upload/');
  //Request fields endpoint
  var request = new http.MultipartRequest("POST", uri)
    ..fields['color'] = color
   // ..files.add(new http.MultipartFile. fromPath(
        'package',
        'build/package.tar.gz',
   //     contentType: new MediaType('application', 'x-tar'),
    ));
    //files.add(new http.MultipartFile.   fromBytes('file', await File.fromUri(uri).readAsBytes(), contentType: new MediaType('image', 'jpeg')))
  
  //Send request
  var response = await request.send();
  if (response.statusCode == 200) print('Uploaded!');
}
*/



//('http://3.88.248.37/upload/');