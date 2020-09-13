import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'util/Color.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Box> boxes = <Box>[];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      home: Scaffold(
        // floatingActionButton: FloatingActionButton(onPressed: () {
        //   setState(() {
        //     boxes.add(Box());
        //     print(boxes);
        //   });
        // }),
        body: SlidingUpPanel(
          panel: Panel(),
          body: Home(boxes: boxes),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          children: const <Widget>[
            Center(
              child: Text('Add Task'),
            ),
          ],
        ),
      );
}

List<Widget> generatePalette(Color color) => <Widget>[
      ...List<Box>.generate(
        10,
        (int index) => Box(
          color: color.darken((index + 1) * 10),
        ),
      ).toList().reversed.toList(),
      ...List<Box>.generate(
        10,
        (int index) => Box(
          color: color.brighten((index + 1) * 10),
        ),
      ).toList()
    ];

class Home extends StatefulWidget {
  Home({this.boxes});

  List<Box> boxes;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  // AnimationController animationController;

  @override
  void initState() {
    super.initState();
    // animationController = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      // children: widget.boxes,
      // children: generatePalette(Colors.red),
      children: <Widget>[
        Box(color: Colors.red),
        Box(color: Colors.green),
        Box(color: Colors.blue),
        Box(color: Colors.yellow),
        Box(color: Colors.black),
        Box(color: Colors.white),
      ],
    );
  }
}

enum PlayState { started, stopped }

class Box extends StatefulWidget {
  Box({this.color = Colors.blue, this.title = "Test"});

  Color color;
  String title;

  @override
  _BoxState createState() => _BoxState();
}

class _BoxState extends State<Box> with TickerProviderStateMixin {
  PlayState playState = PlayState.stopped;

  Stopwatch stopwatch = Stopwatch();
  Timer timer;
  Duration elapsed = const Duration();

  AnimationController iconController;

  AnimationController scaleController;

  Color translucentColor;

  @override
  void initState() {
    super.initState();
    iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    translucentColor = widget.color.computeLuminance() < 0.5
        ? widget.color.brighten(75)
        : widget.color.darken(25);
  }

  void updateTime(Timer _) {
    if (stopwatch.isRunning) {
      setState(() {
        elapsed = stopwatch.elapsed;
      });
    }
  }

  void updateState() {
    playState == PlayState.started
        ? playState = PlayState.stopped
        : playState = PlayState.started;
    switch (playState) {
      case PlayState.started:
        setState(() {
          stopwatch.start();
          timer = Timer.periodic(const Duration(milliseconds: 100), updateTime);
          iconController.forward();
        });
        break;
      case PlayState.stopped:
        setState(() {
          stopwatch.stop();
          timer.cancel();
          iconController.reverse();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          setState(updateState);
        },
        onLongPress: () {
          setState(() {
            translucentColor = Colors.black;
          });
        },
        // onLongPressStart: (_) {
        //   print("long press start");
        //   scaleController.animateTo(
        //     0.2,
        //     duration: const Duration(milliseconds: 500),
        //     curve: Curves.easeOutBack,
        //   );
        // },
        // onLongPressEnd: (_) {
        //   print("long press end");
        //   scaleController.animateBack(
        //     0,
        //     duration: const Duration(milliseconds: 500),
        //     curve: Curves.easeOutBack,
        //   );
        // },
        // onLongPressUp: () {
        //   scaleController.animateBack(
        //     0,
        //     duration: const Duration(milliseconds: 500),
        //     curve: Curves.easeOutBack,
        //   );
        // },
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(
              1 - (scaleController.value),
              1 - (scaleController.value),
            ),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: translucentColor,
            child: Container(
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: translucentColor,
                    ),
                  ),
                  Text(
                    elapsed.toString().split('.').first,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                      color: translucentColor,
                    ),
                  ),
                  // Text(playStateString),
                  AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    color: translucentColor,
                    size: 32,
                    progress: iconController,
                  )
                ],
              ),
            ),
          ),
        ),
      );
}
