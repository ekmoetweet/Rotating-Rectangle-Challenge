import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotating_rectangle/globals.dart' as App;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TutorialKart',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController valueAController = TextEditingController(text: "300");
  final TextEditingController valueBController = TextEditingController(text: "200");

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width - 100;
    double screenHeight = MediaQuery.of(context).size.height / 2;
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter - www.tutorialkart.com'),
      ),
      body: ListView(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            keyboardType: TextInputType.number,
            controller: valueAController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter Width',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            keyboardType: TextInputType.number,
            controller: valueBController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter Height',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            App.Globals.boxWidth = double.tryParse(valueAController.text)!;
            App.Globals.boxHeight = double.tryParse(valueBController.text)!;
            if (App.Globals.boxWidth > screenWidth) {
              App.Globals.boxWidth = screenWidth;
            }
            if (App.Globals.boxHeight > screenHeight) {
              App.Globals.boxHeight = screenHeight;
            }
            setState(() {});
          },
          child: const Text('Click to Draw'),
        ),
        Container(
          width: 500,
          height: 500,
          child: CustomPaint(
            painter: OpenPainter(),
          ),
        ),
      ]),
    );
  }
}

class OpenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;
    double boxOffsetX = 50;
    double boxOffsetY = 50;
    canvas.drawRect(Offset(boxOffsetX, boxOffsetY) & Size(App.Globals.boxWidth, App.Globals.boxHeight), paint1);
/*
1. randomised number(n) of columns: 3 <= n <= 20
2. Column widths are randomised integers
3. Column heights are randomised integers between 0 and h
 */
    var random = Random();

    //randomised number(n) of columns: 3 <= n <= 20
    int numberOfColumns = random.nextInt(17) + 3;
    print("numberOfColumns: $numberOfColumns");

    //max width of column
    double colAvailableWidth = App.Globals.boxWidth / numberOfColumns;
    print("colAvailableWidth: $colAvailableWidth");
    int? maxWidthOfCol = colAvailableWidth.toInt();
    double minWidthOfCol = colAvailableWidth - ((colAvailableWidth / 4).toInt());
    print("maxWidthOfCol: $maxWidthOfCol");

    List<Bar> bars = [];
    List<int> colWidths = [];
/*
Fill the remaining space with the minimum number rows:
 */
    double colOffset = 0;
    for (int i = 0; i < numberOfColumns; i++) {
      // random columns
      int reuse = 0;
      if (i > 0) {
        if (colWidths[i - 1] < maxWidthOfCol) {
          reuse += maxWidthOfCol - colWidths[i - 1];
        }
      }
      int colWidth = random.nextInt(maxWidthOfCol - minWidthOfCol.toInt() + reuse) + minWidthOfCol.toInt();
      colWidths.add(colWidth);
      print("colWidth: $colWidth");

      int colHeight = random.nextInt(App.Globals.boxHeight.toInt());
      print("colHeight: $colHeight");

      Bar bar = Bar(height: colHeight, width: colWidth, offset: colOffset.toInt());
      bars.add(bar);

      colOffset += colWidth;
    }

    bars[bars.length - 1].width = App.Globals.boxWidth.toInt() - bars[bars.length - 1].offset;
    for (int i = 0; i < bars.length; i++) {
      canvas.drawRect(
          Offset(boxOffsetX + bars[i].offset, App.Globals.boxHeight - bars[i].height + boxOffsetY) & Size(bars[i].width.toDouble(), bars[i].height.toDouble()),
          paint1);
    }

    for (int i = 0; i < bars.length; i++) {
      int? currBarHeight = bars[i].height;
      int? currBarOffset = bars[i].offset; //+bars[i].width;

      for (int j = 0; j < bars.length; j++) {
        if (j > i) {
          if (bars[j].height < bars[i].height) {
            currBarOffset = (currBarOffset! + bars[j].width);
          } else {
            break;
          }
        }
      }

      canvas.drawLine(
        Offset(boxOffsetX + bars[i].offset.toDouble() + bars[i].width.toDouble(), App.Globals.boxHeight - currBarHeight.toDouble() + boxOffsetY),
        Offset(boxOffsetX + currBarOffset!.toDouble() + bars[i].width.toDouble(), App.Globals.boxHeight - currBarHeight.toDouble() + boxOffsetY),
        paint1,
      );
    }
    for (int i = bars.length - 1; i >= 0; i--) {
      int? currBarHeight = bars[i].height;
      int? currBarOffset = bars[i].offset;

      for (int j = bars.length - 1; j >= 0; j--) {
        if (j < i) {
          if (bars[j].height < bars[i].height) {
            currBarOffset = (currBarOffset! - bars[j].width);
          } else {
            break;
          }
        }
      }
      //paint1.color = Colors.red;
      //paint1.strokeWidth = 2;
      canvas.drawLine(
        Offset(boxOffsetX + bars[i].offset.toDouble(), App.Globals.boxHeight - currBarHeight.toDouble() + boxOffsetY),
        Offset(boxOffsetX + currBarOffset!.toDouble(), App.Globals.boxHeight - currBarHeight.toDouble() + boxOffsetY),
        paint1,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Bar {
  int offset = 0;
  int height = 0;
  int width = 0;

  Bar({required this.offset, required this.height, required this.width});

  Bar.fromJson(Map<String, dynamic> json) {
    offset = json['offset'];
    height = json['height'];
    width = json['width'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['offset'] = offset;
    data['height'] = height;
    data['width'] = width;
    return data;
  }
}
