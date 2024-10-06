import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  _GeneratePageState createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  @override
  File? image;
  // 画像をギャラリーから選ぶ関数
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      // 画像がnullの場合戻る
      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEFFD),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("AI生成画面"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1つ目の画像
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("お絵描きした絵"),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                            // 画面のサイズに基づいて縮小したサイズで表示
                            height: 150,
                            width: 200,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Image.asset('assets/style.jpg'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // 2つ目の画像
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("選んだ写真"),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                            // 画面のサイズに基づいて縮小したサイズで表示
                            height: 150,
                            width: 150,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Image.asset('assets/content.jpg'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/drawing');
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 255, 67, 195),
                              ),
                              child: Text(
                                'お絵描きをする',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                pickImage();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 255, 67, 195),
                              ),
                              child: Text(
                                '写真を選ぶ',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ])
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 67, 195),
                      ),
                      child: Text(
                        '戻る',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/output');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 67, 195),
                      ),
                      child: Text(
                        'アートを生成する',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }
}
