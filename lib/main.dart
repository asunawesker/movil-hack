import 'dart:io';

import 'package:app_upload/common/card_picture.dart';
import 'package:app_upload/common/take_photo.dart';
import 'package:app_upload/service/dio_upload_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'dart:typed_data';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Urgencias',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Urgencias covadonga'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isButtonActive = false;
  //final DioUploadServiceservice = DioUploadService();
  late CameraDescription _cameraDescription;
  List<String> _images = [];

  get dio => null;

  get response => null;
  late Uint8List bytes;
  set response(response) {}

  Future<String> uploadPhotos(String imagePath, String color) async {
    print(imagePath);
    Uri uri = Uri.parse('http://3.86.209.36:5000/upload');
    http.MultipartRequest request = http.MultipartRequest('POST', uri);
    Map<String, String> headers = {"Content-type": "multipart/form-data"};
    request.files.add(http.MultipartFile('file',
        File(imagePath).readAsBytes().asStream(), File(imagePath).lengthSync(),
        filename: imagePath.split("/").last));
    request.headers.addAll(headers);
    request.fields.addAll({"color": color});
    http.StreamedResponse response = await request.send();
    var responseBytes = await response.stream.toBytes();
    var responseString = utf8.decode(responseBytes);
    print(responseString);
    return responseString;
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then((cameras) {
      final camera = cameras
          .where((camera) => camera.lensDirection == CameraLensDirection.back)
          .toList()
          .first;
      setState(() {
        _cameraDescription = camera;
      });
    }).catchError((err) {
      print(err);
    });
  }

  Future<void> presentAlert(BuildContext context,
      {String title = '', String message = '', Function()? ok}) {
    return showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: Text('$title'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Text('$message'),
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                ),
                onPressed: ok != null ? ok : Navigator.of(context).pop,
              ),
            ],
          );
        });
  }

  void presentLoader(BuildContext context,
      {String text = 'Aguarde...',
      bool barrierDismissible = false,
      bool willPop = true}) {
    showDialog(
        barrierDismissible: barrierDismissible,
        context: context,
        builder: (c) {
          return WillPopScope(
            onWillPop: () async {
              return willPop;
            },
            child: AlertDialog(
              content: Container(
                child: Row(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(
                      width: 20.0,
                    ),
                    Text(
                      text,
                      style: TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  postData() async {
    var response = await http.post(
        Uri.parse("https://jsonplaceholder.typeicode.com/posts"),
        body: {"id": "1", "name": "Irais"});

    print(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF062f75),
          title: Text('Halcones UV'),
          leading: Icon(
            Icons.local_hospital,
            color: Colors.white,
            size: 24.0,
          ),
          titleSpacing: 0,
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Column(children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      height: 400,
                      child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: [
                                CardPicture(
                                  onTap: () async {
                                    final String? imagePath =
                                        await Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) => TakePhoto(
                                                    camera:
                                                        _cameraDescription)));
                                    print('imagepath: $imagePath');
                                    if (imagePath != null) {
                                      setState(() {
                                        _images.add(imagePath);
                                      });
                                    }
                                  },
                                ),
                              ] +
                              _images
                                  .map((String path) => CardPicture(
                                        imagePath: path,
                                      ))
                                  .toList())),
                  const SizedBox(height: 20),
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white30,
                                    border:
                                        Border.all(color: Color(0xFF062f75)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3.0))),
                                child: RawMaterialButton(
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  onPressed: () {
                                    setState(() {
                                      _images.removeLast();
                                    });
                                  },
                                  child: Center(
                                      child: Text(
                                    'Eliminar imagen',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.bold),
                                  )),
                                )),
                          )
                        ],
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Stack(children: <Widget>[
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Color(0xFFC62828),
                                      Color(0xFFD32F2F),
                                      Color(0xFFE53935),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              child: const Text(''),
                              onPressed: (_images.isNotEmpty)
                                  ? () async {
                                      uploadPhotos(_images[0], "1");
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.only(
                                    left: 70, right: 70, bottom: 25, top: 25),
                              ),
                            ),
                          ]),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        Color(0xFF2E7D32),
                                        Color(0xFF388E3C),
                                        Color(0xFF43A047),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                child: const Text(''),
                                onPressed: (_images.isNotEmpty)
                                    ? () async {
                                        uploadPhotos(_images[0], "3");
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.only(
                                      left: 70, right: 70, bottom: 25, top: 25),
                                ),
                              ),
                            ],
                          ),
                        )
                      ]),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Stack(children: <Widget>[
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Color(0xFFF57F17),
                                      Color(0xFFF57F17),
                                      Color(0xFFF57F17),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              child: const Text(''),
                              onPressed: (_images.isNotEmpty)
                                  ? () async {
                                      uploadPhotos(_images[0], "2");
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.only(
                                    left: 70, right: 70, bottom: 25, top: 25),
                              ),
                            ),
                          ]),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        Color(0xFF000000),
                                        Color(0xF0000000),
                                        Color(0xF0000000),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                child: const Text(''),
                                onPressed: (_images.isNotEmpty)
                                    ? () async {
                                        uploadPhotos(_images[0], "4");
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.only(
                                      left: 70, right: 70, bottom: 25, top: 25),
                                ),
                              ),
                            ],
                          ),
                        )
                      ])
                ]))));
  }
}

class FormData {
  FormData.from(Map<String, dynamic> map);
}
