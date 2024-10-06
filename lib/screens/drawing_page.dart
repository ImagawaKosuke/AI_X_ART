import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'dart:io'; // File クラスを使うためのインポート

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<Line> _lines = []; // 描画する線のリスト
  Color _selectedColor = Colors.black; // 選択された色
  double _strokeWidth = 5.0; // 線の太さ
  List<Offset?> _currentLinePoints = []; // 現在の線の点
  GlobalKey _globalKey = GlobalKey(); // RepaintBoundary用のキー

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEFFD),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("お絵描き画面"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // 描画エリア
                Expanded(
                  child: Stack(
                    children: [
                      // RepaintBoundaryを追加
                      RepaintBoundary(
                        key: _globalKey, // スクリーンショットを取るためのキー
                        child: Container(
                          color: Colors.white,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                final RenderBox renderBox =
                                    context.findRenderObject() as RenderBox;
                                final localPosition = renderBox
                                    .globalToLocal(details.globalPosition);

                                if (localPosition.dx >= 0 &&
                                    localPosition.dx <=
                                        renderBox.size.width - 148 &&
                                    localPosition.dy >= 0 &&
                                    localPosition.dy <=
                                        renderBox.size.height - 198) {
                                  _currentLinePoints.add(localPosition);
                                }
                              });
                            },
                            onPanEnd: (details) {
                              setState(() {
                                _lines.add(
                                    Line(_currentLinePoints, _selectedColor));
                                _currentLinePoints = [];
                              });
                            },
                            child: CustomPaint(
                              size: Size(MediaQuery.of(context).size.width,
                                  MediaQuery.of(context).size.height * 0.5),
                              painter: DrawingPainter(_lines, _strokeWidth),
                            ),
                          ),
                        ),
                      ),
                      if (_currentLinePoints.isNotEmpty)
                        CustomPaint(
                          painter: DrawingPainter(
                              [Line(_currentLinePoints, _selectedColor)],
                              _strokeWidth),
                        ),
                    ],
                  ),
                ),
                // 色選択用のウィジェット
                _buildColorPicker(),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/generate');
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 67, 195),
                ),
                child: Text(
                  '戻る',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 10), // スペースを追加
              TextButton(
                onPressed: () async {
                  await _takeScreenshot();
                  Navigator.pushNamed(context, '/generate');
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 67, 195),
                ),
                child: Text(
                  'アートを生成する',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// スクリーンショットを取得するメソッド
  Future<void> _takeScreenshot() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // ユーザーのドキュメントフォルダを取得する
        final String path =
            'C:/Users/kosuk/AI_Art/assets/screenshot.png'; // 保存先

        // ファイルを保存
        final file = File(path);
        await file.writeAsBytes(pngBytes);

        // スクリーンショットの保存が成功したことを通知
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('スクリーンショットが保存されました: $path'),
        ));
      }
    } catch (e) {
      print("Error taking screenshot: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('スクリーンショットの取得中にエラーが発生しました'),
      ));
    }
  }

  // 色を選択するためのウィジェット
  Widget _buildColorPicker() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Colors.red),
              _colorCircle(Colors.orange),
              _colorCircle(Colors.yellow),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Colors.lightGreen),
              _colorCircle(Colors.green),
              _colorCircle(Colors.lightBlue),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Colors.blue),
              _colorCircle(Colors.purple),
              _colorCircle(Colors.pink),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Colors.white),
              _colorCircle(Colors.black),
              _colorCircle(Colors.brown),
            ],
          ),
        ],
      ),
    );
  }

  // 色選択用のボタン
  Widget _colorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color; // 色を更新
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            width: _selectedColor == color ? 3 : 1,
            color: _selectedColor == color ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }
}

// 線を表現するクラス
class Line {
  List<Offset?> points;
  Color color;

  Line(this.points, this.color);
}

// カスタムペインタークラス
class DrawingPainter extends CustomPainter {
  final List<Line> lines;
  final double strokeWidth;

  DrawingPainter(this.lines, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    for (Line line in lines) {
      Paint paint = Paint()
        ..color = line.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      for (int i = 0; i < line.points.length - 1; i++) {
        if (line.points[i] != null && line.points[i + 1] != null) {
          canvas.drawLine(line.points[i]!, line.points[i + 1]!, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
