import 'package:app_upload/common/card_picture.dart';
import 'package:app_upload/common/take_photo.dart';
import 'package:app_upload/service/dio_upload_service.dart';
import 'package:app_upload/service/http_upload_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
  final HttpUploadService _httpUploadService = HttpUploadService();
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
                  // style: greenText,
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
          title: Text('URGENCIAS'),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.local_hospital,
                  color: Colors.white,
                ),
                onPressed: null)
          ],
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: Column(children: [
            Text('Toma una foto a la credencial de elector',
                style: TextStyle(fontSize: 17.0)),
            SizedBox(
              height: 20,
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                height: 400,
                child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                          CardPicture(
                            onTap: () async {
                              final String? imagePath =
                                  await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (_) => TakePhoto(
                                                camera: _cameraDescription,
                                              )));

                              print('imagepath: $imagePath');
                              if (imagePath != null) {
                                setState(() {
                                  _images.add(imagePath);
                                });
                              }
                            },
                          ),
                          // CardPicture(),
                          // CardPicture(),
                        ] +
                        _images
                            .map((String path) => CardPicture(
                                  imagePath: path,
                                ))
                            .toList())),
            const SizedBox(height: 30),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                          decoration: BoxDecoration(
                              color: Color(0xFF5675a7),
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
                              'ELIMINAR IMAGEN',
                              style: TextStyle(
                                  color: Colors.white,
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
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(
                              left: 45, right: 45, bottom: 25, top: 25),
                          primary: Colors.white,
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        onPressed: () {},
                        child: const Text('Urgente'),
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
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.only(
                                left: 28, right: 27, bottom: 25, top: 25),
                            primary: Colors.white,
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          onPressed: () {},
                          child: const Text('No Urgente'),
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
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(
                              left: 55, right: 55, bottom: 25, top: 25),
                          primary: Colors.white,
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        onPressed: () {},
                        child: const Text('Grave'),
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
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.only(
                                left: 50, right: 50, bottom: 25, top: 25),
                            primary: Colors.white,
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          onPressed: () {},
                          child: const Text('Critico'),
                        ),
                      ],
                    ),
                  )
                ]),
          ]),
        )));
  }
}
