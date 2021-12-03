import 'package:app_upload/common/card_picture.dart';
import 'package:app_upload/common/take_photo.dart';
import 'package:app_upload/service/dio_upload_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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
  String? imagePath = "";
  final DioUploadService _dioUploadService = DioUploadService();
  late CameraDescription _cameraDescription;
  List<String> _images = [];

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
                              onPressed: (!_images.isEmpty)
                                  ? () async {
                                      presentLoader(context,
                                          text: 'Enviando información');

                                      var responseDataDio =
                                          await _dioUploadService.uploadPhotos(
                                              _images[0], "no urgente");

                                      Navigator.of(context).pop();

                                      await presentAlert(context,
                                          title: 'Success Dio',
                                          message: responseDataDio.toString());
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
                                onPressed: (!_images.isEmpty)
                                    ? () async {
                                        presentLoader(context,
                                            text: 'Enviando información');

                                        var responseDataDio =
                                            await _dioUploadService
                                                .uploadPhotos(
                                                    _images[0], "no urgente");

                                        Navigator.of(context).pop();

                                        await presentAlert(context,
                                            title: 'Success Dio',
                                            message:
                                                responseDataDio.toString());
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
                              onPressed: (!_images.isEmpty)
                                  ? () async {
                                      presentLoader(context,
                                          text: 'Enviando información');

                                      var responseDataDio =
                                          await _dioUploadService.uploadPhotos(
                                              _images[0], "no urgente");

                                      Navigator.of(context).pop();

                                      await presentAlert(context,
                                          title: 'Success Dio',
                                          message: responseDataDio.toString());
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
                                onPressed: (!_images.isEmpty)
                                    ? () async {
                                        presentLoader(context,
                                            text: 'Enviando información');

                                        var responseDataDio =
                                            await _dioUploadService
                                                .uploadPhotos(
                                                    _images[0], "no urgente");

                                        Navigator.of(context).pop();

                                        await presentAlert(context,
                                            title: 'Success Dio',
                                            message:
                                                responseDataDio.toString());
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
